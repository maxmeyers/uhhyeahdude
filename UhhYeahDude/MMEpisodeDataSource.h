//
//  MMEpisodeDataSource.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <Foundation/Foundation.h>

@protocol MMEpisodeDataSourceListener <NSObject>

- (void) episodesWereUpdated;

@end


@interface MMEpisodeDataSource : NSObject <UITableViewDataSource> {
    NSMutableArray *_listeners;
}

+ (MMEpisodeDataSource *) sharedDataSource;
- (void) registerForUpdates:(id<MMEpisodeDataSourceListener>)listener;
- (void) updateListeners;

- (void) load;
- (void) search:(NSString *) text;


@property (nonatomic) NSArray *episodes;
@property NSMutableArray *searchEpisodes;
@property BOOL letUserSelectRow;
@property BOOL searching;

@end