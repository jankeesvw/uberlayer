#import "ULAppDelegate.h"
#import "ULWelcomeWindowController.h"
#import "ULImageWindowController.h"
#import "ULAboutWindowController.h"
#import "ULMoveableWindow.h"
#import "NSImage+QuickLook.h"
#import "ULMouseDownCanMoveWindowImageView.h"

@interface ULAppDelegate ()

@property(nonatomic, strong) ULWelcomeWindowController *welcomeWindowController;
@property(nonatomic, strong) ULAboutWindowController *aboutWindowController;
@property(nonatomic, strong) ULImageWindowController *imageWindowController;
@property(nonatomic, strong) NSNumber *beforeToggleAlpha;

- (void)openWelcomeScreen;

- (void)showOpenDialog;

- (void)openAboutScreen;

- (void)showAlertForLoadingInvalidImage;

- (void)showAlertForNoImageOnClipboard;

- (void)setWindowsToCurrentLockState;

- (void)toggleLock;

- (float)getCurrentAlpha;

- (void)moveWindowX:(float)x windowY:(float)y;

- (void)changeAlphaWindows:(float)value;

- (void)setAlphaWindows:(float)value;
@end

@implementation ULAppDelegate
{
    NSSize loadedImageSize;
}

@synthesize welcomeWindowController = _welcomeWindowController;
@synthesize imageWindowController = _imageWindowController;
@synthesize aboutWindowController = _aboutWindowController;
@synthesize windowIsLocked = _windowIsLocked;
@synthesize beforeToggleAlpha = _beforeToggleAlpha;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self startApplication];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    NSURL *imageURL = [NSURL fileURLWithPath:filename];
    [self loadImage:imageURL];

    return YES;
}

- (void)startApplication
{
    if (self.imageWindowController)
    {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DO_NOT_SHOW_WELCOME_SCREEN_ON_STARTUP])
    {
        [self showOpenDialog];
    }
    else
    {
        [self openWelcomeScreen];
    }
}

- (void)openWelcomeScreen
{
    [self.imageWindowController.window close];

    self.welcomeWindowController = [[ULWelcomeWindowController alloc] initWithWindowNibName:@"ULWelcomeWindowController"];
    self.welcomeWindowController.delegate = self;

    ULMoveableWindow *window = (ULMoveableWindow *) self.welcomeWindowController.window;
    window.moveDelegate = self;

    [self.welcomeWindowController.window setBackgroundColor:NSColor.whiteColor];
    [self.welcomeWindowController.window center];
    [self.welcomeWindowController.window display];
    [self.welcomeWindowController.window makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

    self.windowIsLocked = NO;
    [self setWindowsToCurrentLockState];
}

- (void)openAboutScreen
{
    [self.aboutWindowController close];

    self.aboutWindowController = [[ULAboutWindowController alloc] initWithWindowNibName:@"ULAboutWindowController"];
    [self.aboutWindowController.window center];
    [self.aboutWindowController.window makeKeyAndOrderFront:self];
}

- (void)showOpenDialog
{
    [self.imageWindowController.window setOpaque:NO];
    [self.imageWindowController.window setLevel:NSFloatingWindowLevel];

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.title = @"Choose an image";
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"pdf", @"ai", @"jpg", @"psd", @"gif", @"tiff", @"jpeg", @"tif", nil]];

    [openPanel setDelegate:self];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];

    if ([openPanel runModal])
    {
        NSURL *currentUrl = [openPanel URL];
        [self loadImage:currentUrl];
    }
    else
    {
        // user clicked cancel
    }
}

- (void)loadImage:(NSURL *)url
{

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];

    NSError *error;

    CGSize calculatedSize = [NSImage ptSizeOfImageAtURL:url error:&error];

    NSString *currentFileExtension = [[url pathExtension] lowercaseString];
    NSArray *regularImageExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", nil];

    if ([regularImageExtensions indexOfObject:currentFileExtension] != NSNotFound || CGSizeEqualToSize(calculatedSize, CGSizeZero))
    {
        image = [[NSImage alloc] initWithContentsOfURL:url];
        image.size = calculatedSize;
    }
    else
    {
        image = [NSImage imageWithPreviewOfFileAtPath:url.path ofSize:calculatedSize asIcon:NO];
    }

    if ([image isValid])
    {
        [self showImage:image];
    }
    else
    {
        [self showAlertForLoadingInvalidImage];
    }
}

