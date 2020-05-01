//
//  NSImage+QuickLook.m
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import "NSImage+QuickLook.h"
#import <QuickLook/QuickLook.h> // Remember to import the QuickLook framework into your project!

@implementation NSImage (QuickLook)

+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)asIcon
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL)
    {
        return nil;
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:asIcon] forKey:(__bridge NSString *) kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef) fileURL, CGSizeMake(size.width, size.height), (__bridge CFDictionaryRef) dict);

    if (ref != NULL)
    {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep)
        {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];

            CFRelease(ref);
            if (newImage)
            {
                return newImage;
            }
        }
        CFRelease(ref);
    } else
    {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon)
        {
            [icon setSize:size];
        }
        return icon;
    }

    return nil;
}

+ (CGSize)sizeOfImageAtURL:(NSURL *)fileURL error:(NSError **)error
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(__bridge NSString *) kCGImageSourceShouldCache];

    CFDictionaryRef cOptions = (__bridge_retained CFDictionaryRef) options;

    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef) fileURL, cOptions);
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, cOptions);

    CFRelease(cOptions);

    CFRelease(source);

    if (imageProperties)
    {
        CGFloat width = [(__bridge NSNumber *) CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) floatValue];
        CGFloat height = [(__bridge NSNumber *) CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight) floatValue];

        int rotation = [(__bridge NSNumber *) CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation) intValue];

        CGSize size;
        if (rotation < 5)
        {
            size = CGSizeMake(width, height);
        } else
        {
            //flip
            size = CGSizeMake(height, width);
        }

        CFRelease(imageProperties);

        return size;
    }
    else
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:@"NSImage-QuickLook-Category" code:1 userInfo:nil];
        }
        return CGSizeZero;
    }
}
@end
