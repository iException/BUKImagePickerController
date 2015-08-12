//
//  NSBundle+BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 8/4/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
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
