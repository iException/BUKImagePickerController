//
//  BUKViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 07/08/2015.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKViewController.h"
#import <BUKImagePickerController/BUKImagePickerController.h>
#import <BUKImagePickerController/BUKCameraViewController.h>

static NSString *const kBUKViewControllerCellIdentifier = @"cell";

@implementation BUKViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBUKViewControllerCellIdentifier];
    self.tableView.rowHeight = 40.0;
    
    self.title = @"BUKImagePicker";
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBUKViewControllerCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BUKImagePickerController *imagePickerController = [[BUKImagePickerController alloc] init];
    imagePickerController.mediaType = BUKImagePickerControllerMediaTypeImage;
    if (indexPath.row == 0) {
        imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibraryAndCamera;
    } else if (indexPath.row == 1) {
        imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibrary;
    } else if (indexPath.row == 2) {
        imagePickerController.sourceType = BUKImagePickerControllerSourceTypeCamera;
    } else {
        imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibraryAndCamera;
    }
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - Private

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Library and camera
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Library and Camera";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Library";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Camera";
    } else {
        // Should never reach here
        cell.textLabel.text = nil;
    }
}


#pragma mark - BUKImagePickerControllerDelegate

- (BOOL)buk_imagePickerController:(BUKImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset {
    return YES;
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset {
    NSLog(@"%s %d %s", __FILE__, __LINE__, __PRETTY_FUNCTION__);
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset {
    NSLog(@"%s %d %s", __FILE__, __LINE__, __PRETTY_FUNCTION__);
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFulfillMinimumSelection:(NSUInteger)minimumNumberOfSelection {
    
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didReachMaximumSelection:(NSUInteger)maximumNumberOfSelection {
    
}


- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController {
    
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    
}

@end
