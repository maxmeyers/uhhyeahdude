//
//  MMMoviePlayerViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/29/12.
//
//

#import "MMMoviePlayerViewController.h"
#import "MMNavigationViewController.h"

@implementation MMMoviePlayerViewController

- (void) viewWillAppear:(BOOL)animated
{
    UIImage *backgroundImage = [UIImage imageNamed:@"335.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    CGRect superFrame = self.moviePlayer.backgroundView.bounds;
    
    int width, height, x, y;
    if (backgroundImage.size.width >= backgroundImage.size.height) {
        width = superFrame.size.width;
        height = (backgroundImage.size.height/backgroundImage.size.width)*width;
        x = 0;
        y = floor((superFrame.size.height / 2) - (height / 2));
    } else {
        height = superFrame.size.height;
        width = (backgroundImage.size.width/backgroundImage.size.height)*height;
        x = floor((superFrame.size.width / 2) - (width / 2));
        y = 0;
    }
    
    backgroundImageView.frame = CGRectMake(x, y, width, height);

    [self.moviePlayer.backgroundView addSubview:backgroundImageView];
    [super viewWillAppear:animated];
}

// Overriding this prevents the moviePlayer from stopping
- (void) viewDidDisappear:(BOOL)animated {}

@end
