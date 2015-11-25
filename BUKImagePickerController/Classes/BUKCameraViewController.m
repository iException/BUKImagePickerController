//
//  BUKCameraViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import <FastttCamera/FastttCamera.h>
#import "BUKCameraViewController.h"
#import "BUKCameraConfirmViewController.h"
#import "BUKCameraImageCollectionViewCell.h"
#import "UIImage+BUKImagePickerController.h"
#import "NSBundle+BUKImagePickerController.h"

static NSString *const kBUKCameraViewControllerCellIdentifier = @"cell";

@interface BUKCameraViewController () <FastttCameraDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BUKCameraImageCollectionViewCellDelegate, BUKCameraConfirmViewControllerDelegate>

@property (nonatomic) UIButton *takePictureButton;
@property (nonatomic) UIButton *flashModeButton;
@property (nonatomic) UIButton *cameraDeviceButton;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UILabel *selectionInfoLabel;
@property (nonatomic) UIView *topToolbarView;
@property (nonatomic) UIView *bottomToolbarView;
@property (nonatomic) UIView *flashView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *mutableCapturedImages;
@property (nonatomic) FastttCameraFlashMode flashMode;
@property (nonatomic) FastttCameraDevice cameraDevice;

@end


@implementation BUKCameraViewController

#pragma mark - Accessors

@synthesize fastCamera = _fastCamera;
@dynamic flashMode;
@dynamic cameraDevice;

- (FastttCamera *)fastCamera {
    if (!_fastCamera) {
        _fastCamera = [[FastttCamera alloc] init];
        _fastCamera.delegate = self;
        _fastCamera.normalizesImageOrientations = NO;
        _fastCamera.returnsRotatedPreview = self.needsConfirmation;
        if (self.usesScaledImage) {
            if (self.maxScaledDimension > 0) {
                _fastCamera.maxScaledDimension = self.maxScaledDimension;
            }
        } else {
            _fastCamera.maxScaledDimension = MAX(self.thumbnailSize.width, self.thumbnailSize.height);
        }
    }
    return _fastCamera;
}


- (UIButton *)takePictureButton {
    if (!_takePictureButton) {
        _takePictureButton = [[UIButton alloc] init];
        _takePictureButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_takePictureButton setImage:[UIImage buk_bundleImageNamed:@"take-picture-button"] forState:UIControlStateNormal];
        [_takePictureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePictureButton;
}


- (UIButton *)flashModeButton {
    if (!_flashModeButton) {
        _flashModeButton = [[UIButton alloc] init];
        _flashModeButton.translatesAutoresizingMaskIntoConstraints = NO;
        _flashModeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_flashModeButton setImage:[UIImage buk_bundleImageNamed:@"flash-button"] forState:UIControlStateNormal];
        [_flashModeButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashModeButton;
}


- (UIButton *)cameraDeviceButton {
    if (!_cameraDeviceButton) {
        _cameraDeviceButton = [[UIButton alloc] init];
        _cameraDeviceButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraDeviceButton setImage:[UIImage buk_bundleImageNamed:@"device-button"] forState:UIControlStateNormal];
        [_cameraDeviceButton addTarget:self action:@selector(toggleCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraDeviceButton;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitle:BUKImagePickerLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_doneButton setTitle:BUKImagePickerLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}


- (UILabel *)selectionInfoLabel {
    if (!_selectionInfoLabel) {
        _selectionInfoLabel = [[UILabel alloc] init];
        _selectionInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _selectionInfoLabel.font = [UIFont systemFontOfSize:14.0];
        _selectionInfoLabel.textColor = [UIColor orangeColor];
        _selectionInfoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _selectionInfoLabel;
}


- (UIView *)topToolbarView {
    if (!_topToolbarView) {
        _topToolbarView = [[UIView alloc] init];
        _topToolbarView.translatesAutoresizingMaskIntoConstraints = NO;
        _topToolbarView.backgroundColor = [UIColor blackColor];
    }
    return _topToolbarView;
}


- (UIView *)bottomToolbarView {
    if (!_bottomToolbarView) {
        _bottomToolbarView = [[UIView alloc] init];
        _bottomToolbarView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomToolbarView.backgroundColor = [UIColor blackColor];
    }
    return _bottomToolbarView;
}


- (UIView *)flashView {
    if (!_flashView) {
        _flashView = [[UIView alloc] init];
        _flashView.translatesAutoresizingMaskIntoConstraints = NO;
        _flashView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0];
    }
    return _flashView;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = self.thumbnailSize;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);
        flowLayout.minimumInteritemSpacing = 4.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[BUKCameraImageCollectionViewCell class] forCellWithReuseIdentifier:kBUKCameraViewControllerCellIdentifier];
    }
    return _collectionView;
}


- (FastttCameraFlashMode)flashMode {
    return self.fastCamera.cameraFlashMode;
}


- (void)setFlashMode:(FastttCameraFlashMode)flashMode {
    NSString *title;
    switch (flashMode) {
        case FastttCameraFlashModeAuto:
            title = BUKImagePickerLocalizedString(@"Flash Auto", nil);
            break;
        case FastttCameraFlashModeOn:
            title = BUKImagePickerLocalizedString(@"Flash On", nil);
            break;
        case FastttCameraFlashModeOff:
            title = BUKImagePickerLocalizedString(@"Flash Off", nil);
            break;
    }
    
    [self.flashModeButton setTitle:title forState:UIControlStateNormal];
    self.fastCamera.cameraFlashMode = flashMode;
}


- (FastttCameraDevice)cameraDevice {
    return self.fastCamera.cameraDevice;
}


- (void)setCameraDevice:(FastttCameraDevice)cameraDevice {
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
        self.flashModeButton.hidden = ![FastttCamera isFlashAvailableForCameraDevice:cameraDevice];
    }
}


