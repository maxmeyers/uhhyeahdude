//
//  MMDownloadManager.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import "MMFileManager.h"
#import "Media.h"
#import "MMURLConnectionOperation.h"
#import "MMAppDelegate.h"

@interface MMFileManager ()

@property NSMutableDictionary *listeners;
@property NSMutableDictionary *downloads;
@property NSMutableDictionary *progress;
@property NSMutableDictionary *fileStatuses;

@end

@implementation MMFileManager

static MMFileManager *_sharedManager;

+ (MMFileManager *) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[MMFileManager alloc] init];
    }
    return _sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.listeners = [NSMutableDictionary dictionary];
        self.downloads = [NSMutableDictionary dictionary];
        self.progress = [NSMutableDictionary dictionary];
        self.fileStatuses = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) notifyListenersOfDownloadProgress:(float)progress forMedia:(Media *)media  {
    [self.progress setObject:@(progress) forKey:media.fileName];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadProgressNotification object:media];
}

- (void) notifyListenersOfDownloadCompletionForMedia:(Media *)media  {
    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFinishedNotification object:media];
}

- (void) downloadMedia:(Media *)media {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.url]];
    MMURLConnectionOperation *operation = [[MMURLConnectionOperation alloc] initWithRequest:request];
    __weak MMURLConnectionOperation *blockOp = operation;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
        [self notifyListenersOfDownloadProgress:progress forMedia:media];
    }];
    
    [operation setCompletionBlock:^{
        if (!blockOp.isCancelled) {
            [blockOp.responseData writeToFile:[media localFilePath] atomically:NO];
            [self.fileStatuses setObject:@(YES) forKey:media.fileName];
        }
        
        [self notifyListenersOfDownloadCompletionForMedia:media];
        [self.downloads removeObjectForKey:media.fileName];
        if (self.downloads.count == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
    [operation start];
    [self.downloads setObject:operation forKey:media.fileName];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) cancelDownloadForMedia:(Media *)media {
    if ([self.downloads objectForKey:media.fileName]) {
        [(MMURLConnectionOperation *)[self.downloads objectForKey:media.fileName] cancel];
    }
}

- (BOOL) isDownloadingMedia:(Media *)media {
    if ([self.downloads objectForKey:media.fileName]) {
        return YES;
    }
    return NO;
}

- (float) progressForMedia:(Media *)media {
    if ([self.progress objectForKey:media.fileName]) {
        return [(NSNumber *)[self.progress objectForKey:media.fileName] floatValue];
    }
    return 0.0;
}

- (BOOL) hasFileForMedia:(Media *)media {
    if (![self.fileStatuses objectForKey:media.fileName]) {
        NSString *path = media.localFilePath;
        if (path) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [self.fileStatuses setObject:@(YES) forKey:media.fileName];
            } else {
                [self.fileStatuses setObject:@(NO) forKey:media.fileName];
            }
        }
    }
    return [(NSNumber*)[self.fileStatuses objectForKey:media.fileName] boolValue];
}

- (void) deleteFileForMedia:(Media *)media {
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", MEDIA_DIRECTORY, media.fileName] error:nil];
    [self.fileStatuses setObject:@(NO) forKey:media.fileName];
}

@end
