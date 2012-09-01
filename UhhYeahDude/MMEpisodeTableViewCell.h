//
//  MMEpisodeTableViewCell.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <UIKit/UIKit.h>

@class MMEpisode;

@interface MMEpisodeTableViewCell : UITableViewCell

@property (weak) MMEpisode *episode;
@property (strong, nonatomic) IBOutlet UIImageView *episodeImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@end
