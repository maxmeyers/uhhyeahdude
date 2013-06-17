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
@dynamic shortTitle;
@dynamic title;
@dynamic url;
@dynamic mediaId;
@dynamic playbackTime;
@dynamic mediaType;
@dynamic imageUrl;
@dynamic thumbUrl;

@synthesize playStatus, image, fileStatus;

+ (NSString *)parseClassName {
    return @"Media";
}

- (void) setObject:(id)object forKey:(NSString *)key {
    if ([key isEqualToString:@"url"]) {
        NSLog(@"url");
    }
    [super setObject:object forKey:key];
}

//- (void) setUrl:(NSString *)url
//{
//    dispatch_async(dispatch_queue_create("file_checker", NULL), ^{
//        NSString *path = [self localFilePath];
//        if (path) {
//            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//                self.fileStatus = Available;
//            } else {
//                self.fileStatus = NotAvailable;
//            }
//        }
//    });
//    
//    self.playbackTime = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@", PLAYBACK_TIME_KEY, self.fileName]];
//}

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

- (NSString *) fileExtension
{
    if ([self.mediaType isEqualToString:@"Episode"]) {
        return @"jpg";
    } else if ([self.mediaType isEqualToString:@"SethsCorner"]) {
        return @"png";
    }
    return @"";
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
