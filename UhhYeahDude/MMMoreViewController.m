//
//  MMMoreViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/9/12.
//
//

#import "MMMoreViewController.h"
#import "Appirater.h"

@interface MMMoreViewController ()

@end

@implementation MMMoreViewController


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

@end
