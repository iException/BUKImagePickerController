//
//  BUKAssetCollectionViewCell.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@interface BUKAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIView *checkmarkView;
@property (nonatomic, readonly) UIView *videoIndicatorView;
@property (nonatomic, readonly) UIView *overlayView;
@property (nonatomic) BOOL showsOverlayViewWhenSelected;

@end
