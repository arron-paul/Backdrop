#import "ApplicationsFolder.h"

#import <sys/param.h>
#import <sys/mount.h>
#import <dlfcn.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <AppKit/AppKit.h>
#import "Constants.h"


@implementation ApplicationsFolder

+ (BOOL)isInApplicationsFolder
{
    if ([self __isBundleInApplicationsDirectory:[[NSBundle mainBundle] bundlePath]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)peformMoveToApplicationsFolderIfNecessary
{
    // Skip this dialog if the user has requested it to be supressed.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_SUPRESS_MOVE_TO_APPLICATIONS_FOLDER_DIALOG])
        return;

    // Path of the bundle
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];

    // Skip this dialog if the application already exists in the 'Applications' folder
    if ([self isInApplicationsFolder]) {
        return;
    }

    // File Manager
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Are we on a disk image?
    NSString *mountedLocation = [self __mountedDevice];

    // Since we are good to go, get the preferred installation directory.
    BOOL installToUserFolder = NO;
    NSString *appDirectories = [self __preferableDestination:&installToUserFolder];
    NSString *bundleName = [bundlePath lastPathComponent];
    NSString *destinationPath = [appDirectories stringByAppendingPathComponent:bundleName];

    // Check if we need admin password to write to the Applications directory
    BOOL needsAuthentication = ([fileManager isWritableFileAtPath:appDirectories] == NO);

    // Check if the destination bundle is already there but not writable
    needsAuthentication |= ([fileManager fileExistsAtPath:destinationPath] && ![fileManager isWritableFileAtPath:destinationPath]);

    // Setup the alert
    NSAlert *alert = [[NSAlert alloc] init];

    // Specify the message for the alert
    NSString *alertContent = nil;
    [alert setMessageText:(installToUserFolder ? MOVE_TO_APP_FOLDER_IN_USER_HOME : MOVE_TO_APP_FOLDER)];
    alertContent = MOVE_TO_APP_FOLDER_BODY;

    // Optional messages depending on certain conditions
    if (needsAuthentication)
        alertContent = [alertContent stringByAppendingString:MOVE_TO_APP_SUDO];
    else if ([self __isBundleInDownloadsDirectory:bundlePath])
        alertContent = [alertContent stringByAppendingString:MOVE_TO_APP_DOWNLOAD_FOLDER_INFO];

    [alert setInformativeText:alertContent];

    // Add accept button
    NSButton *alertAcceptButton = [alert addButtonWithTitle:MOVE_TO_APP_FOLDER_TITLE];
    [alertAcceptButton setKeyEquivalent:@"\r"];

    // Add deny button
    NSButton *alertCancelButton = [alert addButtonWithTitle:MOVE_TO_APP_FOLDER_DECLINE];
    [alertCancelButton setKeyEquivalent:@"\e"];

    // Add 'Suppress alert' tick box.
    [alert setShowsSuppressionButton:YES];
    NSCell *alertCell = [[alert suppressionButton] cell];
    [alertCell setControlSize:NSControlSizeSmall];
    [alertCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];

    // Activate application to suppress the "Scary file from the Internet" dialog.
    if (![NSApp isActive])
        [NSApp activateIgnoringOtherApps:YES];

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // Attempt move to 'Applications' folder.
        if (needsAuthentication) {
            BOOL hasCanceledAuthentication;

            if (![self __invokeAuthenticationWithSource:bundlePath destination:destinationPath canceled:&hasCanceledAuthentication]) {
                if (hasCanceledAuthentication) {
                    NSLog(@"User canceled authentication request");
                    return;
                } else {
                    NSLog(@"Error: Could not copy the .app to the Applications folder with authorization");
                    goto fail;
                }
            }

        } else {
            // If a copy already exists in the Applications folder, then place it in the trash.
            if ([fileManager fileExistsAtPath:destinationPath]) {
                // But lets make sure that it's not running first
                if ([self __isBundleAtPathRunning:destinationPath]) {
                    // Attempt to give the running application, focus, and then programatically terminate.
                    NSLog(@"Info: Switching to an already running version");
                    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:destinationPath]] waitUntilExit];
                    exit(0);

                } else {
                    if ([self __trashBundle:[appDirectories stringByAppendingPathComponent:bundleName]])
                        goto fail;
                }
            }

            // Now, lets attempt to copy
            if (![self __copyBundle:bundlePath destination:destinationPath]) {
                NSLog(@"Error: Could not copy .app to %@", destinationPath);
                goto fail;
            }
        }

        // Now lets trash the original .app bundle. It's okay if this fails.
        if (mountedLocation == nil && ![self __deleteOrTrashBundle:bundlePath])
            NSLog(@"Warning: Could not delete application after moving it to Applications folder");

        // Relaunch the .app
        [self __relaunchBundle:destinationPath];

        // If launched from a disk image, unmount if no files are open after 5 seconds, otherwise leave it mounted.
        if (mountedLocation != nil) {
            NSString *script = [NSString stringWithFormat:@"(/bin/sleep 5 && /usr/bin/hdiutil detach %@) &", [self __shellStringFormat:mountedLocation]];
            [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", script, nil]];
        }

        exit(0);

    }

    // Save the alert suppress preference if checked
    else if ([[alert suppressionButton] state] == NSControlStateValueOn)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_SUPRESS_MOVE_TO_APPLICATIONS_FOLDER_DIALOG];

    return;

