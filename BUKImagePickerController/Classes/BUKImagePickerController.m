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
#import "BUKAccessDeniedPlaceholderView.h"
#import "BUKAssetsManager.h"
#import "NSBundle+BUKImagePickerController.h"

@interface BUKImagePickerController () <BUKAssetsViewControllerDelegate, BUKAlbumsViewControllerDelegate, BUKCameraViewControllerDelegate>

@property (nonatomic) NSMutableOrderedSet *mutableSelectedAssetURLs;
@property (nonatomic) BUKAssetsManager *assetsManager;
@property (nonatomic) UINavigationController *childNavigationController;
@property (nonatomic) UIView *accessDeniedPlaceholderView;
@property (nonatomic, weak) BUKAssetsViewController *assetsViewController;
@property (nonatomic, weak) BUKAlbumsViewController *albumsViewController;

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
        _assetsManager.excludesEmptyGroups = self.excludesEmptyAlbums;
    }
    return _assetsManager;
}


- (UIView *)accessDeniedPlaceholderView {
    if (!_accessDeniedPlaceholderView) {
        _accessDeniedPlaceholderView = [[BUKAccessDeniedPlaceholderView alloc] init];
        _accessDeniedPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _accessDeniedPlaceholderView;
}


#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    if ((self = [super init])) {
        _mutableSelectedAssetURLs = [NSMutableOrderedSet orderedSet];
        _mediaType = BUKImagePickerControllerMediaTypeImage;
        _sourceType = BUKImagePickerControllerSourceTypeLibrary;
        _allowsMultipleSelection = YES;
        _excludesEmptyAlbums = NO;
        _showsCameraCell = NO;
        _savesToPhotoLibrary = NO;
        _needsConfirmation = NO;
        _reversesAssets = NO;
        _maxScaledDimension = 0;
        _usesScaledImage = NO;
        _showsNumberOfSelectedAssets = YES;
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
    
    // Check authorization status
    if ((self.sourceType == BUKImagePickerControllerSourceTypeSavedPhotosAlbum || self.sourceType == BUKImagePickerControllerSourceTypeLibrary) && [BUKAssetsManager isAccessDenied]) {
        [self showAccessDeniedView];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsAccessDenied:) name:kBUKImagePickerAccessDeniedNotificationName object:nil];
    
    // Setup view controllers
    UIViewController *viewController;
    switch (self.sourceType) {
        case BUKImagePickerControllerSourceTypeSavedPhotosAlbum: {
            self.childNavigationController = [[UINavigationController alloc] init];
            BUKAlbumsViewController *albumsViewController = [self createAlbumsViewController];
            BUKAssetsViewController *assetsViewController = [self createAssetsViewController];
            self.albumsViewController = albumsViewController;
            self.assetsViewController = assetsViewController;
            [self.childNavigationController setViewControllers:@[albumsViewController, assetsViewController]];
            viewController = self.childNavigationController;
            
            [self.assetsManager fetchAssetsGroupsWithCompletion:^(NSArray *assetsGroups) {
                if (assetsGroups.count > 0) {
                    assetsViewController.assetsGroup = [assetsGroups firstObject];
                }
            } failureBlock:nil];
            
            break;
        }
        case BUKImagePickerControllerSourceTypeLibrary: {
            BUKAlbumsViewController *albumsViewController = [self createAlbumsViewController];
            self.albumsViewController = albumsViewController;
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
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        return YES;
    }
    
    return [self.childNavigationController.topViewController prefersStatusBarHidden];
}


#pragma mark - BUKAlbumsViewControllerDelegate

- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup {
    BUKAssetsViewController *assetsViewController = [self createAssetsViewController];
    assetsViewController.assetsGroup = assetsGroup;
    self.assetsViewController = assetsViewController;
    [self.childNavigationController pushViewController:assetsViewController animated:YES];
}


- (void)albumsViewControllerDidCancel:(BUKAlbumsViewController *)viewController {
    [self cancelPicking];
}


