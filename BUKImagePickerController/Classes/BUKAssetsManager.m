//
//  BUKAssetsManager.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;
#import "BUKAssetsManager.h"


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
    }];
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

- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray *))completion {
    return [[self class] fetchAssetsGroupsFromAssetsLibrary:self.assetsLibrary withGroupTypes:self.groupTypes mediaType:self.mediaType completion:completion];
}

@end
