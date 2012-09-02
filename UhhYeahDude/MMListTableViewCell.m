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
    self.theImageView.image = nil;
    if (self.media.image) {
        self.theImageView.image = self.media.image;
    } else {
        NSMutableArray *possibilities = [NSMutableArray array];
        [possibilities addObject:[NSURL fileURLWithPath:[self.media localImageFilePath]]];
        [possibilities addObject:[NSURL URLWithString:[self.media remoteImageFilePath]]];
        [self setEpisodeImageWithPossibilities:possibilities currentIndex:0];
    }
}

- (void) setEpisodeImageWithPossibilities:(NSArray *)possibilities currentIndex:(int) i  {
    __weak NSURL *thisURL = [possibilities objectAtIndex:i];
    __weak MMListTableViewCell *blockCell = self;
    UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultEpisode" ofType:@"png"]];
    [self.theImageView setImageWithURL:[possibilities objectAtIndex:i] placeholderImage:placeHolder
        success:^(UIImage *image) {
            if ([[thisURL absoluteString] rangeOfString:self.media.imageName].location != NSNotFound) {
                self.media.image = image;
                if ([[thisURL absoluteString] rangeOfString:@"http"].location != NSNotFound) {
                    NSLog(@"saving image %@", self.media.imageName);
                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:self.media.localImageFilePath atomically:YES];
                }
            } else {
                NSLog(@"The cell that should have gotten %@ got %@ instead.", self.media.imageName, [[thisURL absoluteString] lastPathComponent]);
            }
            
        } failure:^(NSError *error) {
            if (i+1 < [possibilities count]) {
                [blockCell setEpisodeImageWithPossibilities:possibilities currentIndex:i+1];
            } else {
                self.media.image = placeHolder;
                self.theImageView.image = placeHolder;
            }
        }];
}

@end
