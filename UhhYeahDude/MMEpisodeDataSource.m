//
//  MMEpisodeDataSource.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMEpisodeDataSource.h"
#import "MMEpisode.h"
#import "MMEpisodeTableViewCell.h"
#import "MMEpisodeXMLParserDelegate.h"
#import "UIImageView+WebCache.h"

@implementation MMEpisodeDataSource

static MMEpisodeDataSource *_sharedDataSource;

@synthesize episodes = _episodes;

+ (MMEpisodeDataSource *) sharedDataSource {
    if (_sharedDataSource == nil) {
        _sharedDataSource = [[MMEpisodeDataSource alloc] init];
    }
    return _sharedDataSource;
}

- (void) registerForUpdates:(id<MMEpisodeDataSourceListener>)listener
{
    if (!_listeners) {
        _listeners = [NSMutableArray array];
    }
    if ([_listeners indexOfObject:listener] == NSNotFound) {
        [_listeners addObject:listener];
    }
}

- (void) updateListeners
{
    for (id<MMEpisodeDataSourceListener>listener in _listeners) {
        [listener episodesWereUpdated];
    }
}

- (void) setEpisodes:(NSArray *)episodes {
    _episodes = episodes;
    [self updateListeners];
}

- (void) load
{
    [NSThread detachNewThreadSelector:@selector(downloadListings) toTarget:self withObject:nil];
}

- (void) downloadListings
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://feeds.feedburner.com/uhhyeahdude/podcast"]];
    MMEpisodeXMLParserDelegate *delegate = [[MMEpisodeXMLParserDelegate alloc] init];
    [parser setDelegate:delegate];
    
    if (![parser parse]) {
        [[MMEpisodeDataSource sharedDataSource] setEpisodes:[NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/maxmeyers/Desktop/temp.bin"]];
    }
    
    [self performSelectorOnMainThread:@selector(updateListeners) withObject:nil waitUntilDone:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searching) {
        return self.searchEpisodes.count;
    } else {
        return (self.episodes) ? self.episodes.count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EpisodeCell";
    static NSString *loadingCellIdentifier = @"LoadingCell";
    
    NSString *cellId = cellIdentifier;
    if (!self.episodes) {
        cellId = loadingCellIdentifier;
    }
    
    MMEpisodeTableViewCell *cell = (MMEpisodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    MMEpisode *episode;
    if (self.searching) {
        episode = [self.searchEpisodes objectAtIndex:[indexPath row]];
    } else {
        episode = [self.episodes objectAtIndex:[indexPath row]];
    }
    
    if (episode) {
        cell.episode = episode;
        [cell.titleLabel setText:episode.title];
        int fontSize = 17;
        if ([episode componentLength] > 5) {
            fontSize = 13;
        }
        UIFont *font = [UIFont fontWithName:cell.titleLabel.font.fontName size:fontSize];
        cell.titleLabel.font = font;
        
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        [cell.durationLabel setText:episode.duration];
        
        cell.episodeImageView = [[UIImageView alloc] initWithFrame:cell.episodeImageView.bounds];
        UIImage *placeHolder = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"png"]];
        if (episode.image) {
            cell.episodeImageView.image = episode.image;
        } else {
            if (episode.localImageFilePathInBundle) {
                [cell.episodeImageView setImageWithURL:[NSURL fileURLWithPath:episode.localImageFilePathInBundle]  success:^(UIImage *image) {
                    episode.image = image;
                } failure:nil];
            }
        }
    }

    return cell;
}

- (void) search:(NSString *)text
{
    if (!self.searchEpisodes) {
        self.searchEpisodes = [NSMutableArray array];
    }
    
    [self.searchEpisodes removeAllObjects];
    
    NSString *searchText = text;
    for (MMEpisode *episode in self.episodes) {
        BOOL containsAll = YES;
        for (NSString *component in [searchText componentsSeparatedByString:@" "]) {
            if (episode.title) {
                NSRange titleResultsRange = [episode.title rangeOfString:component options:NSCaseInsensitiveSearch];
                
                if (titleResultsRange.length == 0) {
                    containsAll = NO;
                }
            }
        }
        if (containsAll) {
            [self.searchEpisodes addObject:episode];
        }
    }
}

@end
