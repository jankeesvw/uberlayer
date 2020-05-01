#import <Cocoa/Cocoa.h>
#import <objc/NSObject.h>
#import "ULWelcomeWindowControllerProtocol.h"
#import "ULAppDelegateWindowPositioningProtocol.h"

#define DO_NOT_SHOW_WELCOME_SCREEN_ON_STARTUP @"DontShowWelcomeScreenOnStartup"
#define NSColorFromRGB(rgbValue) [NSColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class ULWelcomeWindowController;
@class ULImageWindowController;
@class ULAboutWindowController;

@interface ULAppDelegate : NSObject <ULAppDelegateWindowPositioningProtocol, NSApplicationDelegate, NSOpenSavePanelDelegate, ULWelcomeWindowControllerProtocol, NSWindowDelegate>

@property(nonatomic, assign) BOOL windowIsLocked;


- (IBAction)didClickMoreTransparent:(NSMenuItem *)sender;
- (IBAction)didClickLessTransparent:(NSMenuItem *)sender;
- (void)loadImage:(NSURL *)url;
- (IBAction)didClickToggleLocking:(NSMenuItem *)sender;
- (IBAction)didClickOpenDocument:(NSMenuItem *)sender;
- (IBAction)didClickMoveLeft:(NSMenuItem *)sender;
- (IBAction)didClickMoveRight:(NSMenuItem *)sender;
- (IBAction)didClickMoveUp:(NSMenuItem *)sender;
- (IBAction)didClickMoveDown:(NSMenuItem *)sender;
- (IBAction)didClickOpenWelcomeScreen:(id)sender;
- (IBAction)didClickAbout:(NSMenuItem *)sender;
- (IBAction)didClickHide:(id)sender;
- (IBAction)didClickClose:(id)sender;
- (IBAction)didClickToggleVisibility:(id)sender;
- (IBAction)didClickPaste:(id)sender;
- (IBAction)didSetOpacity:(id)sender;
- (IBAction)didSetTransparent:(id)sender;
- (IBAction)didClickHalfSize:(id)sender;
- (IBAction)didClickActualSize:(id)sender;
- (IBAction)didClickDoubleSize:(id)sender;
@end
