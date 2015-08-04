//
//  NSBundle+BUKImagePickerController.h
//  Pods
//
//  Created by Yiming Tang on 8/4/15.
//
//

@import Foundation;

#define BUKImagePickerLocalizedString(key, comment) NSLocalizedStringFromTableInBundle((key), @"BUKImagePicker", [NSBundle buk_imagePickerBundle], (comment))

@interface NSBundle (BUKImagePickerController)

+ (NSBundle *)buk_imagePickerBundle;

@end
