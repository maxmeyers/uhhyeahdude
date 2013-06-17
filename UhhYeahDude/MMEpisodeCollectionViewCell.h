//
//  MMEpisodeCollectionViewCell.h
//  UhhYeahDude
//
//  Created by Max Meyers on 6/17/13.
//
//

#import <UIKit/UIKit.h>

@class Media;

@interface MMEpisodeCollectionViewCell : UICollectionViewCell

@property (weak) Media *media;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (void) setImage;

@end
