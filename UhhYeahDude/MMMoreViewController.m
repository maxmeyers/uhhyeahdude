//
//  MMMoreViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/9/12.
//
//

#import "MMMoreViewController.h"
#import "Appirater.h"

@implementation MMMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ForumSegue"]) {
        UIViewController *vc = [segue destinationViewController];
        for (UIView *subview in vc.view.subviews) {
            if ([subview class] == [UIWebView class]) {
                [(UIWebView *)subview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://uhhyeahdude.com"]]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://+1-888-842-2357"]];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"To leave a voicemail..." message:@"Call (888) 842-2357." delegate:nil cancelButtonTitle:@"Okay!" otherButtonTitles:nil];
                [alertView show];
            }
        } else if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://uhhyeahdude.com/forums/"]];            
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/podcast/uhh-yeah-dude/id124043755"]];
        } else if (indexPath.row == 1) {
            [Appirater rateApp];
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
