//
//  BUKAssetsViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@class ALAssetsGroup;
@protocol BUKAssetsViewControllerDelegate;

@interface BUKAssetsViewController : UICollectionViewController

@property (nonatomic) ALAssetsGroup *assetsGroup;
@property (nonatomic, readonly) NSArray *assets;
@property (nonatomic, weak) id<BUKAssetsViewControllerDelegate> delegate;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL reversesAssets;
@property (nonatomic) BOOL showsCameraCell;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic) NSUInteger numberOfColumnsInLandscape;
@property (nonatomic) BOOL ignoreChange;

- (void)updateAssets;

@end


@class ALAsset;

@protocol BUKAssetsViewControllerDelegate <NSObject>

@optional
- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController shouldSelectAsset:(ALAsset *)asset;
- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didSelectAsset:(ALAsset *)asset;
- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didDeselectAsset:(ALAsset *)asset;

- (void)assetsViewControllerDidFinishPicking:(BUKAssetsViewController *)assetsViewController;
- (void)assetsViewControllerDidCancel:(BUKAssetsViewController *)assetsViewController;

- (void)assetsViewControllerDidSelectCamera:(BUKAssetsViewController *)assetsViewController;

- (BOOL)assetsViewControllerShouldEnableDoneButton:(BUKAssetsViewController *)assetsViewController;
- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController isAssetSelected:(ALAsset *)asset;
- (BOOL)assetsViewControllerShouldShowSelectionInfo:(BUKAssetsViewController *)assetsViewController;
- (NSString *)assetsViewControllerSelectionInfo:(BUKAssetsViewController *)assetsViewController;

@end

