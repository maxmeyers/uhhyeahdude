//
//  MMAppDelegate.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PUSH_ENABLED_KEY @"PushEnabled"
#define PUSH_TAGS_KEY @"PushTags"

#define EPISODE_TAG @"Episodes"
#define SETH_TAG @"SethsCorner"
#define LIVE_PUSH_TAG @"LiveShows"

#define APP_DELEGATE (MMAppDelegate *)[[UIApplication sharedApplication] delegate]
#define MPVC [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] mpvc]

#define IMAGES_DIRECTORY [NSString stringWithFormat:@"%@/images", [MMAppDelegate applicationDocumentsDirectory]]
#define MEDIA_DIRECTORY [NSString stringWithFormat:@"%@/media", [MMAppDelegate applicationDocumentsDirectory]]

#define LAST_UPDATE_KEY @"LastUpdateKey"

@class MMMoviePlayerViewController, Media;

@interface MMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) MMMoviePlayerViewController *mpvc;
@property UIBarButtonItem *nowPlayingButton;
@property Media *nowPlaying;
@property (strong, nonatomic) NSArray *pushTags;

@property NSMutableArray *downloads;


+ (NSString *) applicationDocumentsDirectory;

@end