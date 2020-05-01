//
//  Created by Eric-Paul Lecluse @ 2011.
//

#import "NSThread+Reusabilitee.h"

@implementation NSThread (BlocksAdditions)

- (void)performBlock:(void (^)())block
{
    if ([[NSThread currentThread] isEqual:self])
        block();
    else
        [self performBlock:block waitUntilDone:NO];
}

+ (void)ng_runBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(ng_runBlock:)
                     onThread:self
                   withObject:[block copy]
                waitUntilDone:wait];
}

+ (void)performBlockInBackground:(void (^)())block
{
    [NSThread performSelectorInBackground:@selector(ng_runBlock:)
                               withObject:[block copy]];
}
@end