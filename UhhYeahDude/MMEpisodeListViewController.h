//
//  MMFirstViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMediaDataSource.h"

#define EPISODES [[MMMediaDataSource sharedDataSource] episodes]
#define SEARCH_EPISODES [[MMMediaDataSource sharedDataSource] searchEpisodes]

@class MMOverlayViewController;

@interface MMEpisodeListViewController : UIViewController <UISearchBarDelegate, MMMediaDataSourceListener> {
    MMOverlayViewController *ovController;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;

- (IBAction)nowPlayingAction:(id)sender;

@property BOOL loading;
@property BOOL searching;
@property BOOL refreshing;

@property NSManagedObjectContext *context;
@property NSArray *objects;

@end