- (void)showImage:(NSImage *)image
{
    [self.welcomeWindowController close];

    NSRect oldRect = self.imageWindowController.window.frame;
    loadedImageSize = [image size];

    ULMouseDownCanMoveWindowImageView *imageView = [[ULMouseDownCanMoveWindowImageView alloc] initWithFrame:NSMakeRect(0, 0, loadedImageSize.width, loadedImageSize.height)];
    imageView.image = image;

    [self.imageWindowController.window close];
    self.imageWindowController = [[ULImageWindowController alloc] initWithWindowNibName:@"ULImageWindowController"];

    [self.imageWindowController.window.contentView addSubview:imageView];

    NSRect newFrame = NSMakeRect(oldRect.origin.x,
                                 oldRect.origin.y + (oldRect.size.height - loadedImageSize.height),
                                 loadedImageSize.width,
                                 loadedImageSize.height
                                 );

    // if a window less than 0 on the x scale, put in back on the screen
    if (!NSPointInRect(newFrame.origin, self.imageWindowController.window.screen.frame))
    {
        newFrame.origin.x = 1;
    }

    [self.imageWindowController.window setFrame:newFrame display:YES];


    // if this is the first window, put it in the center
    if (oldRect.origin.x == 0.0 && oldRect.origin.y == 0 && oldRect.size.width == 0 && oldRect.size.height == 0)
    {
        [self.imageWindowController.window center];
    }

    [self.imageWindowController.window makeKeyAndOrderFront:self];
    self.imageWindowController.window.delegate = self;
    ULMoveableWindow *movableWindow = (ULMoveableWindow *) self.imageWindowController.window;
    movableWindow.moveDelegate = self;

    [[NSApplication sharedApplication] setApplicationIconImage:[NSImage imageNamed:@"uberlayer-1024-active"]];

    self.windowIsLocked = NO;

    [self setWindowsToCurrentLockState];
}

- (void)showAlertForLoadingInvalidImage
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Uberlayer"];
    [alert setInformativeText:@"Uberlayer does not recognize this file, please try loading another image."];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];

    [alert runModal];
}

- (void)showAlertForNoImageOnClipboard
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Uberlayer"];
    [alert setInformativeText:@"Uberlayer did not find an image on your clipboard."];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];

    [alert runModal];
}

- (void)didClickStartApp
{
    [self.welcomeWindowController close];
    [self showOpenDialog];
    self.welcomeWindowController = nil;
}

- (void)setWindowsToCurrentLockState
{
    self.imageWindowController.window.ignoresMouseEvents = self.windowIsLocked;
    self.welcomeWindowController.window.ignoresMouseEvents = self.windowIsLocked;

    if (self.windowIsLocked)
    {
        self.welcomeWindowController.window.styleMask = NSBorderlessWindowMask;
        self.welcomeWindowController.window.level = NSStatusWindowLevel;
        self.welcomeWindowController.window.hasShadow = NO;

        self.imageWindowController.window.level = NSStatusWindowLevel;
        self.imageWindowController.window.hasShadow = NO;
    }
    else
    {
        self.welcomeWindowController.window.styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
        self.welcomeWindowController.window.level = NSNormalWindowLevel;
        self.welcomeWindowController.window.hasShadow = YES;

        self.imageWindowController.window.level = NSNormalWindowLevel;
        self.imageWindowController.window.hasShadow = YES;
    }
}

- (void)toggleLock
{
    self.windowIsLocked = !self.windowIsLocked;

    [self setWindowsToCurrentLockState];
}

- (IBAction)didClickToggleLocking:(NSMenuItem *)sender
{
    [self toggleLock];
}

- (IBAction)didClickOpenDocument:(NSMenuItem *)sender
{
    [self showOpenDialog];
}

- (IBAction)didClickMoveLeft:(NSMenuItem *)sender
{
    [self moveWindowX:-1 windowY:0];
}

- (IBAction)didClickMoveRight:(NSMenuItem *)sender
{
    [self moveWindowX:1 windowY:0];
}

- (IBAction)didClickMoveUp:(NSMenuItem *)sender
{
    [self moveWindowX:0 windowY:1];
}

- (IBAction)didClickMoveDown:(NSMenuItem *)sender
{
    [self moveWindowX:0 windowY:-1];
}

- (IBAction)didClickMoreTransparent:(NSMenuItem *)sender
{
    [self changeAlphaWindows:-0.05];
}

- (IBAction)didClickLessTransparent:(NSMenuItem *)sender
{
    [self changeAlphaWindows:+0.05];
}

- (IBAction)didClickOpenWelcomeScreen:(id)sender
{
    [self openWelcomeScreen];
}

- (IBAction)didClickAbout:(NSMenuItem *)sender
{
    [self openAboutScreen];
}

- (IBAction)didClickHide:(id)sender
{
    [[NSApplication sharedApplication] hide:self];
}

- (IBAction)didClickClose:(id)sender
{
    [[[NSApplication sharedApplication] keyWindow] close];
}

- (IBAction)didClickToggleVisibility:(id)sender
{
    if (self.beforeToggleAlpha == nil)
    {

        NSNumber *alpha = [NSNumber numberWithFloat:[self getCurrentAlpha]];

        [self setAlphaWindows:0];

        self.beforeToggleAlpha = alpha;
    }
    else
    {
        [self setAlphaWindows:[self.beforeToggleAlpha floatValue]];

        self.beforeToggleAlpha = nil;
    }
}

