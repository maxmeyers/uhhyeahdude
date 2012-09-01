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

@interface MMEpisode : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *shortTitle;
@property (nonatomic, strong) NSString *epDescription;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) enum MMFileStatus fileStatus;

- (void) setProperty:(NSString *) property andValue:(id)value;
- (int) componentLength;
- (NSString *) localFilePath;
- (NSString *) localImageFilePathInBundle;
- (NSString *) localImageFilePathInDocumentsWithExtension:(NSString *)extension;

@end
