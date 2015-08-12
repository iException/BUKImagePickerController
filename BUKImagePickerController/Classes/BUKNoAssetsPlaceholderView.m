//
//  BUKNoAssetsPlaceholderView.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 8/12/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKNoAssetsPlaceholderView.h"
#import "NSBundle+BUKImagePickerController.h"

@implementation BUKNoAssetsPlaceholderView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.titleLabel.text = BUKImagePickerLocalizedString(@"No Photos or Videos", nil);
        
        NSString *messageFormat = nil;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            messageFormat = BUKImagePickerLocalizedString(@"You can take photos and videos using the camera, or sync photos and videos onto your %@\nusing iTunes.", nil);
        } else {
            messageFormat = BUKImagePickerLocalizedString(@"You can sync photos and videos onto your %@ using iTunes.", nil);
        }
        self.messageLabel.text = [NSString stringWithFormat:messageFormat, [[UIDevice currentDevice] model]];
    }
    return self;
}

@end
