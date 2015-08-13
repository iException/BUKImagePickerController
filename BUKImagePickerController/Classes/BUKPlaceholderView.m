//
//  BUKPlaceholderView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 8/12/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKPlaceholderView.h"
#import "UIColor+BUKImagePickerController.h"

@implementation BUKPlaceholderView

#pragma mark - Accessors

@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.numberOfLines = 5;
        _titleLabel.textColor = [UIColor buk_lightTextColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        _titleLabel.font = [UIFont fontWithDescriptor:fontDescriptor size:(fontDescriptor.pointSize * 1.6f)];
    }
    return _titleLabel;
}


- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.numberOfLines = 5;
        _messageLabel.textColor = [UIColor buk_lightTextColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    return _messageLabel;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


#pragma mark - Private

- (void)initialize {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    [self addSubview:self.messageLabel];
    [self setupViewConstraints];
}


- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"titleLabel": self.titleLabel,
        @"messageLabel": self.messageLabel
    };
    
    NSDictionary *metrics = @{
        @"margin": @(15.0)
    };
    
    // Title label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:(-5.0)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[titleLabel]-(margin)-|" options:kNilOptions metrics:metrics views:views]];
    
    // Message label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:5.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[messageLabel]-(margin)-|" options:kNilOptions metrics:metrics views:views]];
}

@end
