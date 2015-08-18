//
//  BUKCameraComfirmViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/17/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKCameraConfirmViewController.h"
#import "FastttCapturedImage.h"
#import "NSBundle+BUKImagePickerController.h"

@interface BUKCameraConfirmViewController ()

@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIView *bottomToolbarView;
@property (nonatomic) UIImageView *previewImageView;

@end


@implementation BUKCameraConfirmViewController

#pragma mark - Accessors

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _previewImageView;
}


- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitle:BUKImagePickerLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:BUKImagePickerLocalizedString(@"Retake", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


- (UIView *)bottomToolbarView {
    if (!_bottomToolbarView) {
        _bottomToolbarView = [[UIView alloc] init];
        _bottomToolbarView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomToolbarView.backgroundColor = [UIColor blackColor];
    }
    return _bottomToolbarView;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.previewImageView];
    [self.view addSubview:self.bottomToolbarView];
    [self.bottomToolbarView addSubview:self.cancelButton];
    [self.bottomToolbarView addSubview:self.confirmButton];
    
    [self setupViewConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.capturedImage.rotatedPreviewImage) {
        self.previewImageView.image = self.capturedImage.rotatedPreviewImage;
    } else {
        self.previewImageView.image = self.capturedImage.fullImage;
    }
}


#pragma mark - Actions

- (void)confirmImage:(id)sender {
    [self.delegate cameraConfirmViewControllerDidConfirm:self capturedImage:self.capturedImage];
}


- (void)cancel:(id)sender {
    [self.delegate cameraConfirmViewControllerDidCancel:self];
}


#pragma mark - Private

- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"previewImageView": self.previewImageView,
        @"cancelButton": self.cancelButton,
        @"confirmButton": self.confirmButton,
        @"bottomToolbarView": self.bottomToolbarView,
    };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40.0)-[previewImageView][bottomToolbarView(100.0)]|" options:kNilOptions metrics:nil views:views]];
    
    // Image preview
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewImageView]|" options:kNilOptions metrics:nil views:views]];
    
    // Bottom toolbar view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomToolbarView]|" options:kNilOptions metrics:nil views:views]];
    [self.bottomToolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10.0)-[cancelButton]-(>=100)-[confirmButton]-(10.0)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.bottomToolbarView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomToolbarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
