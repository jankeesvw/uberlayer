//
//  Created by Eric-Paul Lecluse @ 2011.
//

#import "EESingleton.h"

@implementation EESingleton

static NSMutableDictionary* instances = nil;

+ (id) instance
{
    @synchronized(self)
    {
        if (!instances) {
            instances = [[NSMutableDictionary alloc] init];
        }
        
        id instance = [instances objectForKey:self];
        if (!instance) {
            instance = [[self alloc] init];
            [instances setObject:instance forKey:(id)self];
        }
        
        return instance;
    }
}

+ (void) destroyInstance
{
    @synchronized(self)
    {
        [instances removeObjectForKey:self];
        if ([instances count] == 0) [self destroyAllSingletons];
    }
}

+ (void) destroyAllSingletons
{
    @synchronized(self)
    {
        [instances removeAllObjects];
        instances = nil;
    }
}


@end