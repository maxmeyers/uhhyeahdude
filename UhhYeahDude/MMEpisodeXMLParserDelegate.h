//
//  MMXMLParserDelegate.h
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import <Foundation/Foundation.h>

@class MMEpisode;

@interface MMEpisodeXMLParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableArray *currentEpisodes;
    MMEpisode *currentEpisode;
    NSString *currentProperty;
    NSString *currentValue;
}

@property NSArray *episodes;

@end
