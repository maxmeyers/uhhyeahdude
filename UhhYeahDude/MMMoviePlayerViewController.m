//
//  MMMoviePlayerViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/29/12.
//
//

#import "MMMoviePlayerViewController.h"
#import "MMMedia.h"

@implementation MMMoviePlayerViewController

- (void) viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNotification:) name:nil object:self.moviePlayer];
}

- (void) observeNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"MPMoviePlayerDidEnterFullscreenNotification"]) {
        [self setBackgroundImage];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
        
    if ([notification.name isEqualToString:@"MPMoviePlayerDidExitFullscreenNotification"]) {
        [self setBackgroundImage];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setBackgroundImage];
    [super viewWillAppear:animated];
}

- (void) setBackgroundImage
{
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    UIImage *backgroundImage = self.media.image;
    if (backgroundImage && self.media.mediaType == Episode) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        
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
        
        self.backgroundImageView.frame = CGRectMake(x, y, width, height);
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        overlayView.backgroundColor = [UIColor blackColor];
        [self.moviePlayer.backgroundView addSubview:overlayView];
        [self.moviePlayer.backgroundView addSubview:self.backgroundImageView];
    }
}

// Overriding this prevents the moviePlayer from stopping
- (void) viewDidDisappear:(BOOL)animated {
    for (UIView *view in self.moviePlayer.backgroundView.subviews) {
        [view removeFromSuperview];
    }
    if (self.media.mediaType == SethsCorner) {
        [super viewDidDisappear:animated];
    }
}

@end
