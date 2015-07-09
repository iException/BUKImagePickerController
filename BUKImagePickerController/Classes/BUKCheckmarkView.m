//
//  BUKCheckmarkView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKCheckmarkView.h"

@implementation BUKCheckmarkView

#pragma mark - Accessors

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}


- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}


- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}


- (void)setCheckmarkLineWidth:(CGFloat)checkmarkLineWidth {
    _checkmarkLineWidth = checkmarkLineWidth;
    [self setNeedsDisplay];
}


- (void)setCheckmarkColor:(UIColor *)checkmarkColor {
    _checkmarkColor = checkmarkColor;
    [self setNeedsDisplay];
}


#pragma mark - Class Methods

+ (void)initialize {
    if (self == [BUKCheckmarkView class]) {
        BUKCheckmarkView *appearance = [BUKCheckmarkView appearance];
        [appearance setBorderColor:[UIColor whiteColor]];
        [appearance setBorderWidth:1.0];
        [appearance setCheckmarkColor:[UIColor whiteColor]];
        [appearance setCheckmarkLineWidth:2.0];
        [appearance setFillColor:[UIColor colorWithRed:0.078f green:0.435f blue:0.875f alpha:1.0]];
    }
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


- (void)drawRect:(CGRect)rect {
    if (self.borderColor && self.borderWidth > 0) {
        [self.borderColor setFill];
        [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
    }
    
    if (self.fillColor) {
        [self.fillColor setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, self.borderWidth, self.borderWidth)] fill];
    }
    
    if (self.checkmarkColor && self.checkmarkLineWidth > 0) {
        UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
        checkmarkPath.lineWidth = self.checkmarkLineWidth;
        
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        
        [checkmarkPath moveToPoint:CGPointMake(width * (6.0 / 24.0), height * (12.0 / 24.0))];
        [checkmarkPath addLineToPoint:CGPointMake(width * (10.0 / 24.0), height * (16.0 / 24.0))];
        [checkmarkPath addLineToPoint:CGPointMake(width * (18.0 / 24.0), height * (8.0 / 24.0))];
        
        [self.checkmarkColor setStroke];
        [checkmarkPath stroke];
    }
}


#pragma mark - Private

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
}

@end
