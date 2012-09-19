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
#import "UAirship.h"
#import "UAPush.h"
#import "Appirater.h"
#import "SBJson.h"
#import "AFURLConnectionOperation.h"

@implementation MMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:IMAGES_JSON]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"images" ofType:@"json"] toPath:IMAGES_JSON error:nil];
    }
    self.imageMap = [[NSData dataWithContentsOfFile:IMAGES_JSON] JSONValue];
    [self updateImageMap];
    
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:MEDIA_DIRECTORY]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:MEDIA_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error];
    }

    self.pushTags = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TAGS_KEY];
    if (!self.pushTags) {
        self.pushTags = [NSArray arrayWithObject:EPISODE_PUSH_TAG];
        [[NSUserDefaults standardUserDefaults] setObject:self.pushTags forKey:PUSH_TAGS_KEY];
    }
    
    [Appirater setAppId:@"498175623"];
    
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
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PUSH_ENABLED_KEY];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Couldn't register");
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
    [[UAPush shared]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    [[MMEpisodeDataSource sharedDataSource] load];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [UAirship land];
}

- (void) setPushTags:(NSArray *)pushTags
{
    _pushTags = pushTags;
    if (pushTags) {
        [[NSUserDefaults standardUserDefaults] setObject:pushTags forKey:PUSH_TAGS_KEY];
        [[UAPush shared] setTags:_pushTags];
        [[UAPush shared]
         registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                             UIRemoteNotificationTypeSound |
                                             UIRemoteNotificationTypeAlert)];
    }
}

- (NSString *) urlForFileName:(NSString *)filename ofType:(NSString *)type {
    NSDictionary *map = [self.imageMap objectForKey:type];
    if (map) {
        NSString *url = [map objectForKey:filename];
        if (url) {
            return [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        }
    }
    return nil;
}

- (NSString *) thumbForFilename:(NSString *)filename {
    return [self urlForFileName:filename ofType:@"thumbs"];
}

- (NSString *) imageForFilename:(NSString *)filename {
    return [self urlForFileName:filename ofType:@"images"];
}

- (void) updateImageMap {
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/uhhyeahdude/images.json"]]];
    [operation setCompletionBlock:^{
        @try {
            self.imageMap = [operation.responseString JSONValue];
        }
        @catch (NSException *exception) {
            NSLog(@"Image Map Update Failed");
        }
    }];
    [operation start];
}



@end
