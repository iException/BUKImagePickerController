//
//  BUKAlbumsViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;

#import "BUKAlbumsViewController.h"
#import "BUKAssetsViewController.h"
#import "BUKAlbumTableViewCell.h"
#import "BUKAssetsManager.h"
#import "UIImage+BUKImagePickerController.h"
#import "NSBundle+BUKImagePickerController.h"

static NSString *const kBUKAlbumsViewControllerCellIdentifier = @"albumCell";

@interface BUKAlbumsViewController ()
@property (nonatomic, readwrite) NSArray *assetsGroups;
@property (nonatomic) UIBarButtonItem *doneBarButtonItem;
@end


@implementation BUKAlbumsViewController

#pragma mark - NSObject

- (instancetype)init {
    if ((self = [super init])) {
        self.title = BUKImagePickerLocalizedString(@"Photos", nil);
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.allowsMultipleSelection) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BUKImagePickerLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    
    [self setUpToolbar];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.rowHeight = 90.0;
    [self.tableView registerClass:[BUKAlbumTableViewCell class] forCellReuseIdentifier:kBUKAlbumsViewControllerCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    
    // Load assets groups
    __weak typeof(self)weakSelf = self;
    [self updateAssetsGroupsWithCompletion:^{
        [weakSelf.tableView reloadData];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateDoneButton];
    [self updateSelectionInfo];
}


#pragma mark - Actions

- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerDidCancel:)]) {
        [self.delegate albumsViewControllerDidCancel:self];
    } else {
         [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerDidFinishPicking:)]) {
        [self.delegate albumsViewControllerDidFinishPicking:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BUKAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBUKAlbumsViewControllerCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(albumsViewController:didSelectAssetsGroup:)]) {
        [self.delegate albumsViewController:self didSelectAssetsGroup:[self assetsGroupAtIndexPath:indexPath]];
    }
}


#pragma mark - Private

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
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerShouldShowSelectionInfo:)]) {
        shouldShow = [self.delegate albumsViewControllerShouldShowSelectionInfo:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerSelectionInfo:)]) {
        text = [self.delegate albumsViewControllerSelectionInfo:self];
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


- (void)updateDoneButton {
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerShouldEnableDoneButton:)]) {
        self.doneBarButtonItem.enabled = [self.delegate albumsViewControllerShouldEnableDoneButton:self];
    } else {
        self.doneBarButtonItem.enabled = YES;
    }
}


- (BOOL)hasContent {
    return self.assetsGroups.count > 0;
}


- (ALAssetsGroup *)assetsGroupAtIndexPath:(NSIndexPath *)indexPath {
    return self.assetsGroups[indexPath.row];
}


- (void)configureCell:(BUKAlbumTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *assetsGroup = [self assetsGroupAtIndexPath:indexPath];
    NSString *groupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)", groupName, (long)assetsGroup.numberOfAssets];
    cell.tag = indexPath.row;
    
    NSUInteger numberOfAssets = MIN(3, [assetsGroup numberOfAssets]);
    
    if (numberOfAssets == 0) {
        cell.backImageView.hidden = NO;
        cell.middleImageView.hidden = NO;
        
        UIImage *placeholderImage = [UIImage buk_albumPlaceholderImageWithSize:CGSizeMake(68.0, 68.0)];
        cell.frontImageView.image = placeholderImage;
        cell.middleImageView.image = placeholderImage;
        cell.backImageView.image = placeholderImage;
    } else {
        NSRange range = NSMakeRange([assetsGroup numberOfAssets] - numberOfAssets, numberOfAssets);
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
        
        cell.backImageView.hidden = YES;
        cell.middleImageView.hidden = YES;
        
        [assetsGroup enumerateAssetsAtIndexes:indexes options:kNilOptions usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (!asset || cell.tag != indexPath.row) return;
            
            UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
            if (index == NSMaxRange(range) - 1) {
                cell.frontImageView.hidden = NO;
                cell.frontImageView.image = thumbnail;
            } else if (index == NSMaxRange(range) - 2) {
                cell.middleImageView.hidden = NO;
                cell.middleImageView.image = thumbnail;
            } else {
                cell.backImageView.hidden = NO;
                cell.backImageView.image = thumbnail;
            }
        }];
    }
}


- (void)assetsLibraryChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self)weakSelf = self;
        [self updateAssetsGroupsWithCompletion:^{
            [weakSelf.tableView reloadData];
        }];
    });
}


#pragma mark - Fetching AssetsGroups

- (void)updateAssetsGroupsWithCompletion:(void (^)(void))completion {
    [self.assetsManager fetchAssetsGroupsWithCompletion:^(NSArray *assetsGroups) {
        self.assetsGroups = assetsGroups;
        if (completion) {
            completion();
        }
    } failureBlock:nil];
}

@end
