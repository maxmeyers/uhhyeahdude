//
//  MMEpisodeTableViewCell.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class MMMedia, Media;

@interface MMListTableViewCell : UITableViewCell

@property (weak) Media *media;
@property (strong, nonatomic) IBOutlet UIImageView *theImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@property BOOL downloading;

- (void) setDownloadStatus;
- (IBAction)downloadButtonPressed;

@end
