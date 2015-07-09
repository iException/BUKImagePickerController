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
    
    [self.tableView registerClass:[BUKAlbumTableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
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
