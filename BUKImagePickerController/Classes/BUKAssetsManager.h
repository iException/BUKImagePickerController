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

@interface BUKAssetsManager : NSObject

@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) BUKImagePickerControllerMediaType mediaType;
@property (nonatomic) ALAssetsGroupType groupTypes;

+ (instancetype)managerWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
+ (NSArray *)assetsInAssetsGroup:(ALAssetsGroup *)assetsGroup reverse:(BOOL)reverse;
+ (void)fetchAssetsGroupsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            withGroupTypes:(ALAssetsGroupType)groupTypes
                                 mediaType:(BUKImagePickerControllerMediaType)mediaType
                                completion:(void (^)(NSArray *assetsGroups))completion
                              failureBlock:(void (^)(NSError *error))failureBlock;
+ (void)fetchAssetsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                       withAssetURLs:(NSArray *)assetURLs
                            progress:(void (^)(ALAsset *asset, NSUInteger currentCout, NSUInteger totalCount))progressBlock
                          completion:(void (^)(NSArray *assets, NSError *error))completionBlock;
+ (BOOL)isAccessDenied;


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            mediaTyle:(BUKImagePickerControllerMediaType)mediaType
                           groupTypes:(ALAssetsGroupType)groupTypes;
- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray *assetsGroups))completion
                           failureBlock:(void (^)(NSError *error))failureBlock;
- (void)writeImagesToSavedPhotosAlbum:(NSArray *)images
                             progress:(void (^)(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount))progressBlock
                           completion:(void (^)(NSArray *assetsURLs, NSError *error))completionBlock;
- (void)writeImageToSavedPhotosAlbum:(UIImage *)image completion:(void (^)(NSURL *assetURL, NSError *error))completion;
- (void)fetchAssetsWithAssetURLs:(NSArray *)assetURLs
                        progress:(void (^)(ALAsset *asset, NSUInteger currentCout, NSUInteger totalCount))progressBlock
                      completion:(void (^)(NSArray *assets, NSError *error))completionBlock;

@end
