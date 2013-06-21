//
//  MMFirstViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodeListViewController.h"
#import "MMEpisodeViewController.h"
#import "MMMediaDataSource.h"
#import "MMOverlayViewController.h"
#import "MMListTableViewCell.h"
#import "MMMoviePlayerViewController.h"
#import "MMAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "Media.h"

@implementation MMEpisodeListViewController
@synthesize searchBar;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [[MMMediaDataSource sharedDataSource] registerForUpdates:self];
    self.nowPlayingButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    
    [super viewDidLoad];
}

- (UITableView*) tableView {
    return (UITableView*)self.view;
}

#pragma mark -
#pragma mark MMMediaDataSourceListener methods

- (void) startingUpdate
{

}

- (void) mediaWasUpdated
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View Cycle

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MPVC media]) {
        self.navigationItem.rightBarButtonItem = self.nowPlayingButton;        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(self.searching) {
        return;    
    }
	
	//Add the overlay view.
    if (!ovController) {
        ovController = [MMOverlayViewController new];        
    }
    
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
	ovController.overlayedViewController = self;
	
	[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
    self.searching = YES;
	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(doneSearching)];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {	
	if ([searchText length] > 0) {
		[ovController.view removeFromSuperview];
        self.searching = YES;
		self.tableView.scrollEnabled = YES;
        [[MMMediaDataSource sharedDataSource] search:searchText];
	} else {
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
        self.searching = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{	
    [(MMMediaDataSource *)self.tableView.dataSource search:theSearchBar.text];
}

- (void) doneSearching {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
    self.searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	ovController = nil;
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark actions

- (IBAction)nowPlayingAction:(id)sender
{
    [self.navigationController pushViewController:MPVC animated:YES];
}

@end
