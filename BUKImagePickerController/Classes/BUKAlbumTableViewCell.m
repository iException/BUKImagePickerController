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
        _frontImageView = [self borderedImageView];
    }
    return _frontImageView;
}


- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [self borderedImageView];
    }
    return _middleImageView;
}


- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [self borderedImageView];
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

- (UIImageView *)borderedImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    imageView.layer.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    return imageView;
}


- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"imageContainerView": self.imageContainerView,
        @"frontImageView": self.frontImageView,
        @"middleImageView": self.middleImageView,
        @"backImageView": self.backImageView,
        @"titleLabel": self.titleLabel,
    };
    
    CGFloat padding = 2.0;
    NSDictionary *metrics = @{
        @"padding": @(padding),
        @"horizontalMargin": @16.0,
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[imageContainerView(68.0)]-(horizontalMargin)-[titleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    // Image container view
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:(padding * 2)]];
    
    // Front image view
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[frontImageView]|" options:kNilOptions metrics:nil views:views]];
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[frontImageView]|" options:kNilOptions metrics:nil views:views]];
    [self.frontImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.frontImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.frontImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    // Middle image view
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[middleImageView]-(padding)-|" options:kNilOptions metrics:metrics views:views]];
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[middleImageView]" options:kNilOptions metrics:metrics views:views]];
    [self.middleImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.middleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.middleImageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    // Back image view
    [self.imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backImageView]" options:kNilOptions metrics:nil views:views]];
    [self.backImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.backImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.backImageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.backImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.imageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.backImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.imageContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:(- 2 * 2 * padding)]];
}

@end
