//
//  BUKAlbumTableViewCell.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@interface BUKAlbumTableViewCell : UITableViewCell

@property (nonatomic, readonly) UIImageView *frontImageView;
@property (nonatomic, readonly) UIImageView *middleImageView;
@property (nonatomic, readonly) UIImageView *backImageView;
@property (nonatomic, readonly) UILabel *titleLabel;

@end
