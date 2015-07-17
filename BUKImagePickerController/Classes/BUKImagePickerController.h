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
@property (nonatomic, readonly) NSArray *selectedAssets;
@property (nonatomic, weak) id<BUKImagePickerControllerDelegate> delegate;

@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL showsCameraCell;
@property (nonatomic) BOOL reversesAssets;
@property (nonatomic) BOOL savesToPhotoLibrary;
@property (nonatomic) NSUInteger minimumNumberOfSelection;
@property (nonatomic) NSUInteger maximumNumberOfSelection;

@property (nonatomic) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic) NSUInteger numberOfColumnsInLandscape;

@end


@class ALAsset;

@protocol BUKImagePickerControllerDelegate <NSObject>

@optional
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFulfillMinimumSelection:(NSUInteger)minimumNumberOfSelection;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didReachMaximumSelection:(NSUInteger)maximumNumberOfSelection;

- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingImages:(NSArray *)images;

@end