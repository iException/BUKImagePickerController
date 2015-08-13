//
//  BUKAccessDeniedPlaceholderView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 8/12/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAccessDeniedPlaceholderView.h"
#import "NSBundle+BUKImagePickerController.h"

@implementation BUKAccessDeniedPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.titleLabel.text = BUKImagePickerLocalizedString(@"This app does not have access to your photos or videos.", nil);
        self.messageLabel.text = BUKImagePickerLocalizedString(@"You can enable access in \"Settings\" -> \"Privacy\" -> \"Photos\".", nil);
    }
    return self;
}

@end
