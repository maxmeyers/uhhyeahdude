//
//  MMEpisodeDataSource.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

@protocol MMEpisodeDataSourceListener <NSObject>

@required
- (void) startingUpdate;
- (void) episodesWereUpdated;

@end


@interface MMEpisodeDataSource : NSObject <UITableViewDataSource> {
    NSMutableArray *_listeners;
}

+ (MMEpisodeDataSource *) sharedDataSource;
- (void) registerForUpdates:(id<MMEpisodeDataSourceListener>)listener;

- (void) load;
- (void) search:(NSString *) text;

- (void) updateEpisodes:(NSArray *)newEpisodes;

@property (nonatomic) NSArray *episodes;
@property NSMutableArray *searchEpisodes;

@end