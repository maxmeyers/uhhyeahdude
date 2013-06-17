//
//  MMEpisodeCollectionViewCell.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/17/13.
//
//

#import "MMEpisodeCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "Media.h"

@implementation MMEpisodeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setImage
{
    if (self.media.image) {
        if (self.imageView.image == self.media.image) {
            return;
        }
        self.imageView.image = self.media.image;
    } else {
        self.imageView.image = nil;
        
        NSString *localFilePath = self.media.localThumbnailFilePath;
        self.imageView.image = [UIImage imageWithContentsOfFile:localFilePath];
        if (!self.imageView.image) {
            NSLog(@"requesting an image for %@", self.media.title);
            __weak NSURL *thisURL = [NSURL URLWithString:[self.media thumbUrl]];
            __block UIImage *previousImage = self.imageView.image;
            UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultEpisode_thumb" ofType:@"png"]];
            
            __weak MMEpisodeCollectionViewCell *weakSelf = self;
            [self.imageView setImageWithURL:thisURL placeholderImage:placeHolder
                                       success:^(UIImage *image) {
                                           // If the URL matches the media filename, which it should...
                                           if ([[thisURL absoluteString] isEqualToString:weakSelf.media.thumbUrl]) {
                                               if ([[thisURL absoluteString] rangeOfString:@"http"].location != NSNotFound) {
                                                   NSLog(@"saving image %@", weakSelf.media.imageName);
                                                   [UIImageJPEGRepresentation(image, 1.0) writeToFile:localFilePath atomically:YES];
                                                   NSLog(@"Path: %@", localFilePath);
                                               }
                                           } else {
                                               NSLog(@"The cell that should have gotten %@ got %@ instead.", weakSelf.media.imageName, [[thisURL absoluteString] lastPathComponent]);
                                               weakSelf.imageView.image = previousImage;
                                           }
                                           
                                       } failure:^(NSError *error) {
                                           if (weakSelf.media.imageName && [[thisURL absoluteString] rangeOfString:weakSelf.media.imageName].location != NSNotFound) {
                                               weakSelf.media.image = placeHolder;
                                               NSLog(@"%@ failed: %@", weakSelf.media.title, thisURL);
                                           }
                                       }];
        }
        
    }
}

@end
