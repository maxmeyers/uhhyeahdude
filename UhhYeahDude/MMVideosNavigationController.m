//
//  MMVideosNavigationController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/21/13.
//
//

#import "MMVideosNavigationController.h"

@interface MMVideosNavigationController ()

@end

@implementation MMVideosNavigationController

- (NSUInteger) supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}
@end
