//
//  MMEpisodeTableViewCell.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMListTableViewCell.h"
#import "Media.h"
#import "UIImageView+WebCache.h"
#import "MMFileManager.h"

@implementation MMListTableViewCell

@synthesize downloading = _downloading;

- (IBAction)downloadButtonPressed {
    if (self.downloading) {
        [[MMFileManager sharedManager] cancelDownloadForMedia:self.media];
        [self setDownloadStatus];
    } else {
        self.downloadProgressView.progress = 0.0;
        [[MMFileManager sharedManager] downloadMedia:self.media];
        [self setDownloadStatus];
    }
}

- (void) downloadProgressedForMedia:(NSNotification*)notification {
    Media *media = notification.object;
    if (self.media == media) {
        [self performSelectorOnMainThread:@selector(setProgress) withObject:nil waitUntilDone:NO];
    }
}

- (void) downloadFinishedForMedia:(NSNotification*)notification {
    Media *media = notification.object;
    if (self.media == media) {
        [self performSelectorOnMainThread:@selector(setDownloadStatus) withObject:nil waitUntilDone:NO];
    }
}


- (BOOL) downloading {
    return _downloading;
}

- (void) setProgress {
    float progress = [[MMFileManager sharedManager] progressForMedia:self.media];
    self.downloadProgressView.progress = progress;
}

- (void) setDownloading:(BOOL)downloading {
    _downloading = downloading;

    if (downloading) {
        self.downloadProgressView.hidden = NO;
        [self.downloadButton setImage:[UIImage imageNamed:@"downloadProgressButton.png"] forState:UIControlStateNormal];
        [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadProgressWell.png"] forState:UIControlStateNormal];
    } else {
        self.downloadProgressView.hidden = YES;
        [self.downloadButton setImage:[UIImage imageNamed:@"downloadButton.png"] forState:UIControlStateNormal];
        [self.downloadButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
}

- (void) setDownloadStatus {
    self.downloadButton.hidden = [[MMFileManager sharedManager] hasFileForMedia:self.media];
    BOOL downloading = [[MMFileManager sharedManager] isDownloadingMedia:self.media];
    self.downloading = downloading;
}

@end