//
//  NSImage+QuickLook.h
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (QuickLook)


+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)icon;
+ (CGSize)sizeOfImageAtURL:(NSURL *)fileURL error:(NSError **)error;

@end
