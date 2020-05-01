#import "ULImageWindow.h"

@implementation ULImageWindow

@synthesize moveDelegate;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

    if (self != nil)
    {
        self.backgroundColor = [NSColor clearColor];
        self.hasShadow = NO;
        self.opaque = NO;
    }

    return self;
}


- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
}
@end
