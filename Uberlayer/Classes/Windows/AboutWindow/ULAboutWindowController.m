#import "ULAboutWindowController.h"
#import "ULAppDelegate.h"

@interface ULAboutWindowController ()

@end

@implementation ULAboutWindowController
@synthesize shortVersionTextField = shortVersionTextField_;
@synthesize buildNumberTextField = buildNumberTextField_;
@synthesize twelveTwentyButton = twelveTwentyButton_;
@synthesize twelveTwentyButtonContainer = twelveTwentyButtonContainer_;
@synthesize twelveTwentyTrackingArea = _twelveTwentyTrackingArea;

- (void) awakeFromNib {
    [self.window setBackgroundColor: NSColorFromRGB(0xDF5935)];
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    self.shortVersionTextField.stringValue = shortVersion;
    self.buildNumberTextField.stringValue = [NSString stringWithFormat:@"BUILD %@",buildNumber];
}

- (IBAction)didClickTwelveTwenty:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.twelvetwenty.nl"]];
}

@end
