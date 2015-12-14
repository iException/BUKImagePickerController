//
//  BUKImagePickerController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

/**
 The media type of assets.
 */
typedef NS_ENUM(NSUInteger, BUKImagePickerControllerMediaType) {
    /**
     Both images and videos.
     */
    BUKImagePickerControllerMediaTypeAny,
    /**
     Only images.
     */
    BUKImagePickerControllerMediaTypeImage,
    /**
     Only videos.
     */
    BUKImagePickerControllerMediaTypeVideo,
};

/**
 The source type of image picker.
 */
typedef NS_ENUM(NSUInteger, BUKImagePickerControllerSourceType) {
    /**
     Selects assets from the photo library.
     */
    BUKImagePickerControllerSourceTypeLibrary,
    /**
     Captures images with a camera.
     */
    BUKImagePickerControllerSourceTypeCamera,
    /**
     Selects images in saved photos album.
     */
    BUKImagePickerControllerSourceTypeSavedPhotosAlbum,
};

@protocol BUKImagePickerControllerDelegate;

/**
 A controller that allows picking multiple assets from user's photo libray or capturing images with a camera.
 */
@interface BUKImagePickerController : UIViewController

/// --------------------
/// @name Picking Assets
/// --------------------

/**
 The media type of the controller. Default value is `BUKImagePickerControllerMediaTypeImage`.
 
 @see BUKImagePickerControllerMediaType
 */
@property (nonatomic) BUKImagePickerControllerMediaType mediaType;

/**
 The source type of the controller. Default value is `BUKImagePickerControllerSourceTypeLibrary`.
 
 @see BUKImagePickerControllerSourceType
 */
@property (nonatomic) BUKImagePickerControllerSourceType sourceType;

/**
 An array of selected assets' URLs. The value is always `nil` if the `sourceType` of the receiver is `BUKImagePickerControllerSourceTypeCamera`.
 */
@property (nonatomic, readonly) NSArray *selectedAssetURLs;

/**
 The receiver's delegate.
 
 @discussion A `BUKImagePickerControllerDelegate` responds to messages sent by selecting assets or capturing images with the picker. You can use the delegate to handle these events.
 */
@property (nonatomic, weak) id<BUKImagePickerControllerDelegate> delegate;

/**
 Indicates whether empty albums will be ignored. Default value is `NO`.
 
 @warning It has no effects when `sourceType` is `BUKImagePickerControllerSourceTypeCamera`.
 */
@property (nonatomic) BOOL excludesEmptyAlbums;

/**
 Indicates whether multiple selection is enabled. Default value is `YES`.
 */
@property (nonatomic) BOOL allowsMultipleSelection;

/**
 Indicates whether a camera cell will be shown on assets collection view. When the cell is tapped, a camera view will be presented, so the user can capture additional images besides original assets. Default value is `NO`.
 
 @warning It has no effects when `sourceType` is `BUKImagePickerControllerSourceTypeCamera`.
 */
@property (nonatomic) BOOL showsCameraCell;

/**
 Controls the order of assets. Default value is `NO` which means do not reverse assets order.
 
 @warning It has no effects when `sourceType` is `BUKImagePickerControllerSourceTypeCamera`.
 */
@property (nonatomic) BOOL reversesAssets;

/**
 Indicates whether a text label will be shown when the number of selected assets is changed. Default value is `YES`.
 */
@property (nonatomic) BOOL showsNumberOfSelectedAssets;

/**
 The minimum number of selected assets required. Default value is `1`.
 */
@property (nonatomic) NSUInteger minimumNumberOfSelection;

/**
 The maximum number of selected assets allowed. If the value is `0`, selection is unlimited. Default value is `0`.
 
 @warning If the value is less than `minimumNumberOfSelection`, it will be marked as invalid and maximum selection is unlimited.
 */
@property (nonatomic) NSUInteger maximumNumberOfSelection;

/**
 The number of columns of the receiver in portrait mode. Default value is `4`. Only works for `BUKImagePickerControllerSourceTypeLibrary` and `BUKImagePickerControllerSourceTypeSavedPhotosAlbum`.
 */
@property (nonatomic) NSUInteger numberOfColumnsInPortrait;

/**
 The number of columns of the receiver in landscape mode. Default value is `7`. Only works for `BUKImagePickerControllerSourceTypeLibrary` and `BUKImagePickerControllerSourceTypeSavedPhotosAlbum`.
 */
@property (nonatomic) NSUInteger numberOfColumnsInLandscape;

