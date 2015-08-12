//
//  UIImage+BUKImagePickerController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@interface UIImage (BUKImagePickerController)

+ (UIImage *)buk_bundleImageNamed:(NSString *)name;
+ (UIImage *)buk_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)buk_albumPlaceholderImageWithSize:(CGSize)size;

@end
