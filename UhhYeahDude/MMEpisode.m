//
//  MMEpisode.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMEpisode.h"
#import "MMAppDelegate.h"

@implementation MMEpisode

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
//       path = [self localImageFilePathInBundle];
//       if (path) {
//           self.image = [UIImage imageWithContentsOfFile:path];
//       } else {
//           path = [self localImageFilePathInDocumentsWithExtension:@"jpg"];
//           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//               self.image = [UIImage imageWithContentsOfFile:path];
//           } else {
//               path = [self localImageFilePathInDocumentsWithExtension:@"png"];
//               if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//                   self.image = [UIImage imageWithContentsOfFile:path];
//               }
//           }
//       }
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

- (NSString *) localFilePath
{
    return [NSString stringWithFormat:@"%@/%@", [MMAppDelegate applicationDocumentsDirectory], [self.url lastPathComponent]];
}

- (NSString *) localImageFilePathInBundle
{
    NSString *jpg = [[NSBundle mainBundle] pathForResource:[[self.url lastPathComponent] stringByDeletingPathExtension] ofType:@"jpg"];
    return jpg ? jpg : [[NSBundle mainBundle] pathForResource:[[self.url lastPathComponent] stringByDeletingPathExtension] ofType:@"png"];
}

- (NSString *) localImageFilePathInDocumentsWithExtension:(NSString *)extension;
{
    return [NSString stringWithFormat:@"%@/%@.%@", [MMAppDelegate applicationDocumentsDirectory], [[self.url lastPathComponent] stringByDeletingPathExtension], extension];
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"<MMEpisode: %@ (%@)>", self.title, self.date];
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
        self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
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
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
}

@end
