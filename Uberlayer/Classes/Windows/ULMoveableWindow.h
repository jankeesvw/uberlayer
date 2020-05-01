#import <Foundation/Foundation.h>

@protocol ULAppDelegateWindowPositioningProtocol;

@interface ULMoveableWindow : NSWindow <NSWindowDelegate>

@property(nonatomic, assign) id <ULAppDelegateWindowPositioningProtocol> moveDelegate;

@end