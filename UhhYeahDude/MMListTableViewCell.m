//
//  MMEpisodeTableViewCell.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMListTableViewCell.h"
#import "Media.h"
#import "UIImageView+WebCache.h"

@implementation MMListTableViewCell

- (void) setImage
{
    if (self.media.image) {
        if (self.theImageView.image == self.media.image) {
            return;
        }
        self.theImageView.image = self.media.image;
    } else {
        self.theImageView.image = nil;

        NSString *localFilePath = self.media.localThumbnailFilePath;
        self.theImageView.image = [UIImage imageWithContentsOfFile:localFilePath];
        if (!self.theImageView.image) {
            NSLog(@"requesting an image for %@", self.media.shortTitle);
            __weak NSURL *thisURL = [NSURL URLWithString:[self.media thumbUrl]];
            __block UIImage *previousImage = self.theImageView.image;
            UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultEpisode_thumb" ofType:@"png"]];
            
            __weak MMListTableViewCell *weakSelf = self;
            [self.theImageView setImageWithURL:thisURL placeholderImage:placeHolder
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
                        weakSelf.theImageView.image = previousImage;
                    }
                    
                } failure:^(NSError *error) {
                    if (weakSelf.media.imageName && [[thisURL absoluteString] rangeOfString:weakSelf.media.imageName].location != NSNotFound) {
                        weakSelf.media.image = placeHolder;
                        NSLog(@"%@ failed: %@", weakSelf.media.shortTitle, thisURL);
                    }
                }];
        }

    }
}
@end