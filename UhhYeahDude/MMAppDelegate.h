//
//  MMAppDelegate.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_DELEGATE (MMAppDelegate *)[[UIApplication sharedApplication] delegate]
#define MPVC [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] mpvc]

@class MMMoviePlayerViewController;

@interface MMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) MMMoviePlayerViewController *mpvc;
@property UIBarButtonItem *nowPlayingButton;

+ (NSString *) applicationDocumentsDirectory;

@end