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
@property (nonatomic) BOOL allowsMultipleSelection;

@end


@class ALAssetsGroup;

@protocol BUKAlbumsViewControllerDelegate <NSObject>

@optional
- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController;
- (void)albumsViewControllerDidFinishPicking:(BUKAlbumsViewController *)viewController;
- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (BOOL)albumsViewControllerShouldEnableDoneButton:(BUKAlbumsViewController *)viewController;
- (BOOL)albumsViewControllerShouldShowSelectionInfo:(BUKAlbumsViewController *)viewController;
- (NSString *)albumsViewControllerSelectionInfo:(BUKAlbumsViewController *)viewController;
@end
