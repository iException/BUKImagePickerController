//
//  BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKImagePickerController.h"
#import "BUKAssetsViewController.h"
#import "BUKAlbumsViewController.h"

@interface BUKImagePickerController () <BUKAssetsViewControllerDelegate, BUKAlbumsViewControllerDelegate>

@property (nonatomic, readwrite) NSMutableOrderedSet *selectedAssetURLs;
@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) BUKAlbumsViewController *albumsViewController;
@property (nonatomic) BUKAssetsViewController *assetsViewController;

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


#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _selectedAssetURLs = [NSMutableOrderedSet orderedSet];
        _mediaType = BUKImagePickerMediaTypeImage;
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
    
    
    // Add child view controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.assetsViewController];
    [navigationController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:self];
    [navigationController endAppearanceTransition];
}


#pragma mark - BUKAlbumsViewControllerDelegate

- (void)albumsViewController:(BUKAlbumsViewController *)viewController didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self.assetsViewController.assetsGroup = assetsGroup;
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

@end
