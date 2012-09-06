//
//  MMAppDelegate.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAppDelegate.h"
#import "MMEpisodeDataSource.h"
#import "MMVideoDataSource.h"
#import <AVFoundation/AVFoundation.h>
#import "MMMoviePlayerViewController.h"

@implementation MMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:EPISODES_BIN]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"episodes" ofType:@"bin"] toPath:EPISODES_BIN error:nil];
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:VIDEOS_BIN]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"videos" ofType:@"bin"] toPath:VIDEOS_BIN error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:IMAGES_DIRECTORY]) {
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/images/", [[NSBundle mainBundle] resourcePath]] toPath:IMAGES_DIRECTORY error:&error];
    }
    
    // Override point for customization after application launch.
    [[MMEpisodeDataSource sharedDataSource] setEpisodes:[NSKeyedUnarchiver unarchiveObjectWithFile:EPISODES_BIN]];
    [[MMEpisodeDataSource sharedDataSource] load];
    
    [[MMVideoDataSource sharedDataSource] setSections:[NSKeyedUnarchiver unarchiveObjectWithFile:VIDEOS_BIN]];
    [[MMVideoDataSource sharedDataSource] load];
    
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

-(void) applicationWillEnterForeground:(UIApplication *)application
{
    [[MMEpisodeDataSource sharedDataSource] load];
}

@end
