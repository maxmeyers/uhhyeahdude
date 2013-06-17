//
//  MMFirstViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMediaDataSource.h"

@class MMOverlayViewController;

@interface MMEpisodeListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MMMediaDataSourceListener> {
    MMOverlayViewController *ovController;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;
@property (strong, nonatomic) UIControl *theRefreshControl;

- (IBAction)nowPlayingAction:(id)sender;
- (IBAction)refresh:(id)sender;

@property BOOL loading;
@property BOOL searching;
@property BOOL refreshing;

@property NSManagedObjectContext *context;
@property NSArray *objects;

@end
