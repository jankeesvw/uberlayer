//
//  EELog.h
//  CDChanges
//
//  Created by Eric-Paul Lecluse on 12-01-12.
//  Copyright (c) 2012 epologee. All rights reserved.
//

#define LOG_LEVEL_DEBUG		10
#define LOG_LEVEL_INFO		20
#define LOG_LEVEL_WARN		30
#define LOG_LEVEL_ERROR		40

#define LOG_LEVEL			10

extern int kLogLevel;

#define LOG_DEBUG			(LOG_LEVEL <= LOG_LEVEL_DEBUG)
#define LOG_INFO			(LOG_LEVEL <= LOG_LEVEL_INFO)
#define LOG_WARN			(LOG_LEVEL <= LOG_LEVEL_WARN)
#define LOG_ERROR			(LOG_LEVEL <= LOG_LEVEL_ERROR)

void QuietLog (NSString *format, ...);

#if LOG_DEBUG
#   define DLog(...) if (kLogLevel <= LOG_LEVEL_DEBUG) { QuietLog(@"\n%@(%d) ⇨ %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
//#   define DLog(...) if (kLogLevel <= LOG_LEVEL_DEBUG) { NSLog(@"[DEBUG]%s(%d)\n⇨ %@\n ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#else
#	define DLog(...)
#endif

#if LOG_INFO
#if LOG_DEBUG
#   define ILog(...) if (kLogLevel <= LOG_LEVEL_INFO) { QuietLog(@"\n[INFO]\t%@(%d) ⇨ %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#else
#	define ILog(...) if (kLogLevel <= LOG_LEVEL_INFO) { NSLog(@"[INFO]%s(%d)\n⇨ %@\n ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#endif
#else
#	define ILog(...)
#endif

#if LOG_WARN
#if LOG_DEBUG
#   define WLog(...) if (kLogLevel <= LOG_LEVEL_WARN) { QuietLog(@"\n[WARN]\t%@(%d) ⇨ %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#else
#	define WLog(...) if (kLogLevel <= LOG_LEVEL_WARN) { NSLog(@"[WARN]%s(%d)\n⇨ %@\n ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#endif
#else
#	define WLog(...)
#endif

#if LOG_ERROR
#if LOG_DEBUG
#   define ELog(...) if (kLogLevel <= LOG_LEVEL_ERROR) { QuietLog(@"\n[ERROR]\t%@(%d) ⇨ %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#else
#	define ELog(...) if (kLogLevel <= LOG_LEVEL_ERROR) { NSLog(@"[ERROR]%s(%d)\n⇨ %@\n ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]); }
#endif
#else
#	define ELog(...)
#endif
