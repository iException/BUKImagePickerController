//
//  BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;
#import <FastttCamera/UIViewController+FastttCamera.h>
#import "BUKImagePickerController.h"
#import "BUKAssetsViewController.h"
#import "BUKAlbumsViewController.h"
#import "BUKCameraViewController.h"
#import "BUKAssetsManager.h"

@interface BUKImagePickerController () <BUKAssetsViewControllerDelegate, BUKAlbumsViewControllerDelegate, BUKCameraViewControllerDelegate>

@property (nonatomic) NSMutableArray *mutableSelectedAssets;
@property (nonatomic) BUKAssetsManager *assetsManager;
@property (nonatomic) BUKAlbumsViewController *albumsViewController;
@property (nonatomic) BUKAssetsViewController *assetsViewController;
@property (nonatomic) BUKCameraViewController *cameraViewController;
@property (nonatomic) UINavigationController *childNavigationController;

@end

@implementation BUKImagePickerController

#pragma mark - Accessors

- (NSArray *)selectedAssets {
    return [self.mutableSelectedAssets copy];
}


- (BUKAlbumsViewController *)albumsViewController {
    if (!_albumsViewController) {
        _albumsViewController = [[BUKAlbumsViewController alloc] init];
        _albumsViewController.delegate = self;
        _albumsViewController.assetsManager = self.assetsManager;
    }
    return _albumsViewController;
}


- (BUKAssetsViewController *)assetsViewController {
    if (!_assetsViewController) {
        _assetsViewController = [[BUKAssetsViewController alloc] init];
        _assetsViewController.delegate = self;
        _assetsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        _assetsViewController.minimumInteritemSpacing = 2.0;
        _assetsViewController.minimumLineSpacing = 2.0;
        _assetsViewController.numberOfColumnsInPortrait = self.numberOfColumnsInPortrait;
        _assetsViewController.numberOfColumnsInLandscape = self.numberOfColumnsInLandscape;
        _assetsViewController.reversesAssets = YES;
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


- (BUKAssetsManager *)assetsManager {
    if (!_assetsManager) {
        _assetsManager = [[BUKAssetsManager alloc] initWithAssetsLibrary:[[ALAssetsLibrary alloc] init]
                                                              mediaTyle:self.mediaType
                                                             groupTypes:(ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream | ALAssetsGroupAlbum)];
    }
    return _assetsManager;
}


#pragma mark - NSObject

- (instancetype)init {
    if ((self = [super init])) {
        _mutableSelectedAssets = [NSMutableArray array];
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
            __weak typeof(self)weakSelf = self;
            [self.assetsManager fetchAssetsGroupsWithCompletion:^(NSArray *assetsGroups) {
                if (assetsGroups.count > 0) {
                    weakSelf.assetsViewController.assetsGroup = [assetsGroups firstObject];
                }
            }];
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
    [self.childNavigationController pushViewController:self.assetsViewController animated:YES];
}


- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController {
    [self cancelPicking];
}


- (void)albumsViewControllerDidFinishPicking:(BUKAlbumsViewController *)viewController {
    [self finishPickingAssets];
}


#pragma mark - BUKAssetsViewControllerDelegate

- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController shouldSelectAsset:(ALAsset *)asset {
    return YES;
    // TODO: Check number of selected assets
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didSelectAsset:(ALAsset *)asset {
    [self.mutableSelectedAssets addObject:asset];
    NSLog(@"didSelectAsset, selectedAssets: %@", self.mutableSelectedAssets);
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didDeselectAsset:(ALAsset *)asset {
    [self.mutableSelectedAssets removeObject:asset];
    NSLog(@"didDeselectAsset, selectedAssets: %@", self.mutableSelectedAssets);
}


- (void)assetsViewControllerDidFinishPicking:(BUKAssetsViewController *)assetsViewController {
    [self finishPickingAssets];
}


#pragma mark - BUKCameraViewControllerDelegate

- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController {
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        [self cancelPicking];
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

- (void)cancelPicking {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerDidCancel:)]) {
        [self.delegate buk_imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)finishPickingAssets {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingAssets:)]) {
        [self.delegate buk_imagePickerController:self didFinishPickingAssets:self.selectedAssets];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
