//
//  BUKCameraImageCollectionViewCell.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/13/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@protocol BUKCameraImageCollectionViewCellDelegate;

@interface BUKCameraImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIButton *deleteButton;
@property (nonatomic, weak) id<BUKCameraImageCollectionViewCellDelegate> delegate;

@end


@protocol BUKCameraImageCollectionViewCellDelegate <NSObject>
@optional
- (void)imageCollectionViewCell:(BUKCameraImageCollectionViewCell *)cell didClickDeleteButton:(UIButton *)button;
@end