- (NSArray *)capturedImages {
    NSMutableArray *mutableFullImages = [NSMutableArray arrayWithCapacity:self.mutableCapturedImages.count];
    if (self.usesScaledImage) {
        for (FastttCapturedImage *capturedImage in self.mutableCapturedImages) {
            [mutableFullImages addObject:capturedImage.scaledImage];
        }
    } else {
        for (FastttCapturedImage *capturedImage in self.mutableCapturedImages) {
            [mutableFullImages addObject:capturedImage.fullImage];
        }
    }
    return mutableFullImages;
}


#pragma mark - NSObject

- (instancetype)init {
    if ((self = [super init])) {
        _thumbnailSize = CGSizeMake(72.0, 72.0);
        _mutableCapturedImages = [NSMutableArray array];
        _needsConfirmation = NO;
        _allowsMultipleSelection = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Camera view
    [self fastttAddChildViewController:self.fastCamera];
    self.fastCamera.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Top toolbar
    [self.topToolbarView addSubview:self.flashModeButton];
    [self.topToolbarView addSubview:self.cameraDeviceButton];
    [self.topToolbarView addSubview:self.selectionInfoLabel];
    [self.view addSubview:self.topToolbarView];
    
    // Bottom toolbar
    [self.bottomToolbarView addSubview:self.takePictureButton];
    [self.bottomToolbarView addSubview:self.cancelButton];
    [self.bottomToolbarView addSubview:self.doneButton];
    [self.view addSubview:self.bottomToolbarView];
    
    // Collection view
    [self.view addSubview:self.collectionView];
    
    [self setupViewConstraints];
    
    self.flashMode = FastttCameraFlashModeOff;
    self.cameraDevice = FastttCameraDeviceRear;
    
    self.doneButton.hidden = !self.allowsMultipleSelection;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    [self updateDoneButton];
    [self updateSelectionInfo];
    
    // Ugly hack
    // If pushed, set cancel button title "Back";
    if (self.navigationController.viewControllers.count > 1) {
        [self.cancelButton setTitle:BUKImagePickerLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


#pragma mark - Actions

- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidCancel:)]) {
        [self.delegate cameraViewControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didFinishCapturingImages:)]) {
        [self.delegate cameraViewController:self didFinishCapturingImages:self.capturedImages];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)takePicture:(id)sender {
    BOOL shouldTakePicture = YES;
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerShouldTakePicture:)]) {
        shouldTakePicture = [self.delegate cameraViewControllerShouldTakePicture:self];
    }
    
    if (shouldTakePicture) {
        [self.fastCamera takePicture];
    }
}


