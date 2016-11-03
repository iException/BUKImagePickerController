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
#import "BUKCameraCollectionViewCell.h"
#import "BUKVideoIndicatorView.h"
#import "BUKNoAssetsPlaceholderView.h"
#import "BUKAssetsManager.h"
#import "UIImage+BUKImagePickerController.h"
#import "NSBundle+BUKImagePickerController.h"

static NSString *const kBUKAssetsViewControllerAssetCellIdentifier = @"AssetCell";
static NSString *const kBUKAssetsViewControllerCameraCellIdentifier = @"CameraCell";


@interface BUKAssetsViewController ()
@property (nonatomic, readwrite) NSArray *assets;
@property (nonatomic) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic) UIView *placeholderView;
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
        _ignoreChange = NO;
        
        layout.minimumInteritemSpacing = _minimumInteritemSpacing;
        layout.minimumLineSpacing = _minimumLineSpacing;
    }
    
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.allowsMultipleSelection) {
        self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(finishPicking:)];
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    
    [self setUpToolbar];
    
    // Configure collection view
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    [self.collectionView registerClass:[BUKAssetCollectionViewCell class] forCellWithReuseIdentifier:kBUKAssetsViewControllerAssetCellIdentifier];
    [self.collectionView registerClass:[BUKCameraCollectionViewCell class] forCellWithReuseIdentifier:kBUKAssetsViewControllerCameraCellIdentifier];
    
    self.placeholderView = [[BUKNoAssetsPlaceholderView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    
    [self updateAssets];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateDoneButton];
    [self scrollToLatestPhotos];
    [self updateSelectionInfo];
}


#pragma mark - Actions

- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerDidCancel:)]) {
        [self.delegate assetsViewControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)finishPicking:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerDidFinishPicking:)]) {
        [self.delegate assetsViewControllerDidFinishPicking:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.showsCameraCell ? self.assets.count + 1 : self.assets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.item == 0 && self.showsCameraCell) {
        BUKCameraCollectionViewCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBUKAssetsViewControllerCameraCellIdentifier forIndexPath:indexPath];
        cell = cameraCell;
    } else {
        BUKAssetCollectionViewCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBUKAssetsViewControllerAssetCellIdentifier forIndexPath:indexPath];
        [self configureCell:assetCell forItemAtIndexPath:indexPath];
        cell = assetCell;
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showsCameraCell && indexPath.item == 0) {
        if ([self.delegate respondsToSelector:@selector(assetsViewControllerDidSelectCamera:)]) {
            [self.delegate assetsViewControllerDidSelectCamera:self];
        }
        return NO;
    }
    
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
    }
    
    [self updateDoneButton];
    [self updateSelectionInfo];
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(assetsViewController:didDeselectAsset:)]) {
        ALAsset *asset = [self assetItemAtIndexPath:indexPath];
        [self.delegate assetsViewController:self didDeselectAsset:asset];
    }
    
    [self updateDoneButton];
    [self updateSelectionInfo];
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

- (BOOL)hasContent {
    return self.assets.count > 0 || self.showsCameraCell;
}


- (void)updatePlaceholderView:(BOOL)animated {
    if (![self hasContent]) {
        [self showPlacehoderView:animated];
    } else {
        [self hidePlaceholderView:animated];
    }
}


- (void)showPlacehoderView:(BOOL)animated {
    if (!self.placeholderView || self.placeholderView.superview) {
        return;
    }
    
    self.placeholderView.alpha = 0;
    self.placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.placeholderView];
    
    // Add constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.placeholderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.placeholderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.placeholderView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.placeholderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    void (^change)(void) = ^{
        self.placeholderView.alpha = 1.0f;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
    } else {
        change();
    }
}


- (void)hidePlaceholderView:(BOOL)animated {
    if (!self.placeholderView || !self.placeholderView.superview) {
        return;
    }
    
    void (^change)(void) = ^{
        self.placeholderView.alpha = 0.0f;
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished) {
        [self.placeholderView removeFromSuperview];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
    } else {
        change();
        completion(YES);
    }
}


- (void)setUpToolbar {
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14.0],
    };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}


- (void)updateSelectionInfo {
    BOOL shouldShow = NO;
    NSString *text = nil;
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerShouldShowSelectionInfo:)]) {
        shouldShow = [self.delegate assetsViewControllerShouldShowSelectionInfo:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerSelectionInfo:)]) {
        text = [self.delegate assetsViewControllerSelectionInfo:self];
    }
    
    shouldShow = shouldShow && text != nil;
    
    if (shouldShow) {
        UIBarButtonItem *barButtonItem = self.toolbarItems[1];
        barButtonItem.title = text;
    }
    
    BOOL shoulHidden = !shouldShow;
    if (shoulHidden != self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:shoulHidden animated:YES];
    }
}


- (void)scrollToLatestPhotos {
    if (self.reversesAssets) {
        NSInteger section = 0;
        NSInteger count = [self collectionView:self.collectionView numberOfItemsInSection:section] ;
        if (count > 0) {
            // Make sure the collection view scrolls to the bottom, it's a little tricky though.
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            });
        }
    } else {
        NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
        NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:section] - 1;
        if (item >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            });
        }
    }
}


- (void)updateDoneButton {
    if ([self.delegate respondsToSelector:@selector(assetsViewControllerShouldEnableDoneButton:)]) {
        self.doneBarButtonItem.enabled = [self.delegate assetsViewControllerShouldEnableDoneButton:self];
    } else {
        self.doneBarButtonItem.enabled = YES;
    }
}


- (NSUInteger)assetIndexForViewIndexPath:(NSIndexPath *)indexPath {
    return self.showsCameraCell ? indexPath.item - 1 : indexPath.item;
}


- (NSIndexPath *)viewIndexPathForAssetsIndex:(NSUInteger)index {
    return self.showsCameraCell ? [NSIndexPath indexPathForItem:(index + 1) inSection:0] : [NSIndexPath indexPathForItem:index inSection:0];
}


- (ALAsset *)assetItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.assets[[self assetIndexForViewIndexPath:indexPath]];
}


- (void)configureCell:(BUKAssetCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self assetItemAtIndexPath:indexPath];
    
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.allowsMultipleSelection;
    
    // Load thumbnail asynchronously
    __weak BUKAssetCollectionViewCell *weakCell = cell;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (weakCell.tag == indexPath.item) {
                cell.imageView.image = thumbnailImage;
            }
        });
    });
    
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
    
    // Select
    if ([self.delegate respondsToSelector:@selector(assetsViewController:isAssetSelected:)]) {
        BOOL selected = [self.delegate assetsViewController:self isAssetSelected:asset];
        cell.selected = selected;
        if (selected) {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}


- (void)updateAssets {
    self.assets = [BUKAssetsManager assetsInAssetsGroup:self.assetsGroup reverse:self.reversesAssets];
    
    if (self.isViewLoaded) {
        [self updatePlaceholderView:NO];
        [self.collectionView reloadData];
        [self updateSelectionInfo];
    }
}


#pragma mark - Handle Assets Library Changes

- (void)assetsLibraryChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.ignoreChange) {
            return;
        }
        
        NSURL *assetsGroupURL = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        NSSet *updatedAssetsGroupsURLs = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        for (NSURL *groupURL in updatedAssetsGroupsURLs) {
            if ([groupURL isEqual:assetsGroupURL]) {
                [self updateAssets];
            }
        }
    });
}

@end
