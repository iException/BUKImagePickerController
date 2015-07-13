//
//  BUKAlbumTableViewCell.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAlbumTableViewCell.h"

@interface BUKAlbumTableViewCell ()
@property (nonatomic) UIView *imageContainerView;
@end


@implementation BUKAlbumTableViewCell

#pragma mark - Accessors

@synthesize frontImageView = _frontImageView;
@synthesize middleImageView = _middleImageView;
@synthesize backImageView = _backImageView;
@synthesize titleLabel = _titleLabel;

- (UIImageView *)frontImageView {
    if (!_frontImageView) {
        _frontImageView = [[UIImageView alloc] init];
        _frontImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _frontImageView;
}


- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _middleImageView;
}


- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}


- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageContainerView;
}


#pragma mark - UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self.imageContainerView addSubview:self.backImageView];
        [self.imageContainerView addSubview:self.middleImageView];
        [self.imageContainerView addSubview:self.frontImageView];
        [self.contentView addSubview:self.imageContainerView];
        [self.contentView addSubview:self.titleLabel];
        
        [self setupViewConstraints];
    }
    return self;
}


#pragma mark - Private

- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"imageContainerView": self.imageContainerView,
        @"frontImageView": self.frontImageView,
        @"middleImageView": self.middleImageView,
        @"backImageView": self.backImageView,
        @"titleLabel": self.titleLabel,
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16.0-[imageContainerView(68.0)]-18.0-[titleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backImageView(60.0)]" options:kNilOptions metrics:nil views:views]];
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.backImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2.0-[middleImageView(64.0)]" options:kNilOptions metrics:nil views:views]];
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.middleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[frontImageView(68.0)]|" options:kNilOptions metrics:nil views:views]];
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.frontImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

@end
