//
//  EpisodeViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMMedia, AFURLConnectionOperation;

@interface MMMediaViewController : UITableViewController <UITableViewDelegate> {
    CGRect downloadedPlayFrame;
    CGRect downloadedStreamFrame;
}

@property BOOL firstLoading;
@property (nonatomic) BOOL downloading;
@property (nonatomic) BOOL downloaded;
@property (nonatomic) BOOL playing;

@property (strong, nonatomic) MMMedia *media;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *downloadPlayButton;
@property (strong, nonatomic) IBOutlet UIButton *streamButton;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;
@property AFURLConnectionOperation *operation;

- (IBAction)downloadButtonAction:(id)sender;
- (IBAction)streamButtonAction:(id)sender;
- (IBAction)nowPlayingAction:(id)sender;

@end
