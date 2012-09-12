//
//  MMFilesViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/11/12.
//
//

#import <UIKit/UIKit.h>

@interface MMFilesViewController : UITableViewController

@property NSArray *episodes;
@property NSArray *videos;

@property NSDictionary *fileSizes;

@property NSMutableArray *recentlyEmptied;

@end
