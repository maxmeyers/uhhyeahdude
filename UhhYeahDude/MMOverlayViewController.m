//
//  MMOverlayViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/17/12.
//
//

#import "MMOverlayViewController.h"

@implementation MMOverlayViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.overlayedViewController performSelector:@selector(doneSearching)];
}

@end
