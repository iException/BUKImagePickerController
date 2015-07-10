//
//  BUKVideoIconView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKVideoIconView.h"

@implementation BUKVideoIconView

+ (void)initialize {
    if (self == [BUKVideoIconView class]) {
        BUKVideoIconView *appearance = [BUKVideoIconView appearance];
        appearance.iconColor = [UIColor whiteColor];
    }
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    if (!self.iconColor) {
        return;
    }
    
    [self.iconColor setFill];
    
    // Draw triangle
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds) - CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
    [trianglePath closePath];
    [trianglePath fill];
    
    // Draw rounded square
    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - CGRectGetMidY(self.bounds) - 1.0, CGRectGetHeight(self.bounds)) cornerRadius:2.0];
    [squarePath fill];
}


#pragma mark - Private

- (void)setup {
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}

@end