fail:

    // Show failure message
    alert = [[NSAlert alloc] init];
    [alert setMessageText:MOVE_TO_APP_FOLDER_FAIL];
    [alert runModal];
}

+ (BOOL)__isBundleInApplicationsDirectory:(NSString *)path
{
    // Check all known Application directories
    NSArray *applicationDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSAllDomainsMask, YES);
    for (NSString *appDir in applicationDirs)
        if ([path hasPrefix:appDir]) return YES;

    // Handle the case where the user has some other Application folder
    if ([[path pathComponents] containsObject:@"Applications"])
        return YES;

    return NO;
}

+ (NSString *)__mountedDevice
{
    NSString *containingPath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    struct statfs fs;

    if (statfs([containingPath fileSystemRepresentation], &fs) || (fs.f_flags & MNT_ROOTFS))
        return nil;

    NSString *device = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:fs.f_mntfromname length:strlen(fs.f_mntfromname)];
    NSTask *hdiutil = [[NSTask alloc] init];

    [hdiutil setLaunchPath:@"/usr/bin/hdiutil"];
    [hdiutil setArguments:[NSArray arrayWithObjects:@"info", @"-plist", nil]];
    [hdiutil setStandardOutput:[NSPipe pipe]];
    [hdiutil launch];
    [hdiutil waitUntilExit];

    NSData *data = [[[hdiutil standardOutput] fileHandleForReading] readDataToEndOfFile];
    id info;

#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
        info = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
    } else {
#endif
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
        info = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
#endif
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
    }
#endif

    if (![info isKindOfClass:[NSDictionary class]])
        return nil;

    if (![[info objectForKey:@"images"] isKindOfClass:[NSArray class]])
        return nil;

    for (id image in [info objectForKey:@"images"]) {
        if (![image isKindOfClass:[NSDictionary class]])
            return nil;

        if (![[image objectForKey:@"system-entities"] isKindOfClass:[NSArray class]])
            return nil;

        for (id systemEntity in [image objectForKey:@"system-entities"]) {
            if (![[systemEntity objectForKey:@"dev-entry"] isKindOfClass:[NSString class]])
                return nil;

            if ([[systemEntity objectForKey:@"dev-entry"] isEqualToString:device])
                return device;
        }
    }

    return nil;
}

+ (NSString *)__preferableDestination:(BOOL *)isUserDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *appDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);

    if ([appDirectories count] > 0) {
        BOOL isDirectory;

        if ([fileManager fileExistsAtPath:[appDirectories objectAtIndex:0] isDirectory:&isDirectory] && isDirectory) {
            // The user 'Applications' folder is found, get the contents.
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:[appDirectories objectAtIndex:0] error:NULL];

            // Ensure that there's at least one .app in there.
            for (NSString *path in contents) {
                if ([[path pathExtension] isEqualToString:@"app"]) {
                    if (isUserDirectory) *isUserDirectory = YES;
                    return [[appDirectories objectAtIndex:0] stringByResolvingSymlinksInPath];
                }
            }
        }
    }

    // Cannot find a user 'Applications' folder. Use the global 'Applications' folder instead.
    if (isUserDirectory) *isUserDirectory = NO;
    return [[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES) lastObject] stringByResolvingSymlinksInPath];
}

+ (BOOL)__isBundleInDownloadsDirectory:(NSString *)path
{
    // If the bundle 'path' is in any 'Downloads' folder.
    NSArray *downloadDirectories = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSAllDomainsMask, YES);
    for (NSString *downloadsDirPath in downloadDirectories)
        if ([path hasPrefix:downloadsDirPath]) return YES;

    return NO;
}

