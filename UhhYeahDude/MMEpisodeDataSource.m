//
//  MMEpisodeDataSource.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMEpisodeDataSource.h"
#import "MMMedia.h"
#import "MMListTableViewCell.h"
#import "MMEpisodeXMLParserDelegate.h"
#import "MMAppDelegate.h"
#import "MMMoviePlayerViewController.h"

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

- (void) updateListenersOfUpdateStart
{
    for (id<MMEpisodeDataSourceListener>listener in _listeners) {
        [listener startingUpdate];
    }
}

- (void) updateListenersOfUpdate
{
    for (id<MMEpisodeDataSourceListener>listener in _listeners) {
        [listener episodesWereUpdated];
    }
}

- (void) setEpisodes:(NSArray *)episodes {
    _episodes = episodes;
    [self updateListenersOfUpdate];
}

- (void) load
{
    [self updateListenersOfUpdateStart];
    [NSThread detachNewThreadSelector:@selector(downloadListings) toTarget:self withObject:nil];
}

- (void) downloadListings
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://feeds.feedburner.com/uhhyeahdude/podcast"]];
    MMEpisodeXMLParserDelegate *delegate = [[MMEpisodeXMLParserDelegate alloc] init];
    [parser setDelegate:delegate];
    [parser parse];
    [self performSelectorOnMainThread:@selector(updateListenersOfUpdate) withObject:nil waitUntilDone:NO];
}

- (void) search:(NSString *)text
{
    if (!self.searchEpisodes) {
        self.searchEpisodes = [NSMutableArray array];
    }
    
    [self.searchEpisodes removeAllObjects];
    
    NSString *searchText = text;
    for (MMMedia *episode in self.episodes) {
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
