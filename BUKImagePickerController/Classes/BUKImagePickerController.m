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

@property (nonatomic) NSMutableOrderedSet *mutableSelectedAssetURLs;
@property (nonatomic) BUKAssetsManager *assetsManager;
@property (nonatomic) UINavigationController *childNavigationController;

@end

@implementation BUKImagePickerController

#pragma mark - Accessors

- (void)setMinimumNumberOfSelection:(NSUInteger)minimumNumberOfSelection {
    _minimumNumberOfSelection = MAX(minimumNumberOfSelection, 1);
}


- (NSArray *)selectedAssetURLs {
    return [self.mutableSelectedAssetURLs array];
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
        _mutableSelectedAssetURLs = [NSMutableOrderedSet orderedSet];
        _mediaType = BUKImagePickerControllerMediaTypeImage;
        _sourceType = BUKImagePickerControllerSourceTypeLibrary;
        _allowsMultipleSelection = YES;
        _showsCameraCell = NO;
        _savesToPhotoLibrary = NO;
        _needsConfirmation = NO;
        _reversesAssets = NO;
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
            BUKAlbumsViewController *albumsViewController = [self createAlbumsViewController];
            BUKAssetsViewController *assetsViewController = [self createAssetsViewController];
            [self.childNavigationController setViewControllers:@[albumsViewController, assetsViewController]];
            viewController = self.childNavigationController;
            [self.assetsManager fetchAssetsGroupsWithCompletion:^(NSArray *assetsGroups) {
                if (assetsGroups.count > 0) {
                    assetsViewController.assetsGroup = [assetsGroups firstObject];
                }
            }];
            break;
        }
        case BUKImagePickerControllerSourceTypeLibrary: {
            BUKAlbumsViewController *albumsViewController = [self createAlbumsViewController];
            self.childNavigationController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
            viewController = self.childNavigationController;
            break;
        }
        case BUKImagePickerControllerSourceTypeCamera: {
            viewController = [self createCameraViewController];
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
    BUKAssetsViewController *assetsViewController = [self createAssetsViewController];
    assetsViewController.assetsGroup = assetsGroup;
    [self.childNavigationController pushViewController:assetsViewController animated:YES];
}


- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController {
    [self cancelPicking];
}


- (void)albumsViewControllerDidFinishPicking:(BUKAlbumsViewController *)viewController {
    [self finishPickingAssets];
}


- (BOOL)albumsViewControllerShouldEnableDoneButton:(BUKAlbumsViewController *)viewController {
    return [self isTotalNumberOfSelectedAssetsValid];
}


#pragma mark - BUKAssetsViewControllerDelegate

- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController shouldSelectAsset:(ALAsset *)asset {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:shouldSelectAsset:)]) {
        return [self.delegate buk_imagePickerController:self shouldSelectAsset:asset];
    }
    
    return !(self.minimumNumberOfSelection <= self.maximumNumberOfSelection && self.selectedAssetURLs.count >= self.maximumNumberOfSelection);
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didSelectAsset:(ALAsset *)asset {
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [self.mutableSelectedAssetURLs addObject:assetURL];
    
    if (!self.allowsMultipleSelection) {
        [self finishPickingAssets];
    }
}


- (void)assetsViewController:(BUKAssetsViewController *)assetsViewController didDeselectAsset:(ALAsset *)asset {
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [self.mutableSelectedAssetURLs removeObject:assetURL];
}


- (BOOL)assetsViewController:(BUKAssetsViewController *)assetsViewController isAssetSelected:(ALAsset *)asset {
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    return [self.selectedAssetURLs containsObject:assetURL];
}


- (void)assetsViewControllerDidFinishPicking:(BUKAssetsViewController *)assetsViewController {
    [self finishPickingAssets];
}


- (void)assetsViewControllerDidSelectCamera:(BUKAssetsViewController *)assetsViewController {
    self.savesToPhotoLibrary = YES;
    BUKCameraViewController *cameraViewController = [self createCameraViewController];
    [self.childNavigationController presentViewController:cameraViewController animated:YES completion:nil];
}


- (BOOL)assetsViewControllerShouldEnableDoneButton:(BUKAssetsViewController *)assetsViewController {
    return [self isTotalNumberOfSelectedAssetsValid];
}


