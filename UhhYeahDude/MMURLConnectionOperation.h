//
//  MMURLConnectionOperation.h
//  UhhYeahDude
//
//  Created by Max Meyers on 9/15/12.
//
//

#import "AFURLConnectionOperation.h"

@class MMMedia;

@interface MMURLConnectionOperation : AFURLConnectionOperation

@property MMMedia *media;

@end
