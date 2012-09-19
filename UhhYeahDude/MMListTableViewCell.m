//
//  MMEpisodeTableViewCell.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMListTableViewCell.h"
#import "MMMedia.h"
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
            __weak NSURL *thisURL = [NSURL URLWithString:[self.media remoteThumbnailFilePath]];
            __block UIImage *previousImage = self.theImageView.image;
            UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultEpisode_thumb" ofType:@"png"]];
            [self.theImageView setImageWithURL:thisURL placeholderImage:placeHolder
                success:^(UIImage *image) {
                    // If the URL matches the media filename, which it should...
                    if ([[thisURL absoluteString] isEqualToString:self.media.remoteThumbnailFilePath]) {
                        if ([[thisURL absoluteString] rangeOfString:@"http"].location != NSNotFound) {
                            NSLog(@"saving image %@", self.media.imageName);
                            [UIImageJPEGRepresentation(image, 1.0) writeToFile:localFilePath atomically:YES];
                        }
                    } else {
                        NSLog(@"The cell that should have gotten %@ got %@ instead.", self.media.imageName, [[thisURL absoluteString] lastPathComponent]);
                        self.theImageView.image = previousImage;
                    }
                    
                } failure:^(NSError *error) {
                    if (self.media.imageName && [[thisURL absoluteString] rangeOfString:self.media.imageName].location != NSNotFound) {
                        self.media.image = placeHolder;
                        NSLog(@"%@ failed: %@", self.media.shortTitle, thisURL);
                    }
                }];
        }

    }
}
@end