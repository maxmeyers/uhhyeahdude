//
//  EpisodeViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodeViewController.h"
#import "Media.h"
#import "AFNetworking.h"
#import "MMAppDelegate.h"
#import "SoundManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MMMoviePlayerViewController.h"
#import "MMFileManager.h"
#import "UIImageView+LocalFirst.h"

@implementation MMEpisodeViewController

- (id) init
{
    self = [super init];
    if (self) {
        self.downloaded = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = NO;
    self.title = self.media.title;
    
    [self.coverView setImageWithURL:[NSURL URLWithString:self.media.imageUrl] placeHolderImage:[UIImage imageNamed:@"defaultEpisode.png"] butTryLocalPathFirst:self.media.localImageFilePath];
    
    self.descriptionLabel.text = self.media.desc;
    self.showNotesLabel.text = self.media.notes;
    
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MPVC media]) {
        self.navigationItem.rightBarButtonItem = self.nowPlayingButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [super viewWillAppear:animated];
}

- (void) playNow {
    self.downloaded = [[MMFileManager sharedManager] hasFileForMedia:self.media];
    if (self.downloaded) {
        NSURL *path = [NSURL fileURLWithPath:[self.media localFilePath]];
        [self playMediaWithURL:path pushView:YES];
    } else {
        [self playMediaWithURL:[NSURL URLWithString:self.media.url] pushView:YES];
    }
}

- (void)playMediaWithURL:(NSURL *)url pushView:(BOOL)push
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
    
    if (push) {
        [[self navigationController] pushViewController:MPVC animated:YES];
    }
}

- (IBAction)nowPlayingAction:(id)sender {
    [self.navigationController pushViewController:MPVC animated:YES];
}


@end
