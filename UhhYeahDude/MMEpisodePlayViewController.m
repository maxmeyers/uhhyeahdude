//
//  MMEpisodePlayViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodePlayViewController.h"

static MMEpisodePlayViewController *_sharedController = nil;

@implementation MMEpisodePlayViewController

+ (MMEpisodePlayViewController *) sharedController
{
    if (!_sharedController) {
        _sharedController = [[MMEpisodePlayViewController alloc] init];
    }
    return _sharedController;
}

- (void) setMpc:(MPMoviePlayerController *)mpc
{
    _mpc = mpc;
    [[_mpc view] setFrame:self.view.bounds];
    [self.view addSubview:mpc.view];
}

@end
