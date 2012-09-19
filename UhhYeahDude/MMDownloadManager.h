//
//  MMDownloadManager.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import <Foundation/Foundation.h>

@class MMMedia;

@protocol MMDownloadListener

- (void) downloadProgressForMedia:(MMMedia *)media atProgress:(float)progress;
- (void) downloadFinishedForMedia:(MMMedia *)media;

@end

@interface MMDownloadManager : NSObject

+ (MMDownloadManager *) sharedManager;

- (void) registerListener:(id<MMDownloadListener>)listener forMedia:(MMMedia *)media;
- (void) deregisterListener:(id<MMDownloadListener>)listener;

- (void) downloadMedia:(MMMedia *)media;
- (void) cancelDownloadForMedia:(MMMedia *)media;
- (BOOL) isDownloadingMedia:(MMMedia *)media;

@end