//
//  MMFirstViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEpisodeDataSource.h"

@class MMOverlayViewController, ODRefreshControl;

@interface MMEpisodeListViewController : UITableViewController <UITableViewDelegate, UISearchBarDelegate, MMEpisodeDataSourceListener> {
    MMOverlayViewController *ovController;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;
@property (strong, nonatomic) UIControl *theRefreshControl;
@property BOOL refreshing;
- (IBAction)nowPlayingAction:(id)sender;

@end
