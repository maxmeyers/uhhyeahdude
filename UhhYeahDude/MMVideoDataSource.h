//
//  MMVideoDataSource.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/2/12.
//
//

@protocol MMVideoDataSourceListener <NSObject>

@required
- (void) videosUpdated;

@end

@interface MMVideoDataSource : NSObject {
    NSMutableArray *_listeners;
}

@property NSArray *sections;

+ (MMVideoDataSource *) sharedDataSource;
- (void) registerForUpdates:(id<MMVideoDataSourceListener>)listener;
- (void) load;

@end
