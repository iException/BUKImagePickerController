//
//  BUKAssetCollectionViewCell.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAssetCollectionViewCell.h"
#import "BUKCheckmarkView.h"
#import "BUKVideoIndicatorView.h"

@implementation BUKAssetCollectionViewCell

#pragma mark - Accessors

@synthesize imageView = _imageView;
@synthesize checkmarkView = _checkmarkView;
@synthesize videoIndicatorView = _videoIndicatorView;
@synthesize overlayView = _overlayView;

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}


- (BUKCheckmarkView *)checkmarkView {
    if (!_checkmarkView) {
        _checkmarkView = [[BUKCheckmarkView alloc] init];
        _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _checkmarkView;
}


- (BUKVideoIndicatorView *)videoIndicatorView {
    if (!_videoIndicatorView) {
        _videoIndicatorView = [[BUKVideoIndicatorView alloc] init];
        _videoIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _videoIndicatorView;
}


- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _overlayView.backgroundColor = [UIColor whiteColor];
        _overlayView.alpha = 0.4f;
    }
    return _overlayView;
}


#pragma mark - UICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.videoIndicatorView];
        [self.contentView addSubview:self.overlayView];
        [self.contentView addSubview:self.checkmarkView];

        [self setupViewConstraints];
    }
    return self;
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.checkmarkView.hidden = !selected;
    self.overlayView.hidden = !(self.showsOverlayViewWhenSelected && selected);
}


#pragma mark - Private

- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"imageView": self.imageView,
        @"videoIndicatorView": self.videoIndicatorView,
        @"overlayView": self.overlayView,
        @"checkmarkView": self.checkmarkView,
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlayView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoIndicatorView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[videoIndicatorView]|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[videoIndicatorView]-2-|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[videoIndicatorView]" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24.0]];
}

@end
