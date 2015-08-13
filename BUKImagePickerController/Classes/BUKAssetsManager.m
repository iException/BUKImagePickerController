//
//  BUKAssetsManager.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAssetsManager.h"

NSString *const kBUKImagePickerAccessDeniedNotificationName = @"BUKImagePickerAccessDenied";

@implementation BUKAssetsManager

#pragma mark - Class Methods

+ (instancetype)managerWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    return [[self alloc] initWithAssetsLibrary:assetsLibrary];
}


+ (NSArray *)assetsInAssetsGroup:(ALAssetsGroup *)assetsGroup reverse:(BOOL)reverse {
    NSMutableArray *mutableAssets = [NSMutableArray array];
    NSEnumerationOptions options = reverse ? NSEnumerationReverse : kNilOptions;
    [assetsGroup enumerateAssetsWithOptions:options usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [mutableAssets addObject:result];
        }
    }];
    return mutableAssets;
}


+ (BOOL)isAccessDenied {
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    BOOL result;
    
    switch (authorizationStatus) {
        case ALAuthorizationStatusAuthorized:
        case ALAuthorizationStatusNotDetermined:
            result = NO;
            break;
        case ALAuthorizationStatusRestricted:
        case ALAuthorizationStatusDenied:
            result = YES;
            break;
    }
    
    return result;
}


+ (ALAssetsFilter *)assetsFilterForMediaType:(BUKImagePickerControllerMediaType)mediaType {
    switch (mediaType) {
        case BUKImagePickerControllerMediaTypeAny: {
            return [ALAssetsFilter allAssets];
        }
        case BUKImagePickerControllerMediaTypeImage: {
            return [ALAssetsFilter allPhotos];
        }
        case BUKImagePickerControllerMediaTypeVideo: {
            return [ALAssetsFilter allVideos];
        }
    }
}


+ (void)fetchAssetsGroupsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            withGroupTypes:(ALAssetsGroupType)groupTypes
                                 mediaType:(BUKImagePickerControllerMediaType)mediaType
                                completion:(void (^)(NSArray *assetsGroups))completion
                              failureBlock:(void (^)(NSError *error))failureBlock
{
    NSMutableArray *assetsGroups = [NSMutableArray array];
    ALAssetsFilter *assetsFilter = [self assetsFilterForMediaType:mediaType];
    
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if (assetsGroup) {
            [assetsGroup setAssetsFilter:assetsFilter];
            [assetsGroups addObject:assetsGroup];
        }
        // When the enumeration is done, enumerationBlock is invoked with group set to nil.
        else {
            if (completion) {
                completion([self sortAssetsGroups:assetsGroups]);
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"[BUKImagePickerController] An error occurs while fetching assets gourps: %@", [error localizedDescription]);
        [[NSNotificationCenter defaultCenter] postNotificationName:kBUKImagePickerAccessDeniedNotificationName object:nil];
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}


+ (void)fetchAssetsFromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                       withAssetURLs:(NSArray *)assetURLs
                            progress:(void (^)(ALAsset *asset, NSUInteger currentCout, NSUInteger totalCount))progressBlock
                          completion:(void (^)(NSArray *assets, NSError *error))completionBlock
{
    NSUInteger totalCount = assetURLs.count;
    NSMutableArray *mutableAssets = [NSMutableArray arrayWithCapacity:totalCount];
    __block NSUInteger count = 0;
    __block NSError *lastError = nil;
    
    void (^checkNumberOfAssets)(void) = ^{
        if (count == totalCount) {
            if (completionBlock) {
                completionBlock([mutableAssets copy], lastError);
            }
        }
    };
    
    // NOTE: This is a quick and dirty solution
    for (NSURL *assetURL in assetURLs) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            count ++;
            if (progressBlock) {
                progressBlock(asset, count, totalCount);
            }
            
            if (!asset) {
                return;
            }
            
            [mutableAssets addObject:asset];
            checkNumberOfAssets();
        } failureBlock:^(NSError *error) {
            NSLog(@"[BUKImagePickerController] An error occurs while fetching asset: %@", [error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kBUKImagePickerAccessDeniedNotificationName object:nil];
            
            count ++;
            if (progressBlock) {
                progressBlock(nil, count, totalCount);
            }
            
            lastError = error;
            checkNumberOfAssets();
        }];
    }
}


