//
//  MMTabBarController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/21/13.
//
//

#import "MMTabBarController.h"

@interface MMTabBarController ()

@end

@implementation MMTabBarController

- (NSUInteger) supportedInterfaceOrientations {
    return [[self.viewControllers objectAtIndex:(self.selectedIndex > self.viewControllers.count - 1 ? 0 : self.selectedIndex)] supportedInterfaceOrientations];
}

@end
