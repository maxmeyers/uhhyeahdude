//
//  MMMediaDataSource.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMMediaDataSource.h"
#import "Media.h"
#import "MMListTableViewCell.h"
#import "MMAppDelegate.h"
#import "MMMoviePlayerViewController.h"
#import "Reachability.h"
#import "Media.h"
#import <Parse/Parse.h>

@implementation MMMediaDataSource

static MMMediaDataSource *_sharedDataSource;

@synthesize episodes = _episodes;

+ (MMMediaDataSource *) sharedDataSource {
    if (_sharedDataSource == nil) {
        _sharedDataSource = [[MMMediaDataSource alloc] init];
    }
    return _sharedDataSource;
}

- (void) registerForUpdates:(id<MMMediaDataSourceListener>)listener
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
    for (id<MMMediaDataSourceListener>listener in _listeners) {
        [listener startingUpdate];
    }
}

- (void) updateListenersOfUpdate
{
    for (id<MMMediaDataSourceListener>listener in _listeners) {
        [listener mediaWasUpdated];
    }
}

- (void) loadWithCachePolicy:(PFCachePolicy)policy {
    if ([[Reachability reachabilityForInternetConnection] isReachable]) {
        [self updateListenersOfUpdateStart];
        return [self downloadListingsWithCachePolicy:policy];
    }
}

- (void) downloadListingsWithCachePolicy:(PFCachePolicy)policy
{
    PFQuery *query = [Media query];
    query.cachePolicy = policy;
    [query addDescendingOrder:@"date"];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *episodes = [NSMutableArray array];
        NSMutableArray *videos = [NSMutableArray array];
        for (Media *media in objects) {
            if ([media.mediaType isEqualToString:@"Episode"]) {
                [episodes addObject:media];
            } else if ([media.mediaType isEqualToString:@"SethsCorner"]) {
                [videos addObject:media];
            }
            [media checkStatus];
        }
        self.episodes = episodes;
        self.videos = videos;
        [self updateFileStatus];
        [self updateListenersOfUpdate];
    }];
    
}

- (void) updateFileStatus {
    
}

- (void) search:(NSString *)text
{
    if (!self.searchEpisodes) {
        self.searchEpisodes = [NSMutableArray array];
    }
    
    [self.searchEpisodes removeAllObjects];
    
    NSString *searchText = text;
    for (Media *episode in self.episodes) {
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
