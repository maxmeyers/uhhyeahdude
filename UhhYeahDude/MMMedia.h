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

enum MMMediaType {
    Episode,
    SethsCorner
};

@interface MMMedia : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *shortTitle;
@property (nonatomic, strong) NSString *epDescription;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) enum MMFileStatus fileStatus;
@property (nonatomic) enum MMMediaType mediaType;

- (void) setProperty:(NSString *) property andValue:(id)value;
- (int) componentLength;
- (NSString *) imageName;
- (NSString *) fileName;
- (NSString *) localFilePath;
- (NSString *) localImageFilePath;
- (NSString *) remoteImageFilePath;

@end
