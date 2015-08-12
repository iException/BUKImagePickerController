//
//  NSBundle+BUKImagePickerController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 8/4/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import Foundation;

#define BUKImagePickerLocalizedString(key, comment) NSLocalizedStringFromTableInBundle((key), @"BUKImagePicker", [NSBundle buk_imagePickerBundle], (comment))

@interface NSBundle (BUKImagePickerController)

+ (NSBundle *)buk_imagePickerBundle;
+ (NSURL *)buk_imagePickerBundleURL;

@end
