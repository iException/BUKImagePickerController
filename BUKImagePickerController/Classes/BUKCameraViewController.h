//
//  BUKCameraViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@class FastttCamera;
@protocol BUKCameraViewControllerDelegate;

@interface BUKCameraViewController : UIViewController

@property (nonatomic, weak) id<BUKCameraViewControllerDelegate> delegate;
@property (nonatomic, readonly) FastttCamera *fastCamera;
@property (nonatomic, readonly) NSArray *capturedImages;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL needsConfirmation;
@property (nonatomic) BOOL usesScaledImage;
@property (nonatomic) CGFloat maxScaledDimension;

@end

@protocol BUKCameraViewControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController;
- (void)cameraViewController:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images;
- (BOOL)cameraViewControllerShouldTakePicture:(BUKCameraViewController *)cameraViewController;

- (BOOL)cameraViewControllerShouldEnableDoneButton:(BUKCameraViewController *)cameraViewController;
- (void)userDeniedCameraPermissionsForCameraViewController:(BUKCameraViewController *)cameraViewController;

- (BOOL)cameraViewControllerShouldShowSelectionInfo:(BUKCameraViewController *)cameraViewController;
- (NSString *)cameraViewControllerSelectionInfo:(BUKCameraViewController *)cameraViewController;

@end
