//
//  MMMediaDataSource.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <Parse/Parse.h>

@protocol MMMediaDataSourceListener <NSObject>

@required
- (void) startingUpdate;
- (void) mediaWasUpdated;

@end


@interface MMMediaDataSource : NSObject <UITableViewDataSource> {
    NSMutableArray *_listeners;
}

+ (MMMediaDataSource *) sharedDataSource;

- (void) registerForUpdates:(id<MMMediaDataSourceListener>)listener;
- (void) loadWithCachePolicy:(PFCachePolicy)policy;
- (void) search:(NSString *) text;

@property NSArray *episodes;
@property NSArray *videos;
@property NSMutableArray *searchEpisodes;

@end