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
#import "BUKVideoIndicatorView.h"
#import "BUKAssetsManager.h"
#import "UIImage+BUKImagePickerController.h"

static NSString *const kBUKAlbumsViewControllerCellIdentifier = @"AssetCell";

@interface BUKAssetsViewController ()
@property (nonatomic, readwrite) NSArray *assets;
@end


@implementation BUKAssetsViewController

#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
    if (_assetsGroup == assetsGroup) {
        return;
    }
    
    _assetsGroup = assetsGroup;
    
    self.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [self updateAssets];
    [self.collectionView reloadData];
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
        
        layout.minimumInteritemSpacing = _minimumInteritemSpacing;
        layout.minimumLineSpacing = _minimumLineSpacing;
    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(finishPicking:)];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[BUKAssetCollectionViewCell class] forCellWithReuseIdentifier:kBUKAlbumsViewControllerCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
}


#pragma mark - Actions

- (void)finishPicking:(id)sender {
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
    return self.assets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BUKAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBUKAlbumsViewControllerCellIdentifier forIndexPath:indexPath];
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
    if ([self.delegate respondsToSelector:@selector(assetsViewController:didSelectAsset:)]) {
        ALAsset *asset = [self assetItemAtIndexPath:indexPath];
        [self.delegate assetsViewController:self didSelectAsset:asset];
        return;
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(assetsViewController:didDeselectAsset:)]) {
        ALAsset *asset = [self assetItemAtIndexPath:indexPath];
        [self.delegate assetsViewController:self didDeselectAsset:asset];
        return;
    }
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
    
    cell.showsOverlayViewWhenSelected = self.allowsMultipleSelection;
    cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    // Video indicator
    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
    
    if ([assetType isEqualToString:ALAssetTypeVideo]) {
        cell.videoIndicatorView.hidden = NO;
        
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        NSInteger minutes = (NSInteger)(duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
}


- (void)updateAssets {
    self.assets = [BUKAssetsManager assetsInAssetsGroup:self.assetsGroup reverse:self.reversesAssets];
}


#pragma mark - Handle Assets Library Changes

- (void)assetsLibraryChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *assetsGroupURL = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        NSSet *updatedAssetsGroupsURLs = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        for (NSURL *groupURL in updatedAssetsGroupsURLs) {
            if ([groupURL isEqual:assetsGroupURL]) {
                [self updateAssets];
                [self.collectionView reloadData];
            }
        }
    });
}

@end
