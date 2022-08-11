#ifndef Constants_h
#define Constants_h

#define APP_TITLE @"Backdrop"

#define ARGUMENT_BACKGROUND_LAUNCH @"BackgroundLaunch"

// defaults for preferences that can be changed
#define DEFAULT_CLICK_COUNT 3
#define DEFAULT_LAUNCH_ON_STARTUP NO
#define DEFAULT_SHOW_PHOTOGRAPHER_DETAILS YES

// corresponding key identifiers for each of these preferences
#define KEY_HAS_BEEN_LAUNCHED_BEFORE @"hasBeenLaunchedBefore"
#define KEY_CLICK_COUNT @"clickCount"
#define KEY_LAUNCH_ON_STARTUP @"launchOnStartup"
#define KEY_SHOW_PHOTOGRAPHER_DETAILS @"showPhotographerDetails"
#define KEY_SUPRESS_MOVE_TO_APPLICATIONS_FOLDER_DIALOG @"moveToApplicationsFolderAlertSuppress"

// backdrop tooltips
#define TOOLTIP_LAUNCH_ON_STARTUP_ENABLED @"Launches Backdrop in the background when the computer starts."
#define TOOLTIP_LAUNCH_ON_STARTUP_DISABLED @"Backdrop must be in the Applications folder to enable this feature."
#define TOOLTIP_CHECK_FOR_UPDATES @"Automatically check for software updates."
#define TOOLTIP_SHOW_PHOTOGRAPHER_DETAILS @"Shows photographer details when retrieving photos."
#define TOOLTIP_LANGUAGE_SELECT @""
#define TOOLTIP_ACTIVTION_SELECT @"Specify the number of clicks required to change the wallpaper."

// backdrop dialogs
#define ALERT_FORCE_CLOSE_TEXT @"To keep Backdrop running hidden in the background – re-open the app and close the window with ⌘+Q next time."
#define ALERT_FORCE_CLOSE_TITLE @"Stopping Backdrop…"
#define ALERT_FORCE_CLOSE_OPTION_CLOSE @"Stop"

#define ALERT_AUTOLAUNCH_ERROR_TEXT @"macOS requires apps that launch on System Startup to be located in the Applications folder."
#define ALERT_AUTOLAUNCH_ERROR_TITLE @"Backdrop needs to be in Applications folder"
#define ALERT_API_DATA_ISSUE_TEXT @"The photo data received doesn’t map correctly."
#define ALERT_API_DATA_ISSUE_TITLE @"Action Cancelled"
#define ALERT_CANNOT_SAVE_PHOTO @"Could not save wallpaper to disk. Please ensure that %@ is writable"
#define ALERT_SHARED_BUTTON_OK @"OK"

#define DOWNLOAD_RESPONSE_401_TITLE @"Unauthorized"
#define DOWNLOAD_RESPONSE_401_BODY @"Not allowed to download photo"
#define DOWNLOAD_RESPONSE_403_TITLE @"Limit Reached"
#define DOWNLOAD_RESPONSE_403_BODY @"The hourly limit for how many photos you can download has been reached."
#define DOWNLOAD_RESPONSE_404_TITLE @"Not Found"
#define DOWNLOAD_RESPONSE_404_BODY @"This resource is not available."
#define DOWNLOAD_RESPONSE_TITLE @"Server returned a HTTP %li"
#define DOWNLOAD_RESPONSE_BODY @"The response cannot be handled."


// backdrop controls
#define UI_LABEL_PHOTO_BY @"Photo by "

// maspreferences
#define MASPREFS_PANEL_DESKTOP @"Desktop"
#define MASPREFS_PANEL_ABOUT @"About"
#define MASPREFS_PANEL_SETTINGS @"Settings"

// about screen
#define PANEL_ABOUT_COPYRIGHT @"Copyright © %@. Made with ♡ by Arron Paul"
#define PANEL_ABOUT_VERSION @"Backdrop — Version %@"
#define PANEL_ABOUT_BUILD @"Build %@"

// unsplash
#define UNSPLASH_API_VERSION @"v1"
//#define UNSPLASH_API_BASE_URL @"https://api.unsplash.com/"
#define UNSPLASH_API_REQUEST_RANDOM @"https://api.unsplash.com/photos/random?featured"

// misc
#define FINDER_APP_NAME @"Finder"
//#define NETWORK_SCHEMA @"https"
#define BACKDROP_FOLDER @"/Backdrop Downloads/"

// backdrophelper xpc
#define BACKDROP_HELPER_XPC_PATH @"Contents/Library/LoginItems/BackdropHelper.app"
#define BACKDROP_HELPER_IDENTIFIER @"io.arron.BackdropHelper"

// applications folder
#define MOVE_TO_APP_FOLDER_IN_USER_HOME @"Move to Applications folder in your Home folder?"
#define MOVE_TO_APP_FOLDER @"Move to Applications folder?"
#define MOVE_TO_APP_FOLDER_BODY @"Moving Backdrop to the Applications folder provides additional capabilities."
#define MOVE_TO_APP_SUDO @" Note that this will require an administrator password."
#define MOVE_TO_APP_DOWNLOAD_FOLDER_INFO @" This will keep your Downloads folder uncluttered."
#define MOVE_TO_APP_FOLDER_TITLE @"Move to Applications"
#define MOVE_TO_APP_FOLDER_DECLINE @"Do Not Move"
#define MOVE_TO_APP_FOLDER_FAIL @"Could not move to Applications folder"

#endif
