//
//  BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import <FastttCamera/UIViewController+FastttCamera.h>
#import "BUKImagePickerController.h"
#import "BUKAssetsViewController.h"
#import "BUKAlbumsViewController.h"
#import "BUKCameraViewController.h"

@interface BUKImagePickerController () <BUKAssetsViewControllerDelegate, BUKAlbumsViewControllerDelegate, BUKCameraViewControllerDelegate>

@property (nonatomic, readwrite) NSMutableOrderedSet *selectedAssetURLs;
@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) BUKAlbumsViewController *albumsViewController;
@property (nonatomic) BUKAssetsViewController *assetsViewController;
@property (nonatomic) BUKCameraViewController *cameraViewController;
@property (nonatomic) UINavigationController *childNavigationController;

@end

@implementation BUKImagePickerController

#pragma mark - Accessors

- (BUKAlbumsViewController *)albumsViewController {
    if (!_albumsViewController) {
        _albumsViewController = [[BUKAlbumsViewController alloc] init];
        _albumsViewController.delegate = self;
        _albumsViewController.assetsLibrary = self.assetsLibrary;
    }
    return _albumsViewController;
}


- (BUKAssetsViewController *)assetsViewController {
    if (!_assetsViewController) {
        _assetsViewController = [[BUKAssetsViewController alloc] init];
        _assetsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        _assetsViewController.minimumInteritemSpacing = 2.0;
        _assetsViewController.minimumLineSpacing = 2.0;
        _assetsViewController.numberOfColumnsInPortrait = self.numberOfColumnsInPortrait;
        _assetsViewController.numberOfColumnsInLandscape = self.numberOfColumnsInLandscape;
        _assetsViewController.delegate = self;
    }
    return _assetsViewController;
}


- (BUKCameraViewController *)cameraViewController {
    if (!_cameraViewController) {
        _cameraViewController = [[BUKCameraViewController alloc] init];
        _cameraViewController.delegate = self;
    }
    return _cameraViewController;
}


#pragma mark - NSObject

- (instancetype)init {
    if ((self = [super init])) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _selectedAssetURLs = [NSMutableOrderedSet orderedSet];
        _mediaType = BUKImagePickerControllerMediaTypeImage;
        _sourceType = BUKImagePickerControllerSourceTypeLibraryAndCamera;
        _allowsMultipleSelection = YES;
        _numberOfColumnsInPortrait = 4;
        _numberOfColumnsInLandscape = 7;
        _minimumNumberOfSelection = 0;
        _maximumNumberOfSelection = 0;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *viewController;
    switch (self.sourceType) {
        case BUKImagePickerControllerSourceTypeLibraryAndCamera: {
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            [navigationController setViewControllers:@[self.albumsViewController, self.assetsViewController]];
            self.childNavigationController = navigationController;
            viewController = navigationController;
            break;
        }
        case BUKImagePickerControllerSourceTypeLibrary: {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.albumsViewController];
            self.childNavigationController = navigationController;
            viewController = navigationController;
            break;
        }
        case BUKImagePickerControllerSourceTypeCamera: {
            viewController = self.cameraViewController;
            break;
        }
    }
    
    if (viewController) {
        [self fastttAddChildViewController:viewController];
    }
}


- (BOOL)prefersStatusBarHidden {
    return self.sourceType == BUKImagePickerControllerSourceTypeCamera;
}


#pragma mark - BUKAlbumsViewControllerDelegate

- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self.assetsViewController.assetsGroup = assetsGroup;
}


- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - BUKAssetsViewControllerDelegate

- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController shouldSelectAsset:(ALAsset *)asset {
    return YES;
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didSelectAsset:(ALAsset *)asset {
    
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didDeselectAsset:(ALAsset *)asset {
    
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didFinishPickingAssets:(NSArray *)assets {
    
}


- (void)assetsViewControllerDidCancel:(BUKAssetsViewController *)assetsViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerDidCancel:)]) {
        [self.delegate buk_imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - BUKCameraViewControllerDelegate

- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController {
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerDidCancel:)]) {
            [self.delegate buk_imagePickerControllerDidCancel:self];
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.sourceType == BUKImagePickerControllerSourceTypeLibraryAndCamera) {
        [self.childNavigationController popViewControllerAnimated:YES];
    }
}


- (void)cameraViewController:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingImages:)]) {
        [self.delegate buk_imagePickerController:self didFinishPickingImages:images];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private


@end
