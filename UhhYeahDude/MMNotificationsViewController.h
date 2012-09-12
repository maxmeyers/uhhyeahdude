//
//  MMNotificationsViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/11/12.
//
//

#import <UIKit/UIKit.h>

@interface MMNotificationsViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *episodeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *sethsCornerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *showSwitch;

- (IBAction) switchValueChanged:(UISwitch *)switchSender;

@end
