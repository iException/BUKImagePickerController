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

- (void)setMinimumNumberOfSelection:(NSUInteger)minimumNumberOfSelection {
    _minimumNumberOfSelection = MAX(minimumNumberOfSelection, 1);
}


- (NSArray *)selectedAssets {
    return [self.mutableSelectedAssets copy];
}


- (BUKAlbumsViewController *)albumsViewController {
    if (!_albumsViewController) {
        _albumsViewController = [[BUKAlbumsViewController alloc] init];
        _albumsViewController.delegate = self;
        _albumsViewController.assetsManager = self.assetsManager;
        _albumsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    }
    return _albumsViewController;
}


- (BUKAssetsViewController *)assetsViewController {
    if (!_assetsViewController) {
        _assetsViewController = [[BUKAssetsViewController alloc] init];
        _assetsViewController.delegate = self;
        _assetsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        _assetsViewController.reversesAssets = self.reversesAssets;
        _assetsViewController.showsCameraCell = self.showsCameraCell;
        _assetsViewController.minimumInteritemSpacing = 2.0;
        _assetsViewController.minimumLineSpacing = 4.0;
        _assetsViewController.numberOfColumnsInPortrait = self.numberOfColumnsInPortrait;
        _assetsViewController.numberOfColumnsInLandscape = self.numberOfColumnsInLandscape;
    }
    return _assetsViewController;
}


- (BUKCameraViewController *)cameraViewController {
    if (!_cameraViewController) {
        _cameraViewController = [[BUKCameraViewController alloc] init];
        _cameraViewController.delegate = self;
        _cameraViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        _cameraViewController.savesToPhotoLibrary = self.savesToPhotoLibrary;
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
        _sourceType = BUKImagePickerControllerSourceTypeLibrary;
        _allowsMultipleSelection = YES;
        _showsCameraCell = NO;
        _savesToPhotoLibrary = NO;
        _numberOfColumnsInPortrait = 4;
        _numberOfColumnsInLandscape = 7;
        _minimumNumberOfSelection = 1;
        _maximumNumberOfSelection = 0;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *viewController;
    switch (self.sourceType) {
        case BUKImagePickerControllerSourceTypeSavedPhotosAlbum: {
            self.childNavigationController = [[UINavigationController alloc] init];
            [self.childNavigationController setViewControllers:@[self.albumsViewController, self.assetsViewController]];
            viewController = self.childNavigationController;
            __weak typeof(self)weakSelf = self;
            [self.assetsManager fetchAssetsGroupsWithCompletion:^(NSArray *assetsGroups) {
                if (assetsGroups.count > 0) {
                    weakSelf.assetsViewController.assetsGroup = [assetsGroups firstObject];
                }
            }];
            break;
        }
        case BUKImagePickerControllerSourceTypeLibrary: {
            self.childNavigationController = [[UINavigationController alloc] initWithRootViewController:self.albumsViewController];
            viewController = self.childNavigationController;
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


- (BOOL)albumsViewControllerShouldEnableDoneButton:(BUKAlbumsViewController *)viewController {
    return [self isNumberOfSelectionValid];
}


#pragma mark - BUKAssetsViewControllerDelegate

- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController shouldSelectAsset:(ALAsset *)asset {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:shouldSelectAsset:)]) {
        return [self.delegate buk_imagePickerController:self shouldSelectAsset:asset];
    }
    
    return !(self.minimumNumberOfSelection <= self.maximumNumberOfSelection && self.selectedAssets.count >= self.maximumNumberOfSelection);
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didSelectAsset:(ALAsset *)asset {
    [self.mutableSelectedAssets addObject:asset];
    
    if (!self.allowsMultipleSelection) {
        [self finishPickingAssets];
    }
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didDeselectAsset:(ALAsset *)asset {
    [self.mutableSelectedAssets removeObject:asset];
}


- (void)assetsViewControllerDidFinishPicking:(BUKAssetsViewController *)assetsViewController {
    [self finishPickingAssets];
}


- (void)assetsViewControllerDidSelectCamera:(BUKAssetsViewController *)assetsViewController {
    self.cameraViewController.savesToPhotoLibrary = YES;
    [self.childNavigationController pushViewController:self.cameraViewController animated:YES];
}


- (BOOL)assetsViewControllerShouldEnableDoneButton:(BUKAssetsViewController *)assetsViewController {
    return [self isNumberOfSelectionValid];
}


#pragma mark - BUKCameraViewControllerDelegate

- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController {
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        [self cancelPicking];
    } else {
        [self childNavigationController];
    }
}


- (void)cameraViewController:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingImages:)]) {
        [self.delegate buk_imagePickerController:self didFinishPickingImages:images];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)cameraViewControllerShouldEnableDoneButton:(BUKCameraViewController *)cameraViewController {
    return YES;
}


#pragma mark - Private

- (BOOL)isNumberOfSelectionValid {
    NSUInteger count = self.selectedAssets.count;
    BOOL result = (count >= self.minimumNumberOfSelection);
    
    if (self.minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        result = result && count <= self.maximumNumberOfSelection;
    }
    
    return result;
}


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
