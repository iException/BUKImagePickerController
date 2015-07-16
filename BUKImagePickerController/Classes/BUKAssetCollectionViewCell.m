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
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}


- (UIView *)checkmarkView {
    if (!_checkmarkView) {
        _checkmarkView = [[BUKCheckmarkView alloc] init];
        _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
        _checkmarkView.hidden = YES;
    }
    return _checkmarkView;
}


- (BUKVideoIndicatorView *)videoIndicatorView {
    if (!_videoIndicatorView) {
        _videoIndicatorView = [[BUKVideoIndicatorView alloc] init];
        _videoIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _videoIndicatorView.hidden = YES;
    }
    return _videoIndicatorView;
}


- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] init];
        _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        _overlayView.backgroundColor = [UIColor whiteColor];
        _overlayView.alpha = 0.4f;
        _overlayView.hidden = YES;
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
        
        self.showsOverlayViewWhenSelected = YES;
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
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[videoIndicatorView(20.0)]|" options:kNilOptions metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[checkmarkView(24.0)]-4.0-|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4.0-[checkmarkView(24.0)]" options:kNilOptions metrics:nil views:views]];
}

@end
