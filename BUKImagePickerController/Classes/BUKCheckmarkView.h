//
//  BUKCheckmarkView.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@interface BUKCheckmarkView : UIView

@property (nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *checkmarkColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat checkmarkLineWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *fillColor UI_APPEARANCE_SELECTOR;

@end