+ (NSString *)__shellStringFormat:(NSString *)string
{
    return [NSString stringWithFormat:@"'%@'", [string stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"]];
}

+ (BOOL)__invokeAuthenticationWithSource:(NSString *)sourcePath destination:(NSString *)destinationPath canceled:(BOOL *)isCanceled
{
    if (isCanceled) *isCanceled = NO;

    // Ensure that the destination is bundle.
    if (![destinationPath hasSuffix:@".app"]) return NO;

    // Additional verification
    if ([[destinationPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        return NO;
    if ([[sourcePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        return NO;

    // Lets get hella technical
    int pid, status;
    AuthorizationRef authorization;

    // Attempt to retrieve the authorization
    OSStatus authorizationStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorization);

    if (authorizationStatus != errAuthorizationSuccess)
        return NO;

    AuthorizationItem authorizationItems = {kAuthorizationRightExecute, 0, NULL, 0};

    AuthorizationRights authorizationRights = {1, &authorizationItems};

    AuthorizationFlags authorizationFlags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;

    authorizationStatus = AuthorizationCopyRights(authorization, &authorizationRights, NULL, authorizationFlags, NULL);

    if (authorizationStatus != errAuthorizationSuccess) {
        if (authorizationStatus == errAuthorizationCanceled && isCanceled)
            *isCanceled = YES;
        goto fail;
    }

    static OSStatus (*authExecuteWithPriviledges)(AuthorizationRef authorization, const char *path, AuthorizationFlags options, char *const *arguments, FILE **communicationsPipe) = NULL;

    if (!authExecuteWithPriviledges)
        authExecuteWithPriviledges = dlsym(RTLD_DEFAULT, "AuthorizationExecuteWithPrivileges");

    if (!authExecuteWithPriviledges)
        goto fail;

    // Attempt to delete the destination path
    char *deleteArguments[] = {"-rf", (char *)[destinationPath fileSystemRepresentation], NULL};
    authorizationStatus = authExecuteWithPriviledges(authorization, "/bin/rm", kAuthorizationFlagDefaults, deleteArguments, NULL);
    if (authorizationStatus != errAuthorizationSuccess)
        goto fail;

    // Wait until it's done
    pid = wait(&status);
    if (pid == -1 || !WIFEXITED(status))
        goto fail;

    // Attempt to copy the source
    char *copyArguments[] = {"-pR", (char *)[sourcePath fileSystemRepresentation], (char *)[destinationPath fileSystemRepresentation], NULL};
    authorizationStatus = authExecuteWithPriviledges(authorization, "/bin/cp", kAuthorizationFlagDefaults, copyArguments, NULL);
    if (authorizationStatus != errAuthorizationSuccess)
        goto fail;

    // Wait until it's done
    pid = wait(&status);
    if (pid == -1 || !WIFEXITED(status) || WEXITSTATUS(status)) goto fail;

    AuthorizationFree(authorization, kAuthorizationFlagDefaults);
    return YES;

fail:

    AuthorizationFree(authorization, kAuthorizationFlagDefaults);
    return NO;
}

+ (BOOL)__isBundleAtPathRunning:(NSString *)path
{
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5

    // OS X 10.6 and above uses this API
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
        for (NSRunningApplication *application in [[NSWorkspace sharedWorkspace] runningApplications]) {
            NSString *executablePath = [[application executableURL] path];
            if ([executablePath hasPrefix:path])
                return YES;
        }

        return NO;
    }

#endif

    // Otherwise, use a shell script to see if the app is already running on 10.5 and below.
    NSString *script = [NSString stringWithFormat:@"/bin/ps ax -o comm | /usr/bin/grep %@/ | /usr/bin/grep -v grep >/dev/null", [self __shellStringFormat:path]];
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", script, nil]];
    [task waitUntilExit];

    // If terminated with an exit code of 0, it means that grep had 1 or more lines of output, thus there is an app already running
    return [task terminationStatus] == 0;
}

+ (BOOL)__trashBundle:(NSString *)path
{
    if ([[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:[path stringByDeletingLastPathComponent] destination:@"" files:[NSArray arrayWithObject:[path lastPathComponent]] tag:NULL])
        return YES;
    else {
        NSLog(@"Error: Could not trash '%@'", path);
        return NO;
    }
}

+ (BOOL)__copyBundle:(NSString *)sourcePath destination:(NSString *)destinationPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if ([fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error])
        return YES;
    else {
        NSLog(@"Error: Could not copy '%@' to '%@' (%@)", sourcePath, destinationPath, error);
        return NO;
    }
}

+ (BOOL)__deleteOrTrashBundle:(NSString *)path
{
    NSError *error;

    if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error])
        return YES;
    else {
        NSLog(@"Warning: Could not delete '%@': %@", path, [error localizedDescription]);
        return [self __trashBundle:path];
    }
}

+ (void)__relaunchBundle:(NSString *)destinationPath
{
    // The shell script waits until the original app closes, this is so that the relaunched app opens as the front-most app.
    int pid = [[NSProcessInfo processInfo] processIdentifier];
    NSString *exec = @"";

    // Before we launch, clear com.apple.quarantine to avoid 'scary file from the internet' dialog.
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5)
        exec = [NSString stringWithFormat:@"/usr/bin/xattr -d -r com.apple.quarantine %@", [self __shellStringFormat:destinationPath]];
    else
        exec = [NSString stringWithFormat:@"/usr/bin/xattr -d com.apple.quarantine %@", [self __shellStringFormat:destinationPath]];

    // Execute script.
    [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"(while /bin/kill -0 %d >&/dev/null; do /bin/sleep 0.1; done; %@; /usr/bin/open %@) &", pid, exec, [self __shellStringFormat:destinationPath]], nil]];
}

@end