#pragma mark - BUKCameraViewControllerDelegate

- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController {
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        [self cancelPicking];
    } else {
        [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)cameraViewController:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images {
    if (self.savesToPhotoLibrary) {
        [self.assetsManager writeImagesToSavedPhotosAlbum:images progress:^(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount) {
            [self.mutableSelectedAssetURLs addObject:assetURL];
        } completion:^(NSArray *assetsURLs, NSError *error) {
            NSLog(@"[BUKImagePickerController] Saved All Assets");
            if (self.sourceType != BUKImagePickerControllerSourceTypeCamera) {
                return;
            }
            
            [self.assetsManager fetchAssetsWithAssetURLs:assetsURLs progress:nil completion:^(NSArray *assets, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingAssets:)]) {
                    [self.delegate buk_imagePickerController:self didFinishPickingAssets:assets];
                }
            }];
        }];
    }
    
    if (self.sourceType != BUKImagePickerControllerSourceTypeCamera) {
        [cameraViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingImages:)]) {
        [self.delegate buk_imagePickerController:self didFinishPickingImages:images];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (BOOL)cameraViewControllerShouldTakePicture:(BUKCameraViewController *)cameraViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:shouldTakePictureWithCapturedImages:)]) {
        return [self.delegate buk_imagePickerController:self shouldTakePictureWithCapturedImages:cameraViewController.capturedFullImages];
    }
    
    NSUInteger numberOfCapturedImages = cameraViewController.capturedFullImages.count;
    BOOL result = self.minimumNumberOfSelection > self.maximumNumberOfSelection;
    
    return result || (self.selectedAssetURLs.count + numberOfCapturedImages) < self.maximumNumberOfSelection;
}


- (BOOL)cameraViewControllerShouldEnableDoneButton:(BUKCameraViewController *)cameraViewController {
    NSUInteger numberOfCapturedImages = cameraViewController.capturedFullImages.count;
    NSUInteger numberOfSelection = self.selectedAssetURLs.count;
    
    return [self isNumberOfSelectionValid:(numberOfSelection + numberOfCapturedImages)];
}


#pragma mark - Private

- (BUKAlbumsViewController *)createAlbumsViewController {
    BUKAlbumsViewController *albumsViewController = [[BUKAlbumsViewController alloc] init];
    albumsViewController.delegate = self;
    albumsViewController.assetsManager = self.assetsManager;
    albumsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    return albumsViewController;
}


- (BUKAssetsViewController *)createAssetsViewController {
    BUKAssetsViewController *assetsViewController = [[BUKAssetsViewController alloc] init];
    assetsViewController.delegate = self;
    assetsViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    assetsViewController.reversesAssets = self.reversesAssets;
    assetsViewController.showsCameraCell = self.showsCameraCell;
    assetsViewController.minimumInteritemSpacing = 2.0;
    assetsViewController.minimumLineSpacing = 4.0;
    assetsViewController.numberOfColumnsInPortrait = self.numberOfColumnsInPortrait;
    assetsViewController.numberOfColumnsInLandscape = self.numberOfColumnsInLandscape;
    return assetsViewController;
}


- (BUKCameraViewController *)createCameraViewController {
    BUKCameraViewController *cameraViewController = [[BUKCameraViewController alloc] init];
    cameraViewController.delegate = self;
    cameraViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    cameraViewController.needsConfirmation = self.needsConfirmation;
    return cameraViewController;
}


- (BOOL)isNumberOfSelectionValid:(NSUInteger)numberOfSelection {
    BOOL result = (numberOfSelection >= self.minimumNumberOfSelection);
    
    if (self.minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        result = result && numberOfSelection <= self.maximumNumberOfSelection;
    }
    
    return result;
}


- (BOOL)isTotalNumberOfSelectedAssetsValid {
    NSUInteger numberOfSelection = self.selectedAssetURLs.count;
    return [self isNumberOfSelectionValid:numberOfSelection];
}


- (void)cancelPicking {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerDidCancel:)]) {
        [self.delegate buk_imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)finishPickingAssets {
    [self.assetsManager fetchAssetsWithAssetURLs:self.selectedAssetURLs progress:nil completion:^(NSArray *assets, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingAssets:)]) {
            [self.delegate buk_imagePickerController:self didFinishPickingAssets:assets];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
