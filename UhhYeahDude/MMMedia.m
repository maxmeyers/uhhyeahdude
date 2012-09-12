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
    return [NSString stringWithFormat:@"%@.%@", [[self.url lastPathComponent] stringByDeletingPathExtension], [self fileExtension]];
}

- (NSString *) imageDirectoryName
{
    switch (self.mediaType) {
        case Episode:
            return @"episodes";
        case SethsCorner:
            return @"seth";
    }
    return @"";
}

- (NSString *) fileName
{
    return [self.url lastPathComponent];
}

- (NSString *) localFilePath
{
    return [NSString stringWithFormat:@"%@/%@", MEDIA_DIRECTORY, [self.url lastPathComponent]];
}

- (NSString *) localImageFilePath
{
    return [NSString stringWithFormat:@"%@/%@/%@", IMAGES_DIRECTORY, [self imageDirectoryName], [self imageName]];
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

@end
