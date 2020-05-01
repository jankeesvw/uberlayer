#import <Cocoa/Cocoa.h>

@interface ULAboutWindowController : NSWindowController

@property (strong) IBOutlet NSButton *twelveTwentyButton;
@property (strong) IBOutlet NSView *twelveTwentyButtonContainer;
@property (strong) IBOutlet NSTextField *shortVersionTextField;
@property (strong) IBOutlet NSTextField *buildNumberTextField;

@property(nonatomic, strong) NSTrackingArea *twelveTwentyTrackingArea;

- (IBAction)didClickTwelveTwenty:(id)sender;

@end
