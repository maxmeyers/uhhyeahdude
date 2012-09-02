//
//  MMMoviePlayerViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/29/12.
//
//

#import <MediaPlayer/MediaPlayer.h>

@class MMMedia;

@interface MMMoviePlayerViewController : MPMoviePlayerViewController

@property UIImageView *backgroundImageView;
@property MMMedia *media;

@end
