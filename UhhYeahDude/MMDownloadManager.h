//
//  MMDownloadManager.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import <Foundation/Foundation.h>

#define kDownloadProgressNotification @"DOWNLOAD_PROGRESS_NOTIFICATION"
#define KDownloadFinishedNotification @"DOWNLOAD_FINISHED_NOTIFICATION"

@class Media;

@interface MMDownloadManager : NSObject

+ (MMDownloadManager *) sharedManager;

- (void) downloadMedia:(Media *)media;
- (void) cancelDownloadForMedia:(Media *)media;
- (BOOL) isDownloadingMedia:(Media *)media;
- (float) progressForMedia:(Media *)media;

@end