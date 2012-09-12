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

#define EPISODE_PUSH_TAG @"Episodes"
#define SETH_PUSH_TAG @"SethsCorner"
#define LIVE_PUSH_TAG @"LiveShows"

#define APP_DELEGATE (MMAppDelegate *)[[UIApplication sharedApplication] delegate]
#define MPVC [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] mpvc]

#define EPISODES_BIN [NSString stringWithFormat:@"%@/episodes.bin", [MMAppDelegate applicationDocumentsDirectory]]
#define VIDEOS_BIN [NSString stringWithFormat:@"%@/videos.bin", [MMAppDelegate applicationDocumentsDirectory]]
#define IMAGES_DIRECTORY [NSString stringWithFormat:@"%@/images%@", [MMAppDelegate applicationDocumentsDirectory], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]]
#define MEDIA_DIRECTORY [NSString stringWithFormat:@"%@/media", [MMAppDelegate applicationDocumentsDirectory]]
#define EPISODE_SETH_DIRECTORY [NSString stringWithFormat:@"%@/images/seth", [MMAppDelegate applicationDocumentsDirectory]]

@class MMMoviePlayerViewController;

@interface MMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) MMMoviePlayerViewController *mpvc;
@property UIBarButtonItem *nowPlayingButton;
@property (strong, nonatomic) NSArray *pushTags;

+ (NSString *) applicationDocumentsDirectory;

@end