- (void)albumsViewControllerDidFinishPicking:(BUKAlbumsViewController *)viewController {
    [self finishPickingAssets];
}


- (BOOL)albumsViewControllerShouldEnableDoneButton:(BUKAlbumsViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerShouldEnableDoneButton:)]) {
        return [self.delegate buk_imagePickerControllerShouldEnableDoneButton:self];
    }
    
    return [self isTotalNumberOfSelectedAssetsValid];
}


- (BOOL)albumsViewControllerShouldShowSelectionInfo:(BUKAlbumsViewController *)viewController {
    if (!self.showsNumberOfSelectedAssets) {
        return NO;
    }
    
    return self.mutableSelectedAssetURLs.count > 0;
}


- (NSString *)albumsViewControllerSelectionInfo:(BUKAlbumsViewController *)viewController {
    return [self selectionInfoWithNumberOfSelection:self.mutableSelectedAssetURLs.count];
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
    [self.childNavigationController pushViewController:cameraViewController animated:YES];
}


- (BOOL)assetsViewControllerShouldEnableDoneButton:(BUKAssetsViewController *)assetsViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerShouldEnableDoneButton:)]) {
        return [self.delegate buk_imagePickerControllerShouldEnableDoneButton:self];
    }
    
    return [self isTotalNumberOfSelectedAssetsValid];
}


- (BOOL)assetsViewControllerShouldShowSelectionInfo:(BUKAssetsViewController *)assetsViewController {
    if (!self.showsNumberOfSelectedAssets) {
        return NO;
    }
    
    return self.mutableSelectedAssetURLs.count > 0;
}


- (NSString *)assetsViewControllerSelectionInfo:(BUKAssetsViewController *)assetsViewController {
    return [self selectionInfoWithNumberOfSelection:self.mutableSelectedAssetURLs.count];
}


#pragma mark - BUKCameraViewControllerDelegate

- (void)userDeniedCameraPermissionsForCameraViewController:(BUKCameraViewController *)cameraViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerAccessDenied:)]) {
        [self.delegate buk_imagePickerControllerAccessDenied:self];
    }
}


- (void)cameraViewControllerDidCancel:(BUKCameraViewController *)cameraViewController {
    if (self.sourceType == BUKImagePickerControllerSourceTypeCamera) {
        [self cancelPicking];
    } else {
        [self.childNavigationController popViewControllerAnimated:YES];
        
        // Save photos to albums if needed
        NSArray *images = cameraViewController.capturedImages;
        if (images.count == 0) {
            return;
        }
        
        if (self.savesToPhotoLibrary) {
            if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:willSaveImages:)]) {
                [self.delegate buk_imagePickerController:self willSaveImages:images];
            }
            
            self.assetsViewController.ignoreChange = YES;
            
            [self.assetsManager writeImagesToSavedPhotosAlbum:images progress:^(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount) {
                if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:saveImages:withProgress:totalCount:)]) {
                    [self.delegate buk_imagePickerController:self saveImages:images withProgress:currentCount totalCount:totalCount];
                }
            } completion:^(NSArray *assetURLs, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishSavingImages:resultAssetURLs:)]) {
                    [self.delegate buk_imagePickerController:self didFinishSavingImages:images resultAssetURLs:assetURLs];
                }
                
                [self.assetsViewController updateAssets];
                self.assetsViewController.ignoreChange = NO;
                
                [self.mutableSelectedAssetURLs addObjectsFromArray:assetURLs];
            }];
        }
    }
}