- (void)toggleFlashMode:(id)sender {
    FastttCameraFlashMode flashMode;
    switch (self.flashMode) {
        case FastttCameraFlashModeAuto:
            flashMode = FastttCameraFlashModeOn;
            break;
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            break;
        case FastttCameraFlashModeOff:
            flashMode = FastttCameraFlashModeAuto;
            break;
    }
    
    self.flashMode = flashMode;
}


- (void)toggleCameraDevice:(id)sender {
    FastttCameraDevice cameraDevice;
    switch (self.cameraDevice) {
        case FastttCameraDeviceFront:
            cameraDevice = FastttCameraDeviceRear;
            break;
        case FastttCameraDeviceRear:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    
    self.cameraDevice = cameraDevice;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mutableCapturedImages.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BUKCameraImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBUKCameraViewControllerCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"[BUKImagePickerController] didSelectItemAtIndexPath");
}


#pragma mark - FastttCameraDelegate

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage {
    if (!self.needsConfirmation) {
        [self flashAnimated:YES completion:nil];
        return;
    }
    
    // Confirm
    BUKCameraConfirmViewController *confirmViewController = [[BUKCameraConfirmViewController alloc] init];
    confirmViewController.delegate = self;
    confirmViewController.capturedImage = capturedImage;
    
    __weak typeof(self)weakSelf = self;
    [self flashAnimated:YES completion:^{
        NSDictionary *views = @{
            @"confirmView": confirmViewController.view,
        };
        [weakSelf fastttAddChildViewController:confirmViewController belowSubview:weakSelf.flashView];
        [weakSelf.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[confirmView]|" options:kNilOptions metrics:nil views:views]];
        [weakSelf.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[confirmView]|" options:kNilOptions metrics:nil views:views]];
    }];
}


- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage {
    if (self.needsConfirmation) {
        return;
    }
    
    [self addCapturedImage:capturedImage];
}


- (void)userDeniedCameraPermissionsForCameraController:(id<FastttCameraInterface>)cameraController {
    if ([self.delegate respondsToSelector:@selector(userDeniedCameraPermissionsForCameraViewController:)]) {
        [self.delegate userDeniedCameraPermissionsForCameraViewController:self];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:BUKImagePickerLocalizedString(@"Access Denied", nil)
                                                        message:BUKImagePickerLocalizedString(@"You can enable access in \"Settings\" -> \"Privacy\" -> \"Camera\".", nil)
                                                       delegate:nil
                                              cancelButtonTitle:BUKImagePickerLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - BUKImageCollectionViewCellDelegate

- (void)imageCollectionViewCell:(BUKCameraImageCollectionViewCell *)cell didClickDeleteButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    [self removeImageAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    [self updateDoneButton];
    [self updateSelectionInfo];
}


#pragma mark - BUKCameraConfirmViewControllerDelegate

- (void)cameraConfirmViewControllerDidCancel:(BUKCameraConfirmViewController *)viewController {
    [self fastttRemoveChildViewController:viewController];
}


- (void)cameraConfirmViewControllerDidConfirm:(BUKCameraConfirmViewController *)viewController capturedImage:(FastttCapturedImage *)capturedImage {
    [self addCapturedImage:capturedImage];
    [self fastttRemoveChildViewController:viewController];
}


#pragma mark - Private

- (void)addCapturedImage:(FastttCapturedImage *)capturedImage {
    if (!capturedImage || !capturedImage.fullImage || !capturedImage.scaledImage) {
        return;
    }
    
    // Since we don't need preview image, release it to save memory.
    capturedImage.rotatedPreviewImage = nil;
    if (self.usesScaledImage) {
        // If the client want to use scaled image, release the full image data.
        capturedImage.fullImage = nil;
    }
    
    [self.mutableCapturedImages addObject:capturedImage];
    
    if (!self.allowsMultipleSelection) {
        [self done:nil];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.mutableCapturedImages.count - 1) inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    [self updateDoneButton];
    [self updateSelectionInfo];
}


- (void)updateDoneButton {
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerShouldEnableDoneButton:)]) {
        self.doneButton.enabled = [self.delegate cameraViewControllerShouldEnableDoneButton:self];
    } else {
        self.doneButton.enabled = YES;
    }
}


- (void)updateSelectionInfo {
    BOOL shouldShow = NO;
    NSString *text = nil;
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerShouldShowSelectionInfo:)]) {
        shouldShow = [self.delegate cameraViewControllerShouldShowSelectionInfo:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerSelectionInfo:)]) {
        text = [self.delegate cameraViewControllerSelectionInfo:self];
    }
    
    shouldShow = shouldShow && text != nil;
    
    if (shouldShow) {
        self.selectionInfoLabel.text = text;
    } else {
        self.selectionInfoLabel.text = nil;
    }
}