/// ----------------------
/// @name Capturing Images
/// ----------------------

/**
 Indicates whether the receiver should save images to user's photo libray after capturing images. Default value is `NO`.
 */
@property (nonatomic) BOOL savesToPhotoLibrary;

/**
 Indicates whether the receiver should waiting for user's confirmation after capturing images. Only works for `BUKImagePickerControllerSourceTypeCamera`. Default value is `NO`.
 */
@property (nonatomic) BOOL needsConfirmation;

/**
 The receiver will scale the captured images to fit within the size of the camera preview if this property is set `YES`.
 */
@property (nonatomic) BOOL usesScaledImage;

/**
 The maximum dimension the receiver uses to scale images.
 
 @discussion If you'd like to set an explicit max dimension for scaling the image, set it here. This can be useful if you have specific
 requirements for uploading the image.
 */
@property (nonatomic) BOOL maxScaledDimension;

@end


@class ALAsset;

@protocol BUKImagePickerControllerDelegate <NSObject>

@optional

/**
 Asks the delegate whether the asset should be marked as selected.
 
 @param imagePickerController The image picker controller.
 @param asset                 The asset that was tapped.
 
 @return A boolean value indicating whether the asset should be selected.
 */
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset;

/**
 Tells the delegate that the user selected an asset.
 
 @param imagePickerController The image picker controller.
 @param asset                 An asset that was selected.
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;

/**
 Tells the delegate that the user deselected an asset.
 
 @param imagePickerController The image picker controller.
 @param asset                 An asset that was deselected.
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

/**
 Asks the delegate whether the controller should enable done button.
 
 @param imagePickerController The image picker controller.
 
 @return A boolean value indicating whether the image picker should enable done button.
 */
- (BOOL)buk_imagePickerControllerShouldEnableDoneButton:(BUKImagePickerController *)imagePickerController;

/**
 Tells the delegate the user cancelled picking.
 
 @param imagePickerController The image picker that was cancelled.
 */
- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController;

/**
 Tells the delegate that the user finished picking assets. The message is sent if the source type of the picker is `BUKImagePickerControllerSourceTypeLibrary` and `BUKImagePickerControllerSourceTypeSavedPhotosAlbum`. If you're going to capturing images, use `-buk_imagePickerController:didFinishPickingImages:` instead.
 
 @param imagePickerController The image picker controller.
 @param assets                An array of assets which were selected by the user.
 
 @see -buk_imagePickerController:didFinishPickingImages:
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;

/**
 Tells the delegate that the user finished capturing images. The message is sent if and only if the source type of the picker is `BUKImagePickerControllerSourceTypeCamera`.
 
 @param imagePickerController The image picker controller.
 @param images                An array of `UIImage` objects which were captured by the user.
 
 @see -buk_imagePickerController:didFinishPickingAssets:
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingImages:(NSArray *)images;

/**
 Asks the delegate whether the controller should take picture.
 
 @param imagePickerController The image picker controller.
 @param capturedImages        An array of `UIImage` objects which has already been captured.
 
 @return A boolean value indicating whether the image picker should take picture.
 */
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldTakePictureWithCapturedImages:(NSArray *)capturedImages;

/**
 Tells the delegate that the access is denied.
 
 @param imagePickerController The image picker controller who attemped to open user's photo libray or use the camera.
 */
- (void)buk_imagePickerControllerAccessDenied:(BUKImagePickerController *)imagePickerController;

/**
 Tells the delegate that the image picker controller will save images to the user's photo library.
 
 @param imagePickerController The image picker who's going to save images.
 @param images                An array of `UIImage` objects which will be saved.
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController willSaveImages:(NSArray *)images;

/**
 Tells the delegate that the image picker controller is saving images to the user's photo library.
 
 @param imagePickerController The image picker who is saving images.
 @param images                An array of `UIImage` objects which will be saved.
 @param currentCount          The current count of images that were saved.
 @param totalCount            The total number of images that will be saved.
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController saveImages:(NSArray *)images withProgress:(NSUInteger)currentCount totalCount:(NSUInteger)totalCount;

/**
 Tells the delegate that the image picker finished saving images.
 
 @param imagePickerController The image picker who finished saving images.
 @param images                An array of `UIImage` objects saved.
 @param urls                  An array of `NSURL` objects of `ALAsset`s corresponding to images.
 */
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishSavingImages:(NSArray *)images resultAssetURLs:(NSArray *)urls;

@end
