//
//  MMDownloadManager.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import "MMDownloadManager.h"
#import "Media.h"
#import "MMURLConnectionOperation.h"

@interface MMDownloadManager ()

@property NSMutableDictionary *listeners;
@property NSMutableDictionary *downloads;
@property NSMutableDictionary *progress;

@end

@implementation MMDownloadManager

static MMDownloadManager *_sharedManager;

+ (MMDownloadManager *) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[MMDownloadManager alloc] init];
    }
    return _sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.listeners = [NSMutableDictionary dictionary];
        self.downloads = [NSMutableDictionary dictionary];
        self.progress = [NSMutableDictionary dictionary];
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
            media.fileStatus = Available;
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

@end
