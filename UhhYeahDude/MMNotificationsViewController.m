//
//  MMNotificationsViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/11/12.
//
//

#import "MMNotificationsViewController.h"
#import "MMAppDelegate.h"
#import "Reachability.h"

@interface MMNotificationsViewController ()

@end

@implementation MMNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PUSH_ENABLED_KEY]) {
        for (NSString *pushTag in [APP_DELEGATE pushTags]) {
            if ([pushTag isEqualToString:EPISODE_TAG]) {
                [self.episodeSwitch setOn:YES animated:NO];
            } else if ([pushTag isEqualToString:SETH_TAG]) {
                [self.sethsCornerSwitch setOn:YES animated:NO];
            } else if ([pushTag isEqualToString:LIVE_PUSH_TAG]) {
                [self.showSwitch setOn:YES animated:NO];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet connection" message:@"To change notification settings, you must have an Internet connection." delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles:nil];
        [alertView show];
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:PUSH_ENABLED_KEY]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An unknown error occured" message:@"Please try again later." delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles:nil];
        [alertView show];
    } else if (!([[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notifications not enabled" message:@"Enable alerts or badges in Settings.app-> Notifications-> UhhYeahDude, then come back here!" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction) switchValueChanged:(UISwitch *)switchSender
{
    NSString *pushTag;
    // Episodes
    if ([switchSender tag] == 0) {
        pushTag = EPISODE_TAG;
    } else if ([switchSender tag] == 1) {
        pushTag = SETH_TAG;
    } else if ([switchSender tag] == 2) {
        pushTag = LIVE_PUSH_TAG;
    }
    NSMutableArray *newPushTags = [NSMutableArray arrayWithArray:[APP_DELEGATE pushTags]];
    if (pushTag) {
        if (switchSender.on) {
            if ([newPushTags indexOfObject:pushTag] == NSNotFound) {
                [newPushTags addObject:pushTag];
            }
        } else {
            [newPushTags removeObject:pushTag];
        }
    }
    [APP_DELEGATE setPushTags:newPushTags];
    
}


- (void)viewDidUnload {
    [self setEpisodeSwitch:nil];
    [self setSethsCornerSwitch:nil];
    [self setShowSwitch:nil];
    [super viewDidUnload];
}

@end
