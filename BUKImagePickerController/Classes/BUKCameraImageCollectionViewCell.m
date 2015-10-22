//
//  BUKCameraImageCollectionViewCell.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/13/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKCameraImageCollectionViewCell.h"
#import "UIImage+BUKImagePickerController.h"

@implementation BUKCameraImageCollectionViewCell

#pragma mark - Accessors

@synthesize imageView = _imageView;
@synthesize deleteButton = _deleteButton;

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    }
    return _imageView;
}


- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_deleteButton setImage:[UIImage buk_bundleImageNamed:@"delete-button"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


#pragma mark - UICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.deleteButton];
        [self setupViewConstraints];
    }
    return self;
}


#pragma mark - Actions

- (void)deleteButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewCell:didClickDeleteButton:)]) {
        [self.delegate imageCollectionViewCell:self didClickDeleteButton:sender];
    }
}


#pragma mark - Private

- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"imageView": self.imageView,
        @"deleteButton": self.deleteButton,
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]-12.0-|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12.0-[imageView]|" options:kNilOptions metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton]-(5.0)-|" options:kNilOptions metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5.0)-[deleteButton]" options:kNilOptions metrics:nil views:views]];
}

@end
