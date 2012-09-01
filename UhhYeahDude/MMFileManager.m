//
//  MMFileManager.m
//  UhhYeahDude
//
//  Created by Max Meyers on 8/18/12.
//
//

#import "MMFileManager.h"

@implementation MMFileManager

static MMFileManager *_sharedFileManager;

+ (MMFileManager *) sharedFileManager
{
    @synchronized (self) {
        if (_sharedFileManager == nil) {
            _sharedFileManager = [[MMFileManager alloc] init];
        }
        return _sharedFileManager;
    }
}

@end
