//
//  BUKVideoIndicatorView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKVideoIndicatorView.h"
#import "BUKVideoIconView.h"

@implementation BUKVideoIndicatorView

#pragma mark - Accessors

@synthesize videoIconView = _videoIconView;
@synthesize timeLabel = _timeLabel;

- (BUKVideoIconView *)videoIconView {
    if (!_videoIconView) {
        _videoIconView = [[BUKVideoIconView alloc] init];
        _videoIconView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _videoIconView;
}


- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _timeLabel;
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}


#pragma mark - Private

- (void)initialize {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    [self addSubview:self.videoIconView];
    [self addSubview:self.timeLabel];
    
    [self setupViewConstraints];
}


- (void)setupViewConstraints {
    NSDictionary *views =  @{
        @"videoIconView": self.videoIconView,
        @"timeLabel": self.timeLabel,
    };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5.0-[videoIconView(14.0)]-4.0-[timeLabel]-5.0-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoIconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoIconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.videoIconView attribute:NSLayoutAttributeWidth multiplier:(8.0 / 14.0) constant:0]];
}

@end
