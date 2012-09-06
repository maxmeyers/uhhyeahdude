//
//  MMVideoSection.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/2/12.
//
//

#import "MMVideoSection.h"

@implementation MMVideoSection

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.items forKey:@"items"];
}

@end
