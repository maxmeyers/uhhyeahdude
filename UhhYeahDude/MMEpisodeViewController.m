//
//  EpisodeViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodeViewController.h"
#import "MMEpisode.h"
#import "AFNetworking.h"
#import "MMAppDelegate.h"
#import "MMNavigationViewController.h"
#import "SoundManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MMMoviePlayerViewController.h"

@implementation MMEpisodeViewController

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
    self.descriptionLabel.text = self.episode.epDescription;
    self.descriptionLabel.numberOfLines = 0;
    CGRect frame = self.descriptionLabel.frame;
    frame.size.height = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    self.descriptionLabel.frame = frame;
    self.title = (self.episode.shortTitle) ? self.episode.shortTitle : self.episode.title;
    
    if (_episode.fileStatus == Available) {
        self.downloaded = YES;
    } else {
        self.downloaded = NO;
    }
    self.nowPlayingButton = self.navigationItem.rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MPVC episode]) {
        self.navigationItem.rightBarButtonItem = self.nowPlayingButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.sound stop];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setDescriptionLabel:nil];
    [self setDownloadButton:nil];
    [self setPlayButton:nil];
    [self setDownloadProgressView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)downloadButtonAction:(id)sender {
    if (!self.downloading && !self.downloaded) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.episode.url]];
        AFURLConnectionOperation *op = [[AFURLConnectionOperation alloc] initWithRequest:request];
        [op setCompletionBlock:^{
            self.episode.fileStatus = Available;
            NSData *file = op.responseData;
            NSString *path = [self.episode localFilePath];
            [file writeToFile:path atomically:NO];
            self.downloading = NO;
            self.downloaded = YES;
        }];
        [op setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
            self.downloadProgressView.progress = progress;
        }];
        [op start];
        self.downloading = YES;
    } else if (self.downloaded) {
        NSURL *path = [NSURL fileURLWithPath:[_episode localFilePath]];
        MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:path];
        [[self navigationController] pushViewController:mpvc animated:YES];
    }
}

- (IBAction)streamButtonAction:(id)sender {
    MMMoviePlayerViewController *mpvc = MPVC;
    [[mpvc moviePlayer] setContentURL:[NSURL URLWithString:[self.episode url]]];
    [[mpvc moviePlayer] setControlStyle:MPMovieControlModeVolumeOnly];
    [mpvc setEpisode:self.episode];
    [[self navigationController] pushViewController:mpvc animated:YES];
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
    [self.downloadButton setTitle:buttonText forState:UIControlStateNormal];
}

- (void) setDownloading:(BOOL)downloading
{
    _downloading = downloading;
    [UIView animateWithDuration:0.5f animations:^{
        self.downloadProgressView.hidden = !downloading;
    }];
    self.downloadButton.userInteractionEnabled = !downloading;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self setButtonText];
}

- (void) setDownloaded:(BOOL)downloaded
{
    _downloaded = downloaded;
    [self setButtonText];
}



@end
