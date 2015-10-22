//
//  BUKImagePickerController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, BUKImagePickerControllerMediaType) {
    BUKImagePickerControllerMediaTypeAny,
    BUKImagePickerControllerMediaTypeImage,
    BUKImagePickerControllerMediaTypeVideo,
};

typedef NS_ENUM(NSUInteger, BUKImagePickerControllerSourceType) {
    BUKImagePickerControllerSourceTypeLibrary,
    BUKImagePickerControllerSourceTypeCamera,
    BUKImagePickerControllerSourceTypeSavedPhotosAlbum,
};

@protocol BUKImagePickerControllerDelegate;

@interface BUKImagePickerController : UIViewController

@property (nonatomic) BUKImagePickerControllerMediaType mediaType;
@property (nonatomic) BUKImagePickerControllerSourceType sourceType;
@property (nonatomic, readonly) NSArray *selectedAssetURLs;
@property (nonatomic, weak) id<BUKImagePickerControllerDelegate> delegate;

@property (nonatomic) BOOL excludesEmptyAlbums;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL showsCameraCell;
@property (nonatomic) BOOL reversesAssets;
@property (nonatomic) BOOL showsNumberOfSelectedAssets;
@property (nonatomic) NSUInteger minimumNumberOfSelection;
@property (nonatomic) NSUInteger maximumNumberOfSelection;

@property (nonatomic) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic) NSUInteger numberOfColumnsInLandscape;

@property (nonatomic) BOOL savesToPhotoLibrary;
@property (nonatomic) BOOL needsConfirmation;
@property (nonatomic) BOOL usesScaledImage;
@property (nonatomic) BOOL maxScaledDimension;

@end


@class ALAsset;

@protocol BUKImagePickerControllerDelegate <NSObject>

@optional
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

- (BOOL)buk_imagePickerControllerShouldEnableDoneButton:(BUKImagePickerController *)imagePickerController;

- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingImages:(NSArray *)images;
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldTakePictureWithCapturedImages:(NSArray *)capturedImages;
- (void)buk_imagePickerControllerAccessDenied:(BUKImagePickerController *)imagePickerController;

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController willSaveImages:(NSArray *)images;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController saveImages:(NSArray *)images withProgress:(NSUInteger)currentCount totalCount:(NSUInteger)totalCount;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishSavingImages:(NSArray *)images resultAssetURLs:(NSArray *)urls;

@end