//
//  MMXMLParserDelegate.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMEpisodeXMLParserDelegate.h"
#import "MMEpisode.h"
#import "MMEpisodeDataSource.h"

@implementation MMEpisodeXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    currentEpisodes = [NSMutableArray array];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    // If we haven't started an episode
    if (!currentEpisode && [elementName isEqualToString:@"item"]) {
        currentEpisode = [MMEpisode new];
    }
    // If we've already started an episode
    else if (currentEpisode) {
        if ([elementName isEqualToString:@"enclosure"] && [attributeDict objectForKey:@"url"]) {
            [currentEpisode setProperty:@"url" andValue:[attributeDict objectForKey:@"url"]];
        } else {
            currentProperty = elementName;
            currentValue = @"";
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentEpisode && currentProperty) {
        currentValue = [currentValue stringByAppendingString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (currentEpisode && [elementName isEqualToString:@"item"]) {
        [currentEpisodes addObject:currentEpisode];
        currentEpisode = nil;
    } else if (currentEpisode && currentProperty) {
        [currentEpisode setProperty:currentProperty andValue:currentValue];
        currentValue = nil;
        currentProperty = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[MMEpisodeDataSource sharedDataSource] setEpisodes:currentEpisodes];
    [NSKeyedArchiver archiveRootObject:currentEpisodes toFile:@"/Users/maxmeyers/Desktop/Episodes.bin"];
    currentEpisodes = nil;
}

@end
