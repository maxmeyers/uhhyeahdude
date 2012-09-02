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
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (void) videosUpdated
{
    [self.tableView reloadData];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [SECTION(section) title] ? [SECTION(section) title] : @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTIONS ? [SECTIONS count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SECTION(section) ? [[(MMVideoSection *)SECTION(section) items] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoCell";
    MMListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MMMedia *video = [[SECTION(indexPath.section) items] objectAtIndex:indexPath.row];
    cell.media = video;
    
    cell.titleLabel.text = video.title;
    [cell setImage];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MMListTableViewCell *cell = [[MMListTableViewCell alloc] init];
    cell.media = [[SECTION(indexPath.section) items] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"VideoListToEpisodeView" sender:cell];
}

@end
