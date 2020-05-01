//
//  EELog.m
//  CDChanges
//
//  Created by Eric-Paul Lecluse on 12-01-12.
//  Copyright (c) 2012 epologee. All rights reserved.
//

#import "EELog.h"

int kLogLevel = LOG_LEVEL;

void QuietLog (NSString *format, ...) {
    if (format == nil) {
        printf("nil\n");
        return;
    }
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
    va_end(argList);
}