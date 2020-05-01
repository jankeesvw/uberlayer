//
//  Created by Eric-Paul Lecluse @ 2011.
//
//  By design of http://vladimir.zardina.org/2010/12/managing-multiple-singleton-classes-in-objective-c/
//

#import <Foundation/Foundation.h>


@interface EESingleton : NSObject

+ (id) instance;
+ (void) destroyInstance;
+ (void) destroyAllSingletons;

@end
