//
//  BUKAssetsManager.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAssetsManager.h"

NSString *const kBUKImagePickerAccessDeniedNotificationName = @"BUKImagePickerAccessDenied";

@interface BUKAssetsManager ()
@property (nonatomic) dispatch_queue_t saveImagesQueue;
@end

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
                       excludesEmptyGroups:(BOOL)excludesEmptyGroups
                                completion:(BUKAssetsManagerFetchAssetsGroupsCompletionBlock)completion
                              failureBlock:(BUKAssetsManagerFetchAssetsGroupsFailureBlock)failureBlock
{
    NSMutableArray *assetsGroups = [NSMutableArray array];
    ALAssetsFilter *assetsFilter = [self assetsFilterForMediaType:mediaType];
    
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if (assetsGroup) {
            [assetsGroup setAssetsFilter:assetsFilter];
            if (!excludesEmptyGroups || [assetsGroup numberOfAssets] > 0) {
                [assetsGroups addObject:assetsGroup];
            }
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
                            progress:(BUKAssetsManagerFetchAssetsProgressBlock)progressBlock
                          completion:(BUKAssetsManagerFetchAssetsCompletionBlock)completionBlock
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
    
    if (totalCount == 0) {
        checkNumberOfAssets();
        return;
    }
    
    // NOTE: This is a quick and dirty solution
    for (NSURL *assetURL in assetURLs) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            count ++;
            if (progressBlock) {
                progressBlock(asset, count, totalCount);
            }

            if (asset) {
                [mutableAssets addObject:asset];
            }

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
        _excludesEmptyGroups = NO;
        _saveImagesQueue = dispatch_queue_create("com.buk-image-picker-controller.save-images-queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary
                            mediaTyle:(BUKImagePickerControllerMediaType)mediaType
                           groupTypes:(ALAssetsGroupType)groupTypes
{
    if ((self = [self initWithAssetsLibrary:assetsLibrary])) {
        _mediaType = mediaType;
        _groupTypes = groupTypes;
    }
    return self;
}


#pragma mark - Public

- (void)fetchAssetsGroupsWithCompletion:(BUKAssetsManagerFetchAssetsGroupsCompletionBlock)completion failureBlock:(BUKAssetsManagerFetchAssetsGroupsFailureBlock)failureBlock
{
    return [[self class] fetchAssetsGroupsFromAssetsLibrary:self.assetsLibrary
                                             withGroupTypes:self.groupTypes
                                                  mediaType:self.mediaType
                                        excludesEmptyGroups:self.excludesEmptyGroups
                                                 completion:completion
                                               failureBlock:failureBlock];
}


- (void)writeImagesToSavedPhotosAlbum:(NSArray *)images
                             progress:(BUKAssetsManagerWriteImagesProgressBlock)progressBlock
                           completion:(void (^)(NSArray *, NSError *))completionBlock
{
    NSUInteger totalCount = images.count;
    NSMutableArray *mutableAssetURLs = [NSMutableArray arrayWithCapacity:totalCount];
    
    if (totalCount == 0) {
        if (completionBlock) {
            completionBlock(mutableAssetURLs, nil);
        }
        return;
    }
    
    __block NSUInteger count = 0;
    __weak typeof(self)weakSelf = self;
    
    for (UIImage *image in images) {
        dispatch_async(self.saveImagesQueue, ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [strongSelf writeImageToSavedPhotosAlbum:image completion:^(NSURL *assetURL, NSError *error) {
                count ++;
                if (assetURL) {
                    NSLog(@"[BUKImagePicker] Saved image to photos album.");
                    
                    [mutableAssetURLs addObject:assetURL];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if (progressBlock) {
                            progressBlock(assetURL, count, totalCount);
                        }
                    });
                } else {
                    NSLog(@"[BUKImagePicker] Saving images failed: %@", error);
                }
                
                if (count == totalCount) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if (completionBlock) {
                            completionBlock(mutableAssetURLs, nil);
                        }
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
}


- (void)writeImageToSavedPhotosAlbum:(UIImage *)image
                          completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
{
    [self.assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:completion];
}


- (void)fetchAssetsWithAssetURLs:(NSArray *)assetURLs
                        progress:(BUKAssetsManagerFetchAssetsProgressBlock)progressBlock
                      completion:(BUKAssetsManagerFetchAssetsCompletionBlock)completionBlock
{
    [[self class] fetchAssetsFromAssetsLibrary:self.assetsLibrary withAssetURLs:assetURLs progress:progressBlock completion:completionBlock];
}

@end
