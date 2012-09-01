//
//  MMFirstViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodeListViewController.h"
#import "MMEpisodeViewController.h"
#import "MMEpisodeDataSource.h"
#import "MMOverlayViewController.h"
#import "ODRefreshControl.h"
#import "MMEpisodeTableViewCell.h"
#import "MMEpisode.h"
#import "MMMoviePlayerViewController.h"
#import "MMAppDelegate.h"
#import "MMNavigationViewController.h"

@implementation MMEpisodeListViewController
@synthesize searchBar;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EpisodeListToEpisodeView"]){
        MMEpisodeViewController *evc = [segue destinationViewController];
        evc.episode = [sender episode];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = [MMEpisodeDataSource sharedDataSource];
    [[MMEpisodeDataSource sharedDataSource] registerForUpdates:self];
    if (NSClassFromString(@"UIRefreshControl")) {
        self.refreshControl = [UIRefreshControl new];
        self.theRefreshControl = self.refreshControl;
    } else {
        self.theRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    }
    [self.theRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.nowPlayingButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) episodesWereUpdated
{
    [self.tableView reloadData];
    if (self.refreshing) {
        self.refreshing = NO;
        [self.theRefreshControl performSelector:@selector(endRefreshing)];
    }
}

- (void) refresh
{
    self.refreshing = YES;
    [[MMEpisodeDataSource sharedDataSource] load];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MPVC episode]) {
        self.navigationItem.rightBarButtonItem = self.nowPlayingButton;        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
#pragma mark UITableViewDelegate Methods

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"boom");
//}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if([(MMEpisodeDataSource *)self.tableView.dataSource searching]) {
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
	
    [(MMEpisodeDataSource *)self.tableView.dataSource setSearching:YES];
    [(MMEpisodeDataSource *)self.tableView.dataSource setLetUserSelectRow:NO];
	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(doneSearching)];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {	
	if ([searchText length] > 0) {
		[ovController.view removeFromSuperview];
        [(MMEpisodeDataSource *)self.tableView.dataSource setSearching:YES];
        [(MMEpisodeDataSource *)self.tableView.dataSource setLetUserSelectRow:YES];
		self.tableView.scrollEnabled = YES;
        [(MMEpisodeDataSource *)self.tableView.dataSource search:searchText];
	} else {
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
        [(MMEpisodeDataSource *)self.tableView.dataSource setSearching:NO];
        [(MMEpisodeDataSource *)self.tableView.dataSource setLetUserSelectRow:NO];
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{	
    [(MMEpisodeDataSource *)self.tableView.dataSource search:theSearchBar.text];
}

- (void) doneSearching {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
    [(MMEpisodeDataSource *)self.tableView.dataSource setLetUserSelectRow:YES];
    [(MMEpisodeDataSource *)self.tableView.dataSource setSearching:NO];
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	ovController = nil;
	
	[self.tableView reloadData];
}


- (IBAction)nowPlayingAction:(id)sender {
    [self.navigationController pushViewController:MPVC animated:YES];
}
@end
