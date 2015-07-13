//
//  BUKAlbumsViewController.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/9/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAlbumsViewController.h"
#import "BUKAlbumTableViewCell.h"

static NSString *const kCellReuseIdentifier = @"albumCell";

@interface BUKAlbumsViewController ()

@property (nonatomic) NSArray *assetsGroups;

@end

@implementation BUKAlbumsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    self.title = NSLocalizedString(@"Photos", nil);
    
    [self.tableView registerClass:[BUKAlbumTableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
}


#pragma mark - Actions

- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(albumsViewControllerDidCancel:)]) {
        [self.delegate albumsViewControllerDidCancel:self];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)done:(id)sender {
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BUKAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - Private

- (void)configureCell:(BUKAlbumTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
