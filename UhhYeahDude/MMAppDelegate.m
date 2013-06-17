//
//  MMAppDelegate.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAppDelegate.h"
#import "MMMediaDataSource.h"
#import <AVFoundation/AVFoundation.h>
#import "MMMoviePlayerViewController.h"
#import "UAirship.h"
#import "UAPush.h"
#import "Appirater.h"
#import "Media.h"

#import <Parse/Parse.h>

@implementation MMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
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
        self.pushTags = [NSArray arrayWithObject:EPISODE_TAG];
        [[NSUserDefaults standardUserDefaults] setObject:self.pushTags forKey:PUSH_TAGS_KEY];
    }
    
    [Appirater setAppId:@"498175623"];
    
    [Media registerSubclass];
    [Parse setApplicationId:@"8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0"
                  clientKey:@"TtUjkvcLTzjMIwwS2MiPJMNy7A0RJBF5SeDnvDwJ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Override point for customization after application launch.
    [[MMMediaDataSource sharedDataSource] loadWithCachePolicy:kPFCachePolicyCacheThenNetwork];
    
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
    [[MMMediaDataSource sharedDataSource] loadWithCachePolicy:kPFCachePolicyCacheThenNetwork];
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


@end
