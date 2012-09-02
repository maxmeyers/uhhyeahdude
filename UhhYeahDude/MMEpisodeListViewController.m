//
//  MMFirstViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMEpisodeListViewController.h"
#import "MMMediaViewController.h"
#import "MMEpisodeDataSource.h"
#import "MMOverlayViewController.h"
#import "ODRefreshControl.h"
#import "MMListTableViewCell.h"
#import "MMMedia.h"
#import "MMMoviePlayerViewController.h"
#import "MMAppDelegate.h"
#import "UIImageView+WebCache.h"

#define EPISODES [[MMEpisodeDataSource sharedDataSource] episodes]
#define SEARCH_EPISODES [[MMEpisodeDataSource sharedDataSource] searchEpisodes]

@implementation MMEpisodeListViewController
@synthesize searchBar;

#pragma mark - View lifecycle

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EpisodeListToEpisodeView"]){
        MMMediaViewController *evc = [segue destinationViewController];
        evc.media = [sender media];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[MMEpisodeDataSource sharedDataSource] registerForUpdates:self];
//    if (NSClassFromString(@"UIRefreshControl")) {
//        self.refreshControl = [UIRefreshControl new];
//        self.theRefreshControl = self.refreshControl;
//    } else {
//        self.theRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
//    }
//    [self.theRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.nowPlayingButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -
#pragma mark MMEpisodeDataSourceListener methods

- (void) startingUpdate
{
    self.loading = YES;
}

- (void) episodesWereUpdated
{
    [self.tableView reloadData];
    self.loading = NO;
    if (self.refreshing) {
        self.refreshing = NO;
        [self.theRefreshControl performSelector:@selector(endRefreshing)];
    }
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
        [[MMEpisodeDataSource sharedDataSource] search:searchText];
	} else {
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
        self.searching = NO;
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
	
    self.searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	ovController = nil;
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark actions

- (IBAction) refresh:(id) sender
{
    self.refreshing = YES;
    [[MMEpisodeDataSource sharedDataSource] load];
}

- (IBAction)nowPlayingAction:(id)sender
{
    [self.navigationController pushViewController:MPVC animated:YES];
}

#pragma  mark -
#pragma  mark UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searching) {
        return SEARCH_EPISODES.count;
    } else {
        return (EPISODES) ? EPISODES.count : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EpisodeCell";
        
    MMListTableViewCell *cell = (MMListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    MMMedia *episode;
    
    if (self.searching) {
        episode = [SEARCH_EPISODES objectAtIndex:[indexPath row]];
    } else {
        episode = [EPISODES objectAtIndex:[indexPath row]];
    }
    
    if (episode) {
        cell.media = episode;
        [cell.titleLabel setText:episode.title];
        int fontSize = 17;
        if ([episode componentLength] > 5) {
            fontSize = 13;
        }
        UIFont *font = [UIFont fontWithName:cell.titleLabel.font.fontName size:fontSize];
        cell.titleLabel.font = font;
        
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        [cell.durationLabel setText:episode.duration];
        
        [cell setImage];
    }
    
    return cell;
}

@end
