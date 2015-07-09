//
//  BUKAlbumTableViewCell.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAlbumTableViewCell.h"

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


#pragma mark - UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self.contentView addSubview:self.backImageView];
        [self.contentView addSubview:self.middleImageView];
        [self.contentView addSubview:self.frontImageView];
        [self.contentView addSubview:self.titleLabel];
        
        [self setupViewConstraints];
    }
    return self;
}


#pragma mark - Private

- (void)setupViewConstraints {
    
}

@end
