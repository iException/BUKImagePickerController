//
//  BUKImagePickerController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKImagePickerController.h"
#import "BUKAssetsViewController.h"

@interface BUKImagePickerController () <BUKAssetsViewControllerDelegate>

@property (nonatomic, readwrite) NSMutableOrderedSet *selectedAssetURLs;
@property (nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation BUKImagePickerController

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
    BUKAssetsViewController *assetsViewController = [[BUKAssetsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:assetsViewController];
    
    [navigationController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:self];
    [navigationController endAppearanceTransition];
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
