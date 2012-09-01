//
//  MMAppDelegate.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAppDelegate.h"
#import "MMEpisodeDataSource.h"
#import <AVFoundation/AVFoundation.h>
#import "MMMoviePlayerViewController.h"

@implementation MMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[MMEpisodeDataSource sharedDataSource] load];
    self.mpvc = [[MMMoviePlayerViewController alloc] init];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
    
    return YES;
}

static NSString *_applicationDocumentsDirectory = nil;
+ (NSString *) applicationDocumentsDirectory
{
    if (!_applicationDocumentsDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _applicationDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    }
    return _applicationDocumentsDirectory;
}

@end
