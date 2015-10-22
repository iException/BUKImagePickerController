//
//  BUKCameraCollectionViewCell.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 10/22/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKCameraCollectionViewCell.h"
#import "UIImage+BUKImagePickerController.h"
#import "NSBundle+BUKImagePickerController.h"

@implementation BUKCameraCollectionViewCell

#pragma mark - Accessors

@synthesize cameraIconImageView = _cameraIconImageView;
@synthesize titleLabel = _titleLabel;

- (UIImageView *)cameraIconImageView {
    if (!_cameraIconImageView) {
        _cameraIconImageView = [[UIImageView alloc] initWithImage:[UIImage buk_bundleImageNamed:@"camera-icon"]];
        _cameraIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _cameraIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _cameraIconImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:10.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = BUKImagePickerLocalizedString(@"Take Photos", nil);
    }
    return _titleLabel;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.42f alpha:1.0];
        [self.contentView addSubview:self.cameraIconImageView];
        [self.contentView addSubview:self.titleLabel];
        [self setupViewConstraints];
    }
    return self;
}


#pragma mark - Private

- (void)setupViewConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraIconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-6.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cameraIconImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:2.0]];
}

@end
