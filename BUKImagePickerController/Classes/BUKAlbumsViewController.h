//
//  BUKAlbumsViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@class BUKAssetsManager;
@protocol BUKAlbumsViewControllerDelegate;

@interface BUKAlbumsViewController : UITableViewController

@property (nonatomic) BUKAssetsManager *assetsManager;
@property (nonatomic, readonly) NSArray *assetsGroups;
@property (nonatomic, weak) id<BUKAlbumsViewControllerDelegate> delegate;

@end


@class ALAssetsGroup;

@protocol BUKAlbumsViewControllerDelegate <NSObject>

@optional
- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (BOOL)albumsViewController:(BUKAlbumsViewController *)viewController shouldSelectAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (void)albumsViewController:(BUKAlbumsViewController *)viewController didFinishPickingAssets:(NSArray *)assets;
- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController;

@end
