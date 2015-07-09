//
//  BUKImagePickerController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;
@import AssetsLibrary;

typedef NS_ENUM(NSUInteger, BUKImagePickerMediaType) {
    BUKImagePickerMediaTypeAny,
    BUKImagePickerMediaTypeImage,
    BUKImagePickerMediaTypeVideo,
};

@protocol BUKImagePickerControllerDelegate;

@interface BUKImagePickerController : UIViewController

@property (nonatomic, weak) id<BUKImagePickerControllerDelegate> delegate;
@property (nonatomic) BUKImagePickerMediaType mediaType;
@property (nonatomic, readonly) NSOrderedSet *selectedAssetURLs;

@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) NSUInteger minimumNumberOfSelection;
@property (nonatomic) NSUInteger maximumNumberOfSelection;

@property (nonatomic) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic) NSUInteger numberOfColumnsInLandscape;

@end


@protocol BUKImagePickerControllerDelegate <NSObject>

@optional
- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFulfillMinimumSelection:(NSUInteger)minimumNumberOfSelection;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didReachMaximumSelection:(NSUInteger)maximumNumberOfSelection;

- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController;
- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;

@end