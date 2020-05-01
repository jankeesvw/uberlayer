//
//  Created by Eric-Paul Lecluse @ 2011.
//

#import <Foundation/Foundation.h>

@interface NSThread (BlocksAdditions)

- (void)performBlock:(void (^)())block;

- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;

+ (void)performBlockInBackground:(void (^)())block;

@end