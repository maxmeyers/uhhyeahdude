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
#import "Appirater.h"
#import "Media.h"
#import "AFNetworking/AFNetworking.h"

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

    
    [Appirater setAppId:@"498175623"];
    
    [Media registerSubclass];
    [Parse setApplicationId:@"8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0"
                  clientKey:@"TtUjkvcLTzjMIwwS2MiPJMNy7A0RJBF5SeDnvDwJ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.pushTags = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TAGS_KEY];
    if (!self.pushTags) {
        self.pushTags = [NSArray arrayWithObject:EPISODE_TAG];
        [[NSUserDefaults standardUserDefaults] setObject:self.pushTags forKey:PUSH_TAGS_KEY];
    }
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    PFCachePolicy initialPolicy = kPFCachePolicyCacheOnly;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:LAST_UPDATE_KEY] == 0) {
        initialPolicy = kPFCachePolicyNetworkOnly;
    }
    [[MMMediaDataSource sharedDataSource] loadWithCachePolicy:initialPolicy];
    
    AFURLConnectionOperation *op = [[AFURLConnectionOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://uhhyeahdude.s3.amazonaws.com/update"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100]];
    __weak AFURLConnectionOperation *weakOp = op;
    [op setCompletionBlock:^{
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *num = [nf numberFromString:weakOp.responseString];
        if (num) {
            NSInteger lastUpdate = num.integerValue;
            NSInteger previousLastUpdate = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_UPDATE_KEY];

            [[NSUserDefaults standardUserDefaults] setInteger:lastUpdate forKey:LAST_UPDATE_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (lastUpdate > previousLastUpdate
                && previousLastUpdate != 0) { // If it were 0, we already would have done network-only earlier
                NSLog(@"There has been an update!");
                [[MMMediaDataSource sharedDataSource] loadWithCachePolicy:kPFCachePolicyNetworkOnly];
            } else {
                NSLog(@"No update this time.");
            }
        }

    }];
    [op start];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
    
    

    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
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
    [[MMMediaDataSource sharedDataSource] loadWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

- (void) setPushTags:(NSArray *)pushTags
{
    _pushTags = pushTags;
    if (pushTags) {
        [[NSUserDefaults standardUserDefaults] setObject:pushTags forKey:PUSH_TAGS_KEY];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setChannels:_pushTags];
        [currentInstallation saveInBackground];
    }
}


@end
