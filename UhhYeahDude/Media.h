//
//  Media.h
//  UhhYeahDude
//
//  Created by Max Meyers on 6/15/13.
//
//

#import <Foundation/Foundation.h>
#import "Media.h"
#import <Parse/Parse.h>

enum MMFileStatus {
    NotChecked,
    NotAvailable,
    Available
};

enum MMPlayStatus {
    NotStarted,
    Started,
    Finished
};

#define PLAYBACK_TIME_KEY @"PLAYBACK_TIME_"

@interface Media : PFObject<PFSubclassing>

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * mediaId;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * thumbUrl;

@property (nonatomic) int16_t playbackTime;
@property (nonatomic) enum MMPlayStatus playStatus;

@property UIImage *image;

- (int) componentLength;
- (int) durationInSeconds;

- (NSString *) imageName;
- (NSString *) fileName;
- (NSString *) localFilePath;

- (void) checkStatus;

- (NSString *) localThumbnailFilePath;
- (NSString *) localImageFilePath;

@end
