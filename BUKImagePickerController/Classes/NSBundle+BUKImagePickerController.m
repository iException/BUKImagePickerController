//
//  NSBundle+BUKImagePickerController.m
//  Pods
//
//  Created by Yiming Tang on 8/4/15.
//
//

#import "NSBundle+BUKImagePickerController.h"
#import "BUKImagePickerController.h"

@implementation NSBundle (BUKImagePickerController)

+ (NSBundle *)buk_imagePickerBundle {
    return [self bundleWithURL:[self buk_imagePickerBundleURL]];
}


+ (NSURL *)buk_imagePickerBundleURL {
    NSBundle *bundle = [NSBundle bundleForClass:[BUKImagePickerController class]];
    return [bundle URLForResource:@"BUKImagePickerController" withExtension:@"bundle"];
}

@end
