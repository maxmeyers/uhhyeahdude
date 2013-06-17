//
//  MMVideoListViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/2/12.
//
//

#import "MMVideoListViewController.h"
#import "Media.h"
#import "MMListTableViewCell.h"
#import "MMMediaViewController.h"
#import "MMMediaDataSource.h"

#define VIDEOS [[MMMediaDataSource sharedDataSource] videos]

@implementation MMVideoListViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VideoListToEpisodeView"]){
        MMMediaViewController *evc = [segue destinationViewController];
        evc.media = [sender media];
    }
}

- (void)viewDidLoad
{
    [[MMMediaDataSource sharedDataSource] registerForUpdates:self];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (void) startingUpdate {
    
}

- (void) mediaWasUpdated
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VIDEOS ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return (VIDEOS) ? [VIDEOS count] : 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0 : 10;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 0) ? 0 : 10;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 30;
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        MMListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        return cell;
    }
    
    static NSString *CellIdentifier = @"VideoCell";
    MMListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
    }
    
    Media *video = [VIDEOS objectAtIndex:indexPath.row];
    cell.media = video;
    
    cell.titleLabel.text = video.title;
    cell.durationLabel.text = video.duration;
    [cell setImage];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MMListTableViewCell *cell = [[MMListTableViewCell alloc] init];
    cell.media = [VIDEOS objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"VideoListToEpisodeView" sender:cell];
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

@end