+ (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups {
    NSMutableDictionary *mappedAssetsGroups = [NSMutableDictionary dictionary];
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        NSNumber *groupType = [assetsGroup valueForProperty:ALAssetsGroupPropertyType];
        NSMutableArray *array = mappedAssetsGroups[groupType];
        if (!array) {
            array = [NSMutableArray array];
            mappedAssetsGroups[groupType] = array;
        }
        [array addObject:assetsGroup];
    }
    
    // Sort groups
    NSArray *groupTypesOrder = @[
        @(ALAssetsGroupSavedPhotos),
        @(ALAssetsGroupPhotoStream),
        @(ALAssetsGroupAlbum)
    ];
    
    NSMutableArray *sortedAssetsGroups = [NSMutableArray arrayWithCapacity:assetsGroups.count];
    for (NSNumber *groupType in groupTypesOrder) {
        NSArray *array = [mappedAssetsGroups objectForKey:groupType];
        if (array) {
            [sortedAssetsGroups addObjectsFromArray:array];
        }
    }
    
    // Add other groups
    [mappedAssetsGroups enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id array, BOOL *stop) {
        if (!array) {
            return;
        }
        if (![groupTypesOrder containsObject:key]) {
            [sortedAssetsGroups addObjectsFromArray:array];
        }
    }];
    
    return sortedAssetsGroups;
}


#pragma mark - NSObject

- (instancetype)init {
    return [self initWithAssetsLibrary:[[ALAssetsLibrary alloc] init]];
}


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    if ((self = [super init])) {
        _assetsLibrary = assetsLibrary;
        _groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream | ALAssetsGroupAlbum;
        _mediaType = BUKImagePickerControllerMediaTypeAny;
    }
    return self;
}


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary mediaTyle:(BUKImagePickerControllerMediaType)mediaType groupTypes:(ALAssetsGroupType)groupTypes {
    if ((self = [self initWithAssetsLibrary:assetsLibrary])) {
        _mediaType = mediaType;
        _groupTypes = groupTypes;
    }
    return self;
}


#pragma mark - Public

- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray *))completion
                           failureBlock:(void (^)(NSError *))failureBlock{
    return [[self class] fetchAssetsGroupsFromAssetsLibrary:self.assetsLibrary withGroupTypes:self.groupTypes mediaType:self.mediaType completion:completion failureBlock:failureBlock];
}


- (void)writeImagesToSavedPhotosAlbum:(NSArray *)images
                             progress:(void (^)(NSURL *assetURL, NSUInteger currentCount, NSUInteger totalCount))progressBlock
                           completion:(void (^)(NSArray *assetsURLs, NSError *error))completionBlock {
    NSUInteger totalCount = images.count;
    NSMutableArray *mutableAssetURLs = [NSMutableArray arrayWithCapacity:totalCount];
    
    for (UIImage *image in images) {
        [self writeImageToSavedPhotosAlbum:image completion:^(NSURL *assetURL, NSError *error) {
            if (!assetURL) {
                NSLog(@"[BUKImagePicker] Saving images failed: %@", error);
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            }
            
            NSLog(@"[BUKImagePicker] Saved image to photos album.");
            [mutableAssetURLs addObject:assetURL];
            if (progressBlock) {
                progressBlock(assetURL, mutableAssetURLs.count, totalCount);
            }
            
            if (mutableAssetURLs.count == totalCount) {
                if (completionBlock) {
                    completionBlock(mutableAssetURLs, nil);
                }
            }
        }];
    }
}


- (void)writeImageToSavedPhotosAlbum:(UIImage *)image completion:(void (^)(NSURL *, NSError *))completion {
    [self.assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:completion];
}


- (void)fetchAssetsWithAssetURLs:(NSArray *)assetURLs progress:(void (^)(ALAsset *, NSUInteger, NSUInteger))progressBlock completion:(void (^)(NSArray *, NSError *))completionBlock {
    [[self class] fetchAssetsFromAssetsLibrary:self.assetsLibrary withAssetURLs:assetURLs progress:progressBlock completion:completionBlock];
}

@end
