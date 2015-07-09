//
//  BUKAssetsViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/8/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;

#import "BUKAssetsViewController.h"
#import "BUKImagePickerController.h"
#import "BUKAssetCollectionViewCell.h"

static NSString *const kCellReuseIdentifier = @"AssetCell";

@interface BUKAssetsViewController ()

@property (nonatomic, readwrite) NSArray *assets;
@property (nonatomic, readwrite) NSMutableOrderedSet *selectedAssetURLs;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGFloat minimumLineSpacing;

@end

@implementation BUKAssetsViewController

#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
    if (_assetsGroup == assetsGroup) {
        return;
    }
    
    _assetsGroup = assetsGroup;
    
    // TODO: Update assets and reload data
}


#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if ((self = [super initWithCollectionViewLayout:layout])) {
        _minimumInteritemSpacing = 2.0;
        _minimumLineSpacing = 2.0;
        _selectedAssetURLs = [NSMutableOrderedSet orderedSet];
        
        layout.minimumInteritemSpacing = _minimumInteritemSpacing;
        layout.minimumLineSpacing = _minimumLineSpacing;
    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(finishPicking:)];
    
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[BUKAssetCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    
    // Register observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
}


#pragma mark - Actions

- (void)cancel:(id)sender {
    NSLog(@"Cancel");
    
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerDidCancel:)]) {
        [self.delegate assetsViewControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)finishPicking:(id)sender {
    NSLog(@"Did Finish Picking");
    
    if ([self.delegate respondsToSelector:@selector(assetsViewController:didFinishPickingAssets:)]) {
        [self.delegate assetsViewController:self didFinishPickingAssets:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BUKAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(assetsViewController:shouldSelectAsset:)]) {
        ALAsset *asset = [self assetItemAtIndexPath:indexPath];
        return [self.delegate assetsViewController:self shouldSelectAsset:asset];
    }
    
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        numberOfColumns = self.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.numberOfColumnsInLandscape;
    }

    CGFloat width = (self.view.bounds.size.width - 2.0 * (numberOfColumns + 1)) / numberOfColumns;

    return CGSizeMake(width, width);
}


#pragma mark - Private

- (ALAsset *)assetItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.assets[indexPath.item];
}


- (void)configureCell:(BUKAssetCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self assetItemAtIndexPath:indexPath];
    
    // TODO:
}


- (void)assetsLibraryChanged:(NSNotification *)notification {
    
}

@end
