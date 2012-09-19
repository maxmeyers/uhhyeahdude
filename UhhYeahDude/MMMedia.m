//
//  MMEpisode.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMMedia.h"
#import "MMAppDelegate.h"

@implementation MMMedia

static NSArray *Months;

- (id) init
{
    self = [super init];
    if (self) {
        self.fileStatus = NotChecked;
    }
    return self;
}

- (void) setProperty:(NSString *) property andValue:(NSString *)value
{
    if ([property isEqualToString:@"title"]) {
        self.title = [self parseTitle:value];
    } else if ([property isEqualToString:@"description"]) {
        self.epDescription = [self parseDescription:value];
    } else if ([property isEqualToString:@"pubDate"]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"E, dd MMM yyyy HH:mm:ss z"];
        self.date = [df dateFromString:value];
    } else if ([property isEqualToString:@"itunes:duration"]) {
        self.duration = value;
    } else if ([property isEqualToString:@"url"]) {
        self.url = value;
    }
}

- (void) setUrl:(NSString *)url
{
    _url = url;
    dispatch_async(dispatch_queue_create("file_checker", NULL), ^{
        NSString *path = [self localFilePath];
        if (path) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                self.fileStatus = Available;
            } else {
                self.fileStatus = NotAvailable;
            }
        }
    });
    
    self.playbackTime = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@", PLAYBACK_TIME_KEY, self.fileName]];
}

- (void) setPlaybackTime:(int)playbackTime
{
    _playbackTime = playbackTime;
    if (_playbackTime == 0) {
        self.playStatus = NotStarted;
    } else if (_playbackTime > self.durationInSeconds*0.95) {
        self.playStatus = Finished;
    } else {
        self.playStatus = Started;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:playbackTime forKey:[NSString stringWithFormat:@"%@_%@", PLAYBACK_TIME_KEY, self.fileName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) parseTitle:(NSString *)title
{
    if (Months == nil) {
        Months = [NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
    }
    NSArray *components = [title componentsSeparatedByString:@" "];
    NSMutableArray *newComponents = [NSMutableArray array];
    for (NSString *component in components) {
        BOOL hasMonth = NO;
        for (NSString *month in Months) {
            if ([component rangeOfString:month].location != NSNotFound) {
                self.shortTitle = [newComponents componentsJoinedByString:@" "];
                [newComponents addObject:[NSString stringWithFormat:@"\n%@", component]];
                hasMonth = YES;
                break;
            }
        }
        if (!hasMonth) {
            [newComponents addObject:component];
        }
    }
    return [newComponents componentsJoinedByString:@" "];
}

- (NSString *) parseDescription:(NSString *) description
{
    if (description) {
        int location = [description rangeOfString:@"<img"].location;
        if (location != NSNotFound) {
            return [description substringToIndex:location];
        }
    }
    return description;
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

- (NSString *) fileExtension
{
    switch (self.mediaType) {
        case Episode:
            return @"jpg";
        case SethsCorner:
            return @"png";
    }
    return @"";
}

- (NSString *) imageName
{
    return [NSString stringWithFormat:@"%@.jpg", [[self.fileName stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"]];
}

- (NSString *) fileName
{
    return [self.url lastPathComponent];
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

- (NSString *) remoteThumbnailFilePath
{
    NSString *url = [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] thumbForFilename:self.fileName];
    
    return url ? url : [NSString stringWithFormat:@"fail: %@", self.url];
//    return [NSString stringWithFormat:@"https://s3.amazonaws.com/uhhyeahdude/thumbs/%@", [self imageName]];
}

- (NSString *) remoteImageFilePath
{
    return [NSString stringWithFormat:@"https://s3.amazonaws.com/uhhyeahdude/%@", [self imageName]];
}

- (BOOL) isEqual:(id)object
{
    if ([object class] != [self class]) {
        return NO;
    }

    MMMedia *other = (MMMedia *)object;
    if ([self.title isEqual:other.title] && [self.url isEqual:other.url]) {
        return YES;
    }
    return NO;
}

- (NSUInteger) hash
{
    int prime = 31;
    int result = 1;
    result = (prime * result) + [self.title hash];
    result = (prime * result) + [self.url hash];
    return result;
}


#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.shortTitle = [aDecoder decodeObjectForKey:@"shortTitle"];
        self.epDescription = [aDecoder decodeObjectForKey:@"description"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.duration = [aDecoder decodeObjectForKey:@"duration"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.shortTitle forKey:@"shortTitle"];
    [aCoder encodeObject:self.epDescription forKey:@"description"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

#pragma mark -
#pragma mark NSCopying Methods

- (id) copyWithZone:(NSZone *)zone
{
    MMMedia *newMedia = [[MMMedia alloc] init];
    newMedia.title = [self.title copy];
    newMedia.shortTitle = [self.shortTitle copy];
    newMedia.epDescription = [self.epDescription copy];
    newMedia.date = [self.date copy];
    newMedia.duration = [self.duration copy];
    newMedia.url = [self.url copy];
    return newMedia;
}

@end
