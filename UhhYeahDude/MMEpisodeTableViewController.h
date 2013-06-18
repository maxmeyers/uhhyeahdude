//
//  MMEpisodeTableViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 6/17/13.
//
//

#import "MMEpisodeListViewController.h"

@interface MMEpisodeTableViewController : MMEpisodeListViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)nowPlayingAction:(id)sender;

@end
