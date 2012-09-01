//
//  MMEpisodePlayViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MMEpisodePlayViewController : UIViewController

+ (MMEpisodePlayViewController *) sharedController;

@property (nonatomic) MPMoviePlayerController *mpc;

@end
