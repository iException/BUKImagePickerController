//
//  BUKAssetsManager.h
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;
#import "BUKImagePickerController.h"

extern NSString *const kBUKImagePickerAccessDeniedNotificationName;

typedef void (^BUKAssetsManagerFetchAssetsGroupsCompletionBlock)(NSArray *groups);
typedef void (^BUKAssetsManagerFetchAssetsGroupsFailureBlock)(NSError *error);
typedef void (^BUKAssetsManagerWriteImagesProgressBlock)(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount);
typedef void (^BUKAssetsManagerFetchAssetsProgressBlock)(ALAsset *asset, NSUInteger currentCout, NSUInteger totalCount);
typedef void (^BUKAssetsManagerFetchAssetsCompletionBlock)(NSArray *assets, NSError *error);


@interface BUKAssetsManager : NSObject

@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) BUKImagePickerControllerMediaType mediaType;
@property (nonatomic) ALAssetsGroupType groupTypes;
@property (nonatomic) BOOL excludesEmptyGroups;

+ (BOOL)isAccessDenied;
+ (instancetype)managerWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
+ (NSArray *)assetsInAssetsGroup:(ALAssetsGroup *)assetsGroup reverse:(BOOL)reverse;
+ (void)fetchAssetsGroupsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            withGroupTypes:(ALAssetsGroupType)groupTypes
                                 mediaType:(BUKImagePickerControllerMediaType)mediaType
                       excludesEmptyGroups:(BOOL)excludesEmptyGroups
                                completion:(BUKAssetsManagerFetchAssetsGroupsCompletionBlock)completion
                              failureBlock:(BUKAssetsManagerFetchAssetsGroupsFailureBlock)failureBlock;
+ (void)fetchAssetsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                       withAssetURLs:(NSArray *)assetURLs
                            progress:(BUKAssetsManagerFetchAssetsProgressBlock)progressBlock
                          completion:(BUKAssetsManagerFetchAssetsCompletionBlock)completionBlock;

- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            mediaTyle:(BUKImagePickerControllerMediaType)mediaType
                           groupTypes:(ALAssetsGroupType)groupTypes;

// Fetch assets groups
- (void)fetchAssetsGroupsWithCompletion:(BUKAssetsManagerFetchAssetsGroupsCompletionBlock)completion
                           failureBlock:(BUKAssetsManagerFetchAssetsGroupsFailureBlock)failureBlock;

// Write images
- (void)writeImagesToSavedPhotosAlbum:(NSArray *)images
                             progress:(BUKAssetsManagerWriteImagesProgressBlock)progressBlock
                           completion:(void (^)(NSArray *assetURLs, NSError *error))completionBlock;
- (void)writeImageToSavedPhotosAlbum:(UIImage *)image completion:(ALAssetsLibraryWriteImageCompletionBlock)completion;

// Fetch assets
- (void)fetchAssetsWithAssetURLs:(NSArray *)assetURLs
                        progress:(BUKAssetsManagerFetchAssetsProgressBlock)progressBlock
                      completion:(BUKAssetsManagerFetchAssetsCompletionBlock)completionBlock;

@end
