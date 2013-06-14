//
//  MMDownloadManager.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import "MMDownloadManager.h"
#import "MMMedia.h"
#import "MMURLConnectionOperation.h"

@interface MMDownloadManager ()

@property NSMutableDictionary *listeners;
@property NSMutableDictionary *downloads;

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
    }
    return self;
}

- (void) registerListener:(id<MMDownloadListener>)listener forMedia:(MMMedia *)media {
    if (![self.listeners objectForKey:media]) {
        [self.listeners setObject:[NSMutableArray array] forKey:media];
    }
    
    if ([[self.listeners objectForKey:media] indexOfObject:media] == NSNotFound) {
        [[self.listeners objectForKey:media] addObject:listener];
    }
}

- (void) deregisterListener:(id<MMDownloadListener>)listener {
    for (NSMutableArray *listenerList in self.listeners.allValues) {
        [listenerList removeObject:listener];
    }
}

- (void) notifyListenersOfDownloadProgress:(float)progress forMedia:(MMMedia *)media  {
    if ([self.listeners objectForKey:media]) {
        for (id<MMDownloadListener> listener in [self.listeners objectForKey:media]) {
            [listener downloadProgressForMedia:media atProgress:progress];
        }
    }
}

- (void) notifyListenersOfDownloadCompletionForMedia:(MMMedia *)media  {
    if ([self.listeners objectForKey:media]) {
        for (id<MMDownloadListener> listener in [self.listeners objectForKey:media]) {
            [listener downloadFinishedForMedia:media];
        }
    }
}

- (void) downloadMedia:(MMMedia *)media {
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
        [self.downloads removeObjectForKey:media];
        if (self.downloads.count == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
    [operation start];
    [self.downloads setObject:operation forKey:media];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) cancelDownloadForMedia:(MMMedia *)media {
    if ([self.downloads objectForKey:media]) {
        [(MMURLConnectionOperation *)[self.downloads objectForKey:media] cancel];
    }
}

- (BOOL) isDownloadingMedia:(MMMedia *)media {
    if ([self.downloads objectForKey:media]) {
        return YES;
    }
    return NO;
}

@end
