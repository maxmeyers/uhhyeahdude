//
//  MMEpisodeTableViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/17/13.
//
//

#import "MMEpisodeTableViewController.h"
#import "MMListTableViewCell.h"
#import "Media.h"

@interface MMEpisodeTableViewController ()

@end

@implementation MMEpisodeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark -
#pragma  mark UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.searching ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && !self.searching) return 1;
    if (self.searching) {
        return SEARCH_EPISODES.count;
    } else {
        if (EPISODES) {
            return EPISODES.count;
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EpisodeCell";
    
    if (indexPath.section == 0 && !self.searching) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        return cell;
    }
    
    MMListTableViewCell *cell = (MMListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
    }
    
    Media *episode;
    if (self.searching) {
        episode = [SEARCH_EPISODES objectAtIndex:[indexPath row]];
    } else {
        episode = [EPISODES objectAtIndex:[indexPath row]];
    }
    
    if (episode) {
        cell.media = episode;
        NSString *title = [episode valueForKey:@"title"];
        [cell.titleLabel setText:title];
        int fontSize = 17;
        if ([episode componentLength] > 5) {
            fontSize = 13;
        }
        UIFont *font = [UIFont fontWithName:cell.titleLabel.font.fontName size:fontSize];
        cell.titleLabel.font = font;
        
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        cell.durationLabel.text = episode.duration;
        if (episode.playStatus == Started) {
            int secondsLeft = episode.durationInSeconds - episode.playbackTime;
            int minutesLeft = floor(secondsLeft/60);
            cell.timeLeftLabel.text = [NSString stringWithFormat:@"%dm left", minutesLeft];
        } else {
            cell.timeLeftLabel.text = nil;
        }
        
        [cell setImage];
    }
    
    return cell;
}

@end