- (void)cameraViewController:(BUKCameraViewController *)cameraViewController didFinishCapturingImages:(NSArray *)images {
    if (self.savesToPhotoLibrary) {
        if (images.count == 0) {
            [self finishPickingAssets];
            return;
        }
        
        // Start saving
        if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:willSaveImages:)]) {
            [self.delegate buk_imagePickerController:self willSaveImages:images];
        }
        self.assetsViewController.ignoreChange = YES;
        
        [self.assetsManager writeImagesToSavedPhotosAlbum:images progress:^(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount) {
            if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:saveImages:withProgress:totalCount:)]) {
                [self.delegate buk_imagePickerController:self saveImages:images withProgress:currentCount totalCount:totalCount];
            }
        } completion:^(NSArray *assetURLs, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishSavingImages:resultAssetURLs:)]) {
                [self.delegate buk_imagePickerController:self didFinishSavingImages:images resultAssetURLs:assetURLs];
            }
            [self.mutableSelectedAssetURLs addObjectsFromArray:assetURLs];
            [self finishPickingAssets];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:didFinishPickingImages:)]) {
            [self.delegate buk_imagePickerController:self didFinishPickingImages:images];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (BOOL)cameraViewControllerShouldTakePicture:(BUKCameraViewController *)cameraViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerController:shouldTakePictureWithCapturedImages:)]) {
        return [self.delegate buk_imagePickerController:self shouldTakePictureWithCapturedImages:cameraViewController.capturedImages];
    }
    
    NSUInteger numberOfCapturedImages = cameraViewController.capturedImages.count;
    BOOL result = self.minimumNumberOfSelection > self.maximumNumberOfSelection;
    
    return result || (self.selectedAssetURLs.count + numberOfCapturedImages) < self.maximumNumberOfSelection;
}


- (BOOL)cameraViewControllerShouldEnableDoneButton:(BUKCameraViewController *)cameraViewController {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerShouldEnableDoneButton:)]) {
        return [self.delegate buk_imagePickerControllerShouldEnableDoneButton:self];
    }
    
    NSUInteger numberOfCapturedImages = cameraViewController.capturedImages.count;
    NSUInteger numberOfSelection = self.selectedAssetURLs.count;
    
    return [self isNumberOfSelectionValid:(numberOfSelection + numberOfCapturedImages)];
}


- (BOOL)cameraViewControllerShouldShowSelectionInfo:(BUKCameraViewController *)cameraViewController {
    if (!self.showsNumberOfSelectedAssets) {
        return NO;
    }
    
    NSUInteger numberOfCapturedImages = cameraViewController.capturedImages.count;
    NSUInteger numberOfSelection = self.selectedAssetURLs.count;
    return (numberOfCapturedImages + numberOfSelection) > 0;
}


- (NSString *)cameraViewControllerSelectionInfo:(BUKCameraViewController *)cameraViewController {
    return [self selectionInfoWithNumberOfSelection:(cameraViewController.capturedImages.count + self.mutableSelectedAssetURLs.count)];
}


#pragma mark - Private

- (void)assetsAccessDenied:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(buk_imagePickerControllerAccessDenied:)]) {
        [self.delegate buk_imagePickerControllerAccessDenied:self];
    }
    
    [self showAccessDeniedView];
}


- (void)showAccessDeniedView {
    if (self.accessDeniedPlaceholderView.superview) {
        return;
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPicking)];
    
    UIView *view = viewController.view;
    [view addSubview:self.accessDeniedPlaceholderView];
    
    // Add constraints
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.accessDeniedPlaceholderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.accessDeniedPlaceholderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.accessDeniedPlaceholderView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.accessDeniedPlaceholderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self fastttAddChildViewController:navigationController];
}


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
    cameraViewController.usesScaledImage = self.usesScaledImage;
    cameraViewController.maxScaledDimension = self.maxScaledDimension;
    return cameraViewController;
}


- (NSString *)selectionInfoWithNumberOfSelection:(NSInteger)count {
    NSString *text = nil;
    if (self.maximumNumberOfSelection > 0) {
        text = [NSString stringWithFormat:BUKImagePickerLocalizedString(@"Selected: %@/%@", nil), @(count), @(self.maximumNumberOfSelection)];
    } else {
        text = [NSString stringWithFormat:BUKImagePickerLocalizedString(@"Selected: %@", nil), @(count)];
    }
    return text;
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
