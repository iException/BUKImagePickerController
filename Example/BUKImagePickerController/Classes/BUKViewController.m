//
//  BUKViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 07/08/2015.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKViewController.h"
#import <BUKImagePickerController/BUKImagePickerController.h>

static NSString *const kBUKViewControllerCellIdentifier = @"cell";

@interface BUKViewController () <BUKImagePickerControllerDelegate>

@property (nonatomic) NSArray *optionInfos;

@end


@implementation BUKViewController

#pragma mark - Accessors

@synthesize optionInfos = _optionInfos;

- (NSArray *)optionInfos {
    if (!_optionInfos) {
        _optionInfos = @[
            @{@"text": @"Camera - single selection",
              @"selectorName": NSStringFromSelector(@selector(showSingleSelectionCamera:)),
            },
            @{@"text": @"Camera - multiple selection",
              @"selectorName": NSStringFromSelector(@selector(showMultipleSelectionCamera:)),
            },
            @{@"text": @"Library - single selection",
              @"selectorName": NSStringFromSelector(@selector(showSingleSelectionLibrary:)),
            },
            @{@"text": @"Library - multiple selection",
              @"selectorName": NSStringFromSelector(@selector(showMultipleSelectionLibrary:)),
            },
            @{@"text": @"Library - 6 photos at most ",
              @"selectorName": NSStringFromSelector(@selector(showMaximumSelectionLibrary:)),
            },
            @{@"text": @"Saved Photos Album - single selection",
              @"selectorName": NSStringFromSelector(@selector(showSingleSelectionAlbum:)),
            },
            @{@"text": @"Saved Photos Album - multiple Selection",
              @"selectorName": NSStringFromSelector(@selector(showMultipleSelectionAlbum:)),
            },
            @{@"text": @"Saved Photos Album - 3 photos at least",
              @"selectorName": NSStringFromSelector(@selector(showMinimumSelectionAlbum:)),
            },
            @{@"text": @"Saved Photos Album - with camera cell",
              @"selectorName": NSStringFromSelector(@selector(showAlbumWithCameraCell:)),
            },
        ];
    }
    return _optionInfos;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBUKViewControllerCellIdentifier];
    self.tableView.rowHeight = 40.0;
    
    self.title = @"BUKImagePickerController";
}


#pragma mark - Actions

- (void)showSingleSelectionCamera:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsMultipleSelection = NO;
    imagePickerController.needsConfirmation = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showMultipleSelectionCamera:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsMultipleSelection = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showSingleSelectionLibrary:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibrary;
    imagePickerController.allowsMultipleSelection = NO;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showMultipleSelectionLibrary:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibrary;
    imagePickerController.mediaType = BUKImagePickerControllerMediaTypeAny;
    imagePickerController.excludesEmptyAlbums = YES;
    imagePickerController.allowsMultipleSelection = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showMaximumSelectionLibrary:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeLibrary;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showSingleSelectionAlbum:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsMultipleSelection = NO;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showMultipleSelectionAlbum:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsMultipleSelection = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showMinimumSelectionAlbum:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 3;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)showAlbumWithCameraCell:(id)sender {
    BUKImagePickerController *imagePickerController = [self imagePickerController];
    imagePickerController.sourceType = BUKImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsCameraCell = YES;
    imagePickerController.reversesAssets = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionInfos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBUKViewControllerCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectorName = self.optionInfos[indexPath.row][@"selectorName"];
    SEL selector = NSSelectorFromString(selectorName);
    if ([self respondsToSelector:selector]) {
         [self performSelector:selector withObject:nil];
    }
}


#pragma mark - Private

- (BUKImagePickerController *)imagePickerController {
    BUKImagePickerController *imagePickerController = [[BUKImagePickerController alloc] init];
    imagePickerController.mediaType = BUKImagePickerControllerMediaTypeImage;
    imagePickerController.delegate = self;
    return imagePickerController;
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = self.optionInfos[indexPath.row][@"text"];
}


#pragma mark - BUKImagePickerControllerDelegate

- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset {
    
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset {
    
}


- (void)buk_imagePickerControllerDidCancel:(BUKImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    NSLog(@"didFinishPickingAssets: %@", assets);
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)buk_imagePickerController:(BUKImagePickerController *)imagePickerController didFinishPickingImages:(NSArray *)images {
    NSLog(@"didFinishPickingImages: %@", images);
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

@end
