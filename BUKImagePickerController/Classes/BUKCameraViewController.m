//
//  BUKCameraViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import <FastttCamera/FastttCamera.h>
#import "BUKCameraViewController.h"

@interface BUKCameraViewController () <FastttCameraDelegate>

@property (nonatomic) FastttCamera *fastCamera;
@property (nonatomic) UIButton *takePictureButton;
@property (nonatomic) UIButton *flashModeButton;
@property (nonatomic) UIButton *cameraDeviceButton;
@property (nonatomic) UIView *topToolbarView;
@property (nonatomic) UIView *bottomToolbarView;

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
        [_flashModeButton setTitle:@"Flash" forState:UIControlStateNormal];
    }
    return _flashModeButton;
}


- (UIButton *)cameraDeviceButton {
    if (!_cameraDeviceButton) {
        _cameraDeviceButton = [[UIButton alloc] init];
        _cameraDeviceButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraDeviceButton addTarget:self action:@selector(toggleCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraDeviceButton setTitle:@"Camera" forState:UIControlStateNormal];
    }
    return _cameraDeviceButton;
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


- (FastttCameraFlashMode)flashMode {
    return self.fastCamera.cameraFlashMode;
}


- (void)setFlashMode:(FastttCameraFlashMode)flashMode {
    if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
        self.flashModeButton.hidden = YES;
        return;
    }
    
    self.fastCamera.cameraFlashMode = flashMode;
    self.flashModeButton.hidden = NO;
    
    NSString *title;
    switch (self.flashMode) {
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
}


- (FastttCameraDevice)cameraDevice {
    return self.fastCamera.cameraDevice;
}


- (void)setCameraDevice:(FastttCameraDevice)cameraDevice {
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
        self.flashModeButton.hidden = ![self.fastCamera isFlashAvailableForCurrentDevice];
    }
}


#pragma mark - NSObject


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self fastttAddChildViewController:self.fastCamera];
    
    [self.topToolbarView addSubview:self.flashModeButton];
    [self.topToolbarView addSubview:self.cameraDeviceButton];
    [self.view addSubview:self.topToolbarView];
    
    [self.bottomToolbarView addSubview:self.takePictureButton];
    [self.view addSubview:self.bottomToolbarView];
    
    [self setupViewConstraints];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - Actions

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


#pragma mark - Private

- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"topToolbarView": self.topToolbarView,
        @"bottomToolbarView": self.bottomToolbarView,
        @"cameraView": self.fastCamera.view,
        @"flashModeButton": self.flashModeButton,
        @"cameraDeviceButton": self.cameraDeviceButton,
        @"takePictureButton": self.takePictureButton,
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
}

@end