- (void)flashAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.flashView.superview) {
        return;
    }
    
    self.flashView.alpha = 0;
    [self.view addSubview:self.flashView];
    
    UIView *cameraView = self.fastCamera.view;
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.flashView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cameraView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
        [NSLayoutConstraint constraintWithItem:self.flashView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cameraView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
        [NSLayoutConstraint constraintWithItem:self.flashView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cameraView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
        [NSLayoutConstraint constraintWithItem:self.flashView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cameraView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
    ]];
    
    __weak typeof(self)weakSelf = self;
    void (^change)(void) = ^{
        weakSelf.flashView.alpha = 1.0;
    };
    
    void (^animationCompletionBlock)(BOOL finished) = ^(BOOL finished) {
        if (completion) {
            completion();
        }
        [weakSelf hideFlashView:animated];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:change completion:animationCompletionBlock];
    } else {
        change();
        animationCompletionBlock(YES);
    }
}


- (void)hideFlashView:(BOOL)animated {
    if (!self.flashView.superview) {
        return;
    }
    
    void (^change)(void) = ^{
        self.flashView.alpha = 0.0f;
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished) {
        [self.flashView removeFromSuperview];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.15f delay:0.05f options:UIViewAnimationOptionCurveEaseOut animations:change completion:completion];
    } else {
        change();
        completion(YES);
    }
}


- (void)removeImageAtIndex:(NSUInteger)index {
    NSUInteger count = self.mutableCapturedImages.count;
    if (index >= count) {
        return;
    }
    
    [self.mutableCapturedImages removeObjectAtIndex:index];
}


- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.mutableCapturedImages objectAtIndex:indexPath.item];
}


- (void)configureCell:(BUKCameraImageCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    FastttCapturedImage *capturedImage = [self objectAtIndexPath:indexPath];
    cell.imageView.image = capturedImage.scaledImage;
    cell.delegate = self;
}


- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"topToolbarView": self.topToolbarView,
        @"bottomToolbarView": self.bottomToolbarView,
        @"cameraView": self.fastCamera.view,
        @"flashModeButton": self.flashModeButton,
        @"selectionInfoLabel": self.selectionInfoLabel,
        @"cameraDeviceButton": self.cameraDeviceButton,
        @"takePictureButton": self.takePictureButton,
        @"doneButton": self.doneButton,
        @"cancelButton": self.cancelButton,
        @"collectionView": self.collectionView,
    };
    
    NSDictionary *metrics = @{
        @"thumbnailHeight": @(self.thumbnailSize.height + 4.0),
        @"margin": @15.0,
    };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topToolbarView(40.0)][cameraView][bottomToolbarView(100.0)]|" options:kNilOptions metrics:nil views:views]];
    
    // Camera view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cameraView]|" options:kNilOptions metrics:nil views:views]];
    
    // Top toolbar
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topToolbarView]|" options:kNilOptions metrics:nil views:views]];
    
    // Flash mode button and camera device button
    [self.topToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[flashModeButton]-(>=0)-[selectionInfoLabel]-(>=0)-[cameraDeviceButton]-(margin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    [self.topToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.flashModeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.topToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionInfoLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.topToolbarView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // Bottom toolbar
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomToolbarView]|" options:kNilOptions metrics:nil views:views]];
    
    // Take picture button
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.takePictureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:66.0]];
    [self.takePictureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.takePictureButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    // Cancel button
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[cancelButton]" options:kNilOptions metrics:metrics views:views]];
    
    // Done button
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[doneButton]-(margin)-|" options:kNilOptions metrics:metrics views:views]];
    
    // Collection view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(thumbnailHeight)]-10.0-[bottomToolbarView]" options:kNilOptions metrics:metrics views:views]];
}

@end
