//
//  EpisodeViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MMURLConnectionOperation;

@interface MMEpisodeViewController : UIViewController

@property (nonatomic) BOOL downloading;
@property (nonatomic) BOOL downloaded;
@property (nonatomic) BOOL playing;

@property (strong, nonatomic) Media *media;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;
@property (strong, nonatomic) IBOutlet UIImageView *coverView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *showNotesLabel;

- (IBAction)nowPlayingAction:(id)sender;

- (void)playNow;

@end
