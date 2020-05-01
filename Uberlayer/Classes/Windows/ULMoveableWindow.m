#import "ULMoveableWindow.h"
#import "ULAppDelegateWindowPositioningProtocol.h"

@implementation ULMoveableWindow

@synthesize moveDelegate = _moveDelegate;

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSShiftKeyMask)
    {
        switch ([theEvent keyCode])
        {
            case 123:
                [self.moveDelegate moveLeftFast];
                return;
                break;
            case 124:
                [self.moveDelegate moveRightFast];
                return;
                break;
            case 125:
                [self.moveDelegate moveDownFast];
                return;
                break;
            case 126:
                [self.moveDelegate moveUpFast];
                return;
                break;
        }
    }
    [super keyDown:theEvent];
}
@end