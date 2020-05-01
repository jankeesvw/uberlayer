#import <Foundation/Foundation.h>
#import "ULMoveableWindow.h"

@protocol ULAppDelegateWindowPositioningProtocol;

@interface ULImageWindow : ULMoveableWindow <NSDraggingDestination>

@end