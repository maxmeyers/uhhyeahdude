//
//  Media.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/15/13.
//
//

#import "Media.h"
#import "MMAppDelegate.h"
#import <Parse/PFObject+Subclass.h>

@implementation Media

@dynamic date;
@dynamic desc;
@dynamic duration;
@dynamic title;
@dynamic url;
@dynamic mediaId;
@dynamic playbackTime;
@dynamic mediaType;
@dynamic imageUrl;
@dynamic thumbUrl;
@dynamic notes;
@dynamic links;

@synthesize playStatus, image;

+ (NSString *)parseClassName {
    return @"Media";
}

- (void) checkStatus
{
    self.playbackTime = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@", PLAYBACK_TIME_KEY, self.fileName]];
}

- (int) componentLength
{
    if (self.title) {
        int count = 0;
        for (NSString *component in [self.title componentsSeparatedByString:@" "]) {
            if (![component isEqualToString:@" "] && ![component isEqualToString:@""]) {
                count++;
            }
        }
        return count;
    }
    return 0;
}

- (int) durationInSeconds
{
    if (self.duration) {
        int seconds = 0;
        NSArray *timeBlock = [self.duration componentsSeparatedByString:@":"];
        for (int i = 0; i < timeBlock.count; i++) {
            int time = [[timeBlock objectAtIndex:i] intValue];
            if (timeBlock.count == 3) {
                if (i == 0) {
                    seconds += time * 60 * 60;
                } else if (i == 1) {
                    seconds += time * 60;
                } else {
                    seconds += time;
                }
            } else if (timeBlock.count == 2) {
                if (i == 0) {
                    seconds += time * 60;
                } else {
                    seconds += time;
                }
            }
        }
        return seconds;
    }
    return 0;
}

- (NSString *) fileName
{
    return [self.url lastPathComponent];
}

- (NSString *) imageName
{
    return [self.imageUrl lastPathComponent];
}

- (NSString *) localFilePath
{
    return [NSString stringWithFormat:@"%@/%@", MEDIA_DIRECTORY, [self.url lastPathComponent]];
}

- (NSString *) localThumbnailFilePath
{
    return [NSString stringWithFormat:@"%@/thumbs/%@", IMAGES_DIRECTORY, [self imageName]];
}

- (NSString *) localImageFilePath
{
    return [NSString stringWithFormat:@"%@/%@", IMAGES_DIRECTORY, [self imageName]];
}

@end
