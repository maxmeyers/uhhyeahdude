//
//  UIImageView+LocalFirst.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/20/13.
//
//

#import "UIImageView+LocalFirst.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (LocalFirst)

- (void) setImageWithURL:(NSURL*)url placeHolderImage:(UIImage *)placeHolder butTryLocalPathFirst:(NSString *)localPath {
    UIImage *localImage = [UIImage imageWithContentsOfFile:localPath];
    if (localImage) {
        self.image = localImage;
    } else {
        [self setImageWithURL:url placeholderImage:placeHolder success:^(UIImage *image) {
            if ([[url absoluteString] rangeOfString:@"http"].location != NSNotFound) {
                NSLog(@"saving image %@", localPath);
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:localPath atomically:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
