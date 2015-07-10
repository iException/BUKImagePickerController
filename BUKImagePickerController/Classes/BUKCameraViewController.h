//
//  BUKCameraViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@protocol BUKCameraViewControllerDelegate;

@interface BUKCameraViewController : UIViewController

@property (nonatomic, weak) id<BUKCameraViewControllerDelegate> delegate;

@end

@protocol BUKCameraViewControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController;
- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images;
@end
