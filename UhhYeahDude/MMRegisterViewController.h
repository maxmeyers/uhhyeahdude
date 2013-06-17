//
//  MMRegisterViewController.h
//  UhhYeahDude
//
//  Created by Max Meyers on 6/14/13.
//
//

#import <UIKit/UIKit.h>

@interface MMRegisterViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@end
