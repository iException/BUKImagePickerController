//
//  BUKAlbumsViewController.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import UIKit;

@class ALAssetsLibrary;
@protocol BUKAlbumsViewControllerDelegate;

@interface BUKAlbumsViewController : UITableViewController

@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, weak) id<BUKAlbumsViewControllerDelegate> delegate;

@end


@class ALAssetsGroup;

@protocol BUKAlbumsViewControllerDelegate <NSObject>

@optional
- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController;

@end
