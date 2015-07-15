//
//  BUKImageCollectionViewCell.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/13/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@protocol BUKImageCollectionViewCellDelegate;

@interface BUKImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIButton *deleteButton;
@property (nonatomic, weak) id<BUKImageCollectionViewCellDelegate> delegate;

@end


@protocol BUKImageCollectionViewCellDelegate <NSObject>
@optional
- (void)imageCollectionViewCell:(BUKImageCollectionViewCell *)cell didClickDeleteButton:(UIButton *)button;
@end
