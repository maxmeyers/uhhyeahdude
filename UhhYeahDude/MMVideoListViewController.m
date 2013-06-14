//
//  MMVideoListViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/2/12.
//
//

#import "MMVideoListViewController.h"
#import "MMVideoDataSource.h"
#import "MMVideoSection.h"
#import "MMMedia.h"
#import "MMListTableViewCell.h"
#import "MMMediaViewController.h"

#define SECTIONS [[MMVideoDataSource sharedDataSource] sections]
#define SECTION(X) [SECTIONS objectAtIndex:X]

@implementation MMVideoListViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VideoListToEpisodeView"]){
        MMMediaViewController *evc = [segue destinationViewController];
        evc.media = [sender media];
    }
}

- (void)viewDidLoad
{
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (void) videosUpdated
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTIONS ? [SECTIONS count] + 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return SECTION(section-1) ? [[(MMVideoSection *)SECTION(section-1) items] count] : 0;
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
    
    MMMedia *video = [[SECTION(indexPath.section-1) items] objectAtIndex:indexPath.row];
    cell.media = video;
    
    cell.titleLabel.text = video.title;
    cell.durationLabel.text = video.duration;
    [cell setImage];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MMListTableViewCell *cell = [[MMListTableViewCell alloc] init];
    cell.media = [[SECTION(indexPath.section-1) items] objectAtIndex:indexPath.row];
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
