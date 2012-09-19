//
//  EpisodeViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMMediaViewController.h"
#import "MMMedia.h"
#import "AFNetworking.h"
#import "MMAppDelegate.h"
#import "SoundManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MMMoviePlayerViewController.h"
#import "MMDownloadManager.h"

@implementation MMMediaViewController

- (id) init
{
    self = [super init];
    if (self) {
        self.downloaded = NO;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.downloading ? 80 : 60;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return self.descriptionLabel.frame.size.height + 20;
        }
    }
    return tableView.rowHeight;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    self.firstLoading = YES;
    downloadedPlayFrame = CGRectMake(20, 8, 260, 44);
    downloadedStreamFrame = CGRectMake(280, 8, 0, 44);
    
    if (self.media.epDescription) {
        self.descriptionLabel.text = self.media.epDescription;
        self.descriptionLabel.numberOfLines = 0;
        CGRect frame = self.descriptionLabel.frame;
        frame.size.height = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
        self.descriptionLabel.frame = frame;
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    self.title = (self.media.shortTitle) ? self.media.shortTitle : self.media.title;
    
    self.downloaded = (self.media.fileStatus == Available);
    if (!self.downloaded) {
        if ([[MMDownloadManager sharedManager] isDownloadingMedia:self.media]) {
            [[MMDownloadManager sharedManager] registerListener:self forMedia:self.media];
            self.downloading = YES;
        }
    }
    self.nowPlayingButton = self.navigationItem.rightBarButtonItem;
    self.firstLoading = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MPVC media]) {
        self.navigationItem.rightBarButtonItem = self.nowPlayingButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setDescriptionLabel:nil];
    [self setDownloadPlayButton:nil];
    [self setStreamButton:nil];
    [self setDownloadProgressView:nil];
    [super viewDidUnload];
}

- (IBAction)downloadButtonAction:(id)sender {
    if (!self.downloading && !self.downloaded) {
        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.media.url]];
//        self.operation = [[MMURLConnectionOperation alloc] initWithRequest:request];
//        self.operation.media = self.media;
//        __block MMURLConnectionOperation *operation = self.operation;
//        [[APP_DELEGATE downloads] addObject:self.operation];
//        [self.operation setCompletionBlock:^{
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            if (!self.operation.isCancelled) {
//                self.media.fileStatus = Available;
//                NSData *file = self.operation.responseData;
//                NSString *path = [self.media localFilePath];
//                [file writeToFile:path atomically:NO];
//                self.downloading = NO;
//                self.downloaded = YES;
//                self.operation = nil;
//            } else {
//                self.downloaded = NO;
//                self.downloading = NO;
//            }
//            [[APP_DELEGATE downloads] removeObject:operation];
//        }];
//        [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//            float progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
//            self.downloadProgressView.progress = progress;
//        }];
//        [self.operation start];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[MMDownloadManager sharedManager] registerListener:self forMedia:self.media];
        [[MMDownloadManager sharedManager] downloadMedia:self.media];
        self.downloading = YES;
    } else if (self.downloaded) {
        NSURL *path = [NSURL fileURLWithPath:[self.media localFilePath]];
        [self playMediaWithURL:path];
    }
}

- (IBAction)streamButtonAction:(id)sender {
    if (self.downloading) {
        [[MMDownloadManager sharedManager] cancelDownloadForMedia:self.media];
    }
    [self playMediaWithURL:[NSURL URLWithString:self.media.url]];
}

- (void)playMediaWithURL:(NSURL *)url
{
    if (MPVC.media != self.media) {
        MMMoviePlayerViewController *mpvc = [[MMMoviePlayerViewController alloc] initWithContentURL:url];
        [mpvc setMedia:self.media];
        if (self.media.playStatus == Started) {
            [mpvc.moviePlayer setInitialPlaybackTime:self.media.playbackTime];
        }
        [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] setMpvc:mpvc];
        [[mpvc moviePlayer] setControlStyle:MPMovieControlStyleDefault];
    }
    [[self navigationController] pushViewController:MPVC animated:YES];
}

- (IBAction)nowPlayingAction:(id)sender {
    [self.navigationController pushViewController:MPVC animated:YES];
}

- (void) setButtonText
{
    NSString *buttonText = @"";
    if (self.downloading) {
        buttonText = @"Downloading...";
    } else {
        buttonText = self.downloaded ? @"Play" : @"Download";
    }
    [self.downloadPlayButton setTitle:buttonText forState:UIControlStateNormal];
}

- (void) downloadProgressForMedia:(MMMedia *)media atProgress:(float)progress
{
    self.downloadProgressView.progress = progress;
}

- (void) downloadFinishedForMedia:(MMMedia *)media
{
    self.downloading = NO;
    self.downloaded = (media.fileStatus == Available);
}

- (void) setDownloading:(BOOL)downloading
{
    _downloading = downloading;
    [UIView animateWithDuration:0.5f animations:^{
        self.downloadProgressView.hidden = !downloading;
    }];
    self.downloadPlayButton.userInteractionEnabled = !downloading;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self setButtonText];
}

- (void) setDownloaded:(BOOL)downloaded
{
    _downloaded = downloaded;
    [self setButtonText];
    if (downloaded) {
        if (self.firstLoading) {
            self.downloadPlayButton.frame = downloadedPlayFrame;
            self.streamButton.frame = downloadedStreamFrame;
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.downloadPlayButton.frame = downloadedPlayFrame;
                self.streamButton.frame = downloadedStreamFrame;
            }];
        }
    }
}



@end
