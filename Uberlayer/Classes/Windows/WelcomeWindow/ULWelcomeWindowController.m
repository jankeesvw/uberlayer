#import "ULWelcomeWindowController.h"
#import "ULWelcomeWindowControllerProtocol.h"
#import "ULAppDelegate.h"

@implementation ULWelcomeWindowController

@synthesize showWindowOnLaunchCheckbox = showWindowOnLaunchCheckbox_;
@synthesize delegate = _delegate;

- (IBAction)didClickCheckbox:(id)sender
{
    BOOL enabled = self.showWindowOnLaunchCheckbox.state == NSOnState;
    [[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:DO_NOT_SHOW_WELCOME_SCREEN_ON_STARTUP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)didClickStartApplication:(id)sender
{
    [self.delegate didClickStartApp];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.showWindowOnLaunchCheckbox.state = [[NSUserDefaults standardUserDefaults] boolForKey:DO_NOT_SHOW_WELCOME_SCREEN_ON_STARTUP] ? NSOffState : NSOnState;
    [[self.showWindowOnLaunchCheckbox cell] setHighlightsBy:NSNoCellMask];
}

@end
