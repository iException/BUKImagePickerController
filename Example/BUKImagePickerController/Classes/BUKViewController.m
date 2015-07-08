//
//  BUKViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 07/08/2015.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKViewController.h"
#import <BUKImagePickerController/BUKImagePickerController.h>

@interface BUKViewController ()
@property (nonatomic, readonly) UIButton *imagePickerButton;
@end


@implementation BUKViewController

#pragma mark - Accessors

@synthesize imagePickerButton = _imagePickerButton;

- (UIButton *)imagePickerButton {
    if (!_imagePickerButton) {
        _imagePickerButton = [[UIButton alloc] init];
        _imagePickerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _imagePickerButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
        [_imagePickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_imagePickerButton setTitle:@"Show Image Picker" forState:UIControlStateNormal];
        [_imagePickerButton addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imagePickerButton;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imagePickerButton];
    [self setupViewConstraints];
}


#pragma mark - Actions

- (void)showImagePicker:(id)sender {
    NSLog(@"Show Image Picker");
    
    BUKImagePickerController *imagePickerController = [[BUKImagePickerController alloc] init];
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - Private

- (void)setupViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imagePickerButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imagePickerButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
