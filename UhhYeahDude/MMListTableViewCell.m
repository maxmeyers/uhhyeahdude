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

- (void) setImage
{
    if (self.media.image) {
        if (self.theImageView.image == self.media.image) {
            return;
        }
        self.theImageView.image = self.media.image;
    } else {
        self.theImageView.image = nil;

        NSString *localFilePath = self.media.localThumbnailFilePath;
        self.theImageView.image = [UIImage imageWithContentsOfFile:localFilePath];
        if (!self.theImageView.image) {
            NSLog(@"requesting an image for %@", self.media.title);
            __weak NSURL *thisURL = [NSURL URLWithString:[self.media thumbUrl]];
            __block UIImage *previousImage = self.theImageView.image;
            UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultEpisode_thumb" ofType:@"png"]];
            
            __weak MMListTableViewCell *weakSelf = self;
            [self.theImageView setImageWithURL:thisURL placeholderImage:placeHolder
                success:^(UIImage *image) {
                    // If the URL matches the media filename, which it should...
                    if ([[thisURL absoluteString] isEqualToString:weakSelf.media.thumbUrl]) {
                        if ([[thisURL absoluteString] rangeOfString:@"http"].location != NSNotFound) {
                            NSLog(@"saving image %@", weakSelf.media.imageName);
                            [UIImageJPEGRepresentation(image, 1.0) writeToFile:localFilePath atomically:YES];
                            NSLog(@"Path: %@", localFilePath);
                        }
                    } else {
                        NSLog(@"The cell that should have gotten %@ got %@ instead.", weakSelf.media.imageName, [[thisURL absoluteString] lastPathComponent]);
                        weakSelf.theImageView.image = previousImage;
                    }
                    
                } failure:^(NSError *error) {
                    if (weakSelf.media.imageName && [[thisURL absoluteString] rangeOfString:weakSelf.media.imageName].location != NSNotFound) {
                        weakSelf.media.image = placeHolder;
                        NSLog(@"%@ failed: %@", weakSelf.media.title, thisURL);
                    }
                }];
        }

    }
}

- (IBAction)downloadButtonPressed {
    if (self.downloading) {
        [[MMFileManager sharedManager] cancelDownloadForMedia:self.media];
        self.downloading = NO;
    } else {
        self.downloadProgressView.progress = 0.0;
        [[MMFileManager sharedManager] downloadMedia:self.media];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressedForMedia:) name:kDownloadProgressNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedForMedia:) name:KDownloadFinishedNotification object:nil];
        self.downloading = YES;
    }
}

- (BOOL) downloading {
    return _downloading;
}

- (void) downloadProgressedForMedia:(NSNotification*)notification {
    Media *media = notification.object;
    if (self.media == media) {
        float progress = [[MMFileManager sharedManager] progressForMedia:self.media];
        self.downloadProgressView.progress = progress;
    }
}

- (void) downloadFinishedForMedia:(NSNotification*)notification {
    Media *media = notification.object;
    if (self.media == media) {
        [self setDownloadStatus];
    }
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
}

- (void) setDownloadStatus {
    if ([[MMFileManager sharedManager] hasFileForMedia:self.media]) {
        self.downloadButton.hidden = YES;
    }
    if ([[MMFileManager sharedManager] isDownloadingMedia:self.media]) {
        self.downloading = YES;
    } else {
        self.downloading = NO;
    }
}

@end