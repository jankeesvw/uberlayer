#import "ULMouseDownCanMoveWindowImageView.h"
#import "ULAppDelegate.h"

@implementation ULMouseDownCanMoveWindowImageView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }

    return self;
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSArray *items = [[sender draggingPasteboard] pasteboardItems];
    for (NSPasteboardItem *item in items)
    {
        NSString *draggedURLString = [item stringForType:@"public.file-url"];

        NSString *fileExtension = [[NSURL fileURLWithPath:draggedURLString] pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) fileExtension, NULL);

        if (UTTypeConformsTo(fileUTI, kUTTypeImage) || UTTypeConformsTo(fileUTI, kUTTypePDF))
        {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSArray *items = [[sender draggingPasteboard] pasteboardItems];
    for (NSPasteboardItem *item in items)
    {
        NSString *draggedURLString = [item stringForType:@"public.file-url"];
        NSURL *draggedURL = [NSURL URLWithString:draggedURLString];
        NSString *draggedPath = [draggedURL path];
        [(ULAppDelegate *) [[NSApplication sharedApplication] delegate] loadImage:[NSURL fileURLWithPath:draggedPath]];
        return;
    }
}

- (BOOL)mouseDownCanMoveWindow
{
    return YES;
}
@end