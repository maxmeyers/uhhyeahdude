//
//  MMEpisodeTableViewCell.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <UIKit/UIKit.h>

@class MMMedia;

@interface MMListTableViewCell : UITableViewCell

@property (weak) MMMedia *media;
@property (strong, nonatomic) IBOutlet UIImageView *theImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIView *frameView;

- (void) setImage;

@end
