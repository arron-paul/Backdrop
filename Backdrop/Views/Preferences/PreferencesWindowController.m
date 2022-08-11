#import "PreferencesWindowController.h"
#import "NSWindowFade.h"


@interface PreferencesWindowController ()

@end


@implementation PreferencesWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)awakeFromNib
{
    // Subclass the MASPreferences NSWindow to we can apply custom keyboard event logic
    [self setWindow:[[PreferencesWindow alloc] init]];

    // Appearance of the window
    [self.window setStyleMask:self.window.styleMask | NSWindowStyleMaskClosable];

    // Ensure that the window stays at a fixed position
    CGSize fixedSize = CGSizeMake(420.0f, 272.0f);
    [self.window setMinSize:fixedSize];
    [self.window setMaxSize:fixedSize];

    // Appearance of the title bar
    [self.window setTitlebarAppearsTransparent:YES];
    [self.window setTitleVisibility:NSWindowTitleHidden];

    // Appeareance of the toolbar
    [self.toolbar setVisible:NO];

    // Right-click context menu with 'Customize This Toolbar' options.
    [self.toolbar setAllowsUserCustomization:NO];

    // Ensure that we can move the window, dragging the menu bar or anywhere on the background.
    [self.window setMovable:YES];
    [self.window setMovableByWindowBackground:YES];
}

- (void)selectControllerAtIndex:(NSUInteger)controllerIndex
{
    // Ensure minimize/resize buttons stay disabled regardless of MASPreferences child controllers
    [super selectControllerAtIndex:controllerIndex];
    [[self.window standardWindowButton:NSWindowCloseButton] setState:NSControlStateValueOn];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NSControlStateValueOff];
    [[self.window standardWindowButton:NSWindowZoomButton] setEnabled:NSControlStateValueOff];
}

- (void)showWindow:(id)sender
{
    [self.window center];
    [super showWindow:sender];
}

@end
