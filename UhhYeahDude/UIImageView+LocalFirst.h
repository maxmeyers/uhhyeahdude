//
//  UIImageView+LocalFirst.h
//  UhhYeahDude
//
//  Created by Max Meyers on 6/20/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (LocalFirst)

- (void) setImageWithURL:(NSURL*)url placeHolderImage:(UIImage *)placeHolder butTryLocalPathFirst:(NSString *)localPath;

@end
