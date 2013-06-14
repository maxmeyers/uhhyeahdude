//
//  MMVideoDataSource.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/2/12.
//
//

#import "MMVideoDataSource.h"
#import "SBJson.h"
#import "AFNetworking.h"
#import "MMMedia.h"
#import "MMVideoSection.h"
#import "MMAppDelegate.h"

@implementation MMVideoDataSource

static MMVideoDataSource *_sharedDataSource;

+ (MMVideoDataSource *) sharedDataSource {
    if (_sharedDataSource == nil) {
        _sharedDataSource = [[MMVideoDataSource alloc] init];
    }
    return _sharedDataSource;
}

- (void) registerForUpdates:(id<MMVideoDataSourceListener>)listener
{
    if (!_listeners) {
        _listeners = [NSMutableArray array];
    }
    if ([_listeners indexOfObject:listener] == NSNotFound) {
        [_listeners addObject:listener];
    }
}

- (void) updateListenersOfUpdate
{
    for (id<MMVideoDataSourceListener>listener in _listeners) {
        [listener videosUpdated];
    }
}

- (void) load
{
    [NSThread detachNewThreadSelector:@selector(downloadAndProcessListings) toTarget:self withObject:nil];
}

- (void) downloadAndProcessListings
{
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MEDIA_JSON_URL]]];
    __weak AFHTTPRequestOperation *blockOp = op;
    [op setCompletionBlock:^{
        NSString *jsonResponse = [blockOp responseString];
        NSDictionary *dict = [jsonResponse JSONValue];
        if ([dict objectForKey:@"sections"]) {
            NSMutableArray *tempSections = [NSMutableArray array];
            for (NSDictionary *sectionDict in [dict objectForKey:@"sections"]) {
                MMVideoSection *section = [[MMVideoSection alloc] init];
                
                [section setTitle:[sectionDict objectForKey:@"title"]];
                
                NSMutableArray *tempItems = [NSMutableArray array];
                for (NSDictionary *itemDict in [sectionDict objectForKey:@"items"]) {
                    MMMedia *item = [[MMMedia alloc] init];
                    [item setMediaType:SethsCorner];
                    [item setTitle:[itemDict objectForKey:@"title"]];
                    [item setUrl:[itemDict objectForKey:@"url"]];
                    [item setDuration:[itemDict objectForKey:@"duration"]];
                    [tempItems addObject:item];
                }
                [section setItems:[NSArray arrayWithArray:tempItems]];
                [tempSections addObject:section];
            }
            self.sections = [NSArray arrayWithArray:tempSections];
            [NSKeyedArchiver archiveRootObject:self.sections toFile:VIDEOS_BIN];
#ifdef TARGET_IPHONE_SIMULATOR
            [NSKeyedArchiver archiveRootObject:self.sections toFile:@"/Users/maxmeyers/Desktop/videos.bin"];
#endif
        }
        [self performSelectorOnMainThread:@selector(updateListenersOfUpdate) withObject:nil waitUntilDone:NO];
    }];
    [op start];
}

@end
