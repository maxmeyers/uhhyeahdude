//
//  MMRegisterViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/14/13.
//
//

#import "MMRegisterViewController.h"
#import "MMAppDelegate.h"

@interface MMRegisterViewController ()

@end

@implementation MMRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (MMAppDelegate *)appDelegate {
    return (MMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
}

/*
 The textFieldShouldReturn: method will get called and dismiss the soft keyboard when the user presses the return button.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
