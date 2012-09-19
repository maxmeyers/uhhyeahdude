//
//  MMEpisode.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

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

enum MMMediaType {
    Episode,
    SethsCorner
};

#define PLAYBACK_TIME_KEY @"PLAYBACK_TIME_"

@interface MMMedia : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *shortTitle;
@property (nonatomic, strong) NSString *epDescription;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) int playbackTime;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) enum MMFileStatus fileStatus;
@property (nonatomic) enum MMPlayStatus playStatus;
@property (nonatomic) enum MMMediaType mediaType;

- (void) setProperty:(NSString *) property andValue:(id)value;
- (int) componentLength;
- (int) durationInSeconds;
- (NSString *) imageName;
- (NSString *) fileName;
- (NSString *) localFilePath;

- (NSString *) localThumbnailFilePath;
- (NSString *) localImageFilePath;
- (NSString *) remoteThumbnailFilePath;
- (NSString *) remoteImageFilePath;

@end
