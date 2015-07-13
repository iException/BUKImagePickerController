//
//  BUKCameraViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import <FastttCamera/FastttCamera.h>
#import "BUKCameraViewController.h"

static NSString *const kBUKCameraViewControllerCellIdentifier = @"cell";

@interface BUKCameraViewController () <FastttCameraDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) FastttCamera *fastCamera;
@property (nonatomic) UIButton *takePictureButton;
@property (nonatomic) UIButton *flashModeButton;
@property (nonatomic) UIButton *cameraDeviceButton;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIView *topToolbarView;
@property (nonatomic) UIView *bottomToolbarView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSOrderedSet *selectedImages;
@property (nonatomic) FastttCameraFlashMode flashMode;
@property (nonatomic) FastttCameraDevice cameraDevice;

@end


@implementation BUKCameraViewController

#pragma mark - Accessors

@dynamic flashMode;
@dynamic cameraDevice;

- (FastttCamera *)fastCamera {
    if (!_fastCamera) {
        _fastCamera = [[FastttCamera alloc] init];
        _fastCamera.delegate = self;
    }
    return _fastCamera;
}


- (UIButton *)takePictureButton {
    if (!_takePictureButton) {
        _takePictureButton = [[UIButton alloc] init];
        _takePictureButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_takePictureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        [_takePictureButton setTitle:@"Boom!" forState:UIControlStateNormal];
    }
    
    return _takePictureButton;
}


- (UIButton *)flashModeButton {
    if (!_flashModeButton) {
        _flashModeButton = [[UIButton alloc] init];
        _flashModeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_flashModeButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashModeButton;
}


- (UIButton *)cameraDeviceButton {
    if (!_cameraDeviceButton) {
        _cameraDeviceButton = [[UIButton alloc] init];
        _cameraDeviceButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraDeviceButton addTarget:self action:@selector(toggleCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraDeviceButton setTitle:@"Toggle Camera" forState:UIControlStateNormal];
    }
    return _cameraDeviceButton;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
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


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBUKCameraViewControllerCellIdentifier];
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
            title = NSLocalizedString(@"Flash Auto", nil);
            break;
        case FastttCameraFlashModeOn:
            title = NSLocalizedString(@"Flash On", nil);
            break;
        case FastttCameraFlashModeOff:
            title = NSLocalizedString(@"Flash Off", nil);
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


#pragma mark - NSObject


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Camera view
    [self fastttAddChildViewController:self.fastCamera];
    
    // Top toolbar
    [self.topToolbarView addSubview:self.flashModeButton];
    [self.topToolbarView addSubview:self.cameraDeviceButton];
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
}


- (BOOL)prefersStatusBarHidden {
    return YES;
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
    NSLog(@"DONE");
}


- (void)takePicture:(id)sender {
    [self.fastCamera takePicture];
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
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBUKCameraViewControllerCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Private

- (void)configureCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor redColor];
}


- (void)updateDoneButton {
    
}


- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"topToolbarView": self.topToolbarView,
        @"bottomToolbarView": self.bottomToolbarView,
        @"cameraView": self.fastCamera.view,
        @"flashModeButton": self.flashModeButton,
        @"cameraDeviceButton": self.cameraDeviceButton,
        @"takePictureButton": self.takePictureButton,
        @"doneButton": self.doneButton,
        @"cancelButton": self.cancelButton,
        @"collectionView": self.collectionView,
    };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topToolbarView]" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topToolbarView]|" options:kNilOptions metrics:nil views:views]];
    [self.topToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.topToolbarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40.0]];
    
    [self.topToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.flashModeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.topToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[flashModeButton]" options:kNilOptions metrics:nil views:views]];
    
    [self.topToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraDeviceButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.topToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cameraDeviceButton]-5-|" options:kNilOptions metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomToolbarView]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomToolbarView]|" options:kNilOptions metrics:nil views:views]];
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomToolbarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100.0]];
    
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.takePictureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:66.0]];
    [self.takePictureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.takePictureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.takePictureButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[cancelButton]" options:kNilOptions metrics:nil views:views]];
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.bottomToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[doneButton]-5-|" options:kNilOptions metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(60.0)]-10.0-[bottomToolbarView]" options:kNilOptions metrics:nil views:views]];
}

@end
