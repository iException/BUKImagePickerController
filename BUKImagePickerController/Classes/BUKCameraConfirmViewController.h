//
//  BUKCameraComfirmViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/17/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//


@import UIKit;

@class FastttCapturedImage;
@protocol BUKCameraConfirmViewControllerDelegate;

@interface BUKCameraConfirmViewController : UIViewController

@property (nonatomic, weak) id<BUKCameraConfirmViewControllerDelegate> delegate;
@property (nonatomic) FastttCapturedImage *capturedImage;

@end


@protocol BUKCameraConfirmViewControllerDelegate <NSObject>
@required
- (void)cameraConfirmViewControllerDidCancel:(BUKCameraConfirmViewController *)viewController;
- (void)cameraConfirmViewControllerDidConfirm:(BUKCameraConfirmViewController *)viewController capturedImage:(FastttCapturedImage *)capturedImage;

@end
