//
//  UIImage+BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "UIImage+BUKImagePickerController.h"
#import "BUKImagePickerController.h"

@implementation UIImage (BUKImagePickerController)

+ (UIImage *)buk_albumPlaceholderImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:0.702f green:0.702f blue:0.714f alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)buk_bundleImageNamed:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[BUKImagePickerController class]];
    return [self buk_imageNamed:name inBundle:bundle];
}


+ (UIImage *)buk_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    if ([self respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [self imageNamed:name];
    }
}

@end
