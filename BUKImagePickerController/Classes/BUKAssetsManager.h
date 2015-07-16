//
//  BUKAssetsManager.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKImagePickerController.h"

@class ALAssetsLibrary;

@interface BUKAssetsManager : NSObject

@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) BUKImagePickerControllerMediaType mediaType;
@property (nonatomic) ALAssetsGroupType groupTypes;

+ (instancetype)managerWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            mediaTyle:(BUKImagePickerControllerMediaType)mediaType
                           groupTypes:(ALAssetsGroupType)groupTypes;

- (NSArray *)assetsInAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray *assetsGroups))completion;
- (void)fetchAssetsGroupsWithGroupTypes:(ALAssetsGroupType)groupTypes
                              mediaType:(BUKImagePickerControllerMediaType)mediaType
                             completion:(void (^)(NSArray *assetsGroups))completion;
@end