- (IBAction)didClickPaste:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = [NSArray arrayWithObject:[NSImage class]];
    NSDictionary *options = [NSDictionary dictionary];

    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    if (ok)
    {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        NSImage *image = [objectsToPaste objectAtIndex:0];

        if ([image isValid])
        {
            [self showImage:image];
        }
        else
        {
            [self showAlertForLoadingInvalidImage];
        }
    }
    else
    {
        [self showAlertForNoImageOnClipboard];
    }
}

- (IBAction)didSetOpacity:(id)sender
{
    NSMenuItem *menuItem = sender;
    int key = [[menuItem keyEquivalent] intValue];
    switch (key)
    {
        case 1:
            [self setAlphaWindows:0.1];
            break;
        case 2:
            [self setAlphaWindows:0.2];
            break;
        case 3:
            [self setAlphaWindows:0.3];
            break;
        case 4:
            [self setAlphaWindows:0.4];
            break;
        case 5:
            [self setAlphaWindows:0.5];
            break;
        case 6:
            [self setAlphaWindows:0.6];
            break;
        case 7:
            [self setAlphaWindows:0.7];
            break;
        case 8:
            [self setAlphaWindows:0.8];
            break;
        case 9:
            [self setAlphaWindows:0.9];
            break;
        case 0:
            [self setAlphaWindows:1];
            break;
    }
}

- (IBAction)didSetTransparent:(id)sender
{
    [self setAlphaWindows:0];
}

// necessary screen resolutions
// throw into haskell interpreter like ghc's ghci
// let pointAccurate imageScale = 1/imageScale
// let pixelAccurate imageScale screenScale simScale = (simScale/screenScale)/imageScale
// let necessaryResolutions = nub . sort . concat $ [ [pointAccurate imageScale, pixelAccurate imageScale screenScale simScale] | imageScale <- [1,2,3], screenScale <- [1,2], simScale <- [2,3]]
// necessaryResolutions
// [0.3333333333333333,0.5,0.6666666666666666,0.75,1.0,1.5,2.0,3.0]

- (IBAction)didClickZoomLevel:(NSMenuItem *)sender
{
    NSDictionary<NSNumber *, NSNumber *> *dictionary = @{
        @1: @(1./3.),
        @2: @0.5,
        @3: @(2./3.),
        @4: @0.75,
        @5: @1,
        @6: @1.5,
        @7: @2,
        @8: @3
    };
    CGFloat scale = [dictionary objectForKey:@(sender.tag)].doubleValue;
    [self setImageSize:NSMakeSize(loadedImageSize.width * scale, loadedImageSize.height * scale)];
}

- (void)setImageSize:(NSSize)size
{
    NSRect frame = self.imageWindowController.window.frame;
    // scale from top left corner
    frame.origin.y = frame.origin.y - (size.height - frame.size.height);
    frame.size.width = size.width;
    frame.size.height = size.height;

    [self.imageWindowController.window setFrame:frame display:YES];

    NSImageView *image = [[self.imageWindowController.window.contentView subviews] objectAtIndex:0];

    [image setImageScaling:NSImageScaleAxesIndependently];
    [image setImageAlignment:NSImageAlignBottomLeft];

    frame = image.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    frame.origin.x = 0;
    frame.origin.y = 0;
    image.frame = frame;

    [self performSelector:@selector(applyShadow) withObject:self afterDelay:0];
}

- (void)applyShadow
{
    [self.imageWindowController.window invalidateShadow];
}

- (void)moveLeftFast
{
    [self moveWindowX:-10 windowY:0];
}

- (void)moveRightFast
{
    [self moveWindowX:10 windowY:0];
}

- (void)moveUpFast
{
    [self moveWindowX:0 windowY:10];
}

- (void)moveDownFast
{
    [self moveWindowX:0 windowY:-10];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] setApplicationIconImage:nil];
}

- (float)getCurrentAlpha
{
    return [[[NSApplication sharedApplication] keyWindow] alphaValue];
}

- (void)changeAlphaWindows:(float)value
{
    self.beforeToggleAlpha = nil;

    [self setAlphaWindows:([self getCurrentAlpha] + value)];
}

- (void)setAlphaWindows:(float)value
{
    self.beforeToggleAlpha = nil;

    self.imageWindowController.window.alphaValue = MAX(0.0, MIN(value, 1.0));
    self.welcomeWindowController.window.alphaValue = MAX(0.0, MIN(value, 1.0));
}

- (void)moveWindowX:(float)x windowY:(float)y
{
    NSRect windowFrame = self.imageWindowController.window.frame;
    windowFrame.origin.y += y;
    windowFrame.origin.x += x;
    [self.imageWindowController.window setFrame:windowFrame display:YES animate:YES];

    NSRect welcomeFrame = self.welcomeWindowController.window.frame;
    welcomeFrame.origin.y += y;
    welcomeFrame.origin.x += x;
    [self.welcomeWindowController.window setFrame:welcomeFrame display:YES animate:YES];
}
@end
