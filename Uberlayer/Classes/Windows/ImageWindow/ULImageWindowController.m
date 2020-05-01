#import "ULImageWindowController.h"

@interface ULImageWindowController ()
@end

@implementation ULImageWindowController
@synthesize initialLocation = _initialLocation;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.

    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self window] setMovableByWindowBackground:YES];
}
@end
