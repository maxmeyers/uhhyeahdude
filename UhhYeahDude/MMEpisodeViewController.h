//
//  EpisodeViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMEpisode, Sound;

@interface MMEpisodeViewController : UITableViewController <UITableViewDelegate>

@property (nonatomic) BOOL downloading;
@property (nonatomic) BOOL downloaded;

@property (nonatomic) BOOL playing;

@property (strong, nonatomic) Sound *sound;
@property (strong, nonatomic) MMEpisode *episode;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;

- (IBAction)downloadButtonAction:(id)sender;
- (IBAction)streamButtonAction:(id)sender;
- (IBAction)nowPlayingAction:(id)sender;

@end
