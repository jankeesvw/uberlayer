#import <Cocoa/Cocoa.h>

@protocol ULWelcomeWindowControllerProtocol;

@interface ULWelcomeWindowController : NSWindowController <NSWindowDelegate, NSDraggingDestination>

@property (unsafe_unretained) IBOutlet NSButton *showWindowOnLaunchCheckbox;
@property (nonatomic, assign) id <ULWelcomeWindowControllerProtocol> delegate;

- (IBAction)didClickCheckbox:(id)sender;
- (IBAction)didClickStartApplication:(id)sender;

@end
