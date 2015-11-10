//
//  DDAssetHandle.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDAssetHandle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "NSIndexSet+Convenience.h"

NSString *const DDAssetGroupDidChangedNotification = @"DDAssetGroupDidChangedNotification";
NSString *const DDAssetsDidChangedNotification = @"DDAssetsDidChangedNotification";
NSString *const DDAssetDetailDidChangedNotification = @"DDAssetDetailDidChangedNotification";

NSString *const DDAssetDataSourceKey = @"DDAssetDataSourceKey";

NSString *const DDAssetNeedReloadKey = @"DDAssetNeedReloadKey";
NSString *const DDAssetRemovedIndexPathsKey = @"DDAssetRemovedIndexPathsKey";
NSString *const DDAssetInsertedIndexPathsKey = @"DDAssetInsertedIndexPathsKey";
NSString *const DDAssetChangedIndexPathsKey = @"DDAssetChangedIndexPathsKey";

NSString *const DDAssetDetailKey = @"DDAssetDetailKey";


const char *DDSyncAssetQueue = "com.asset.ddSyncAssetQueue";

NSInteger const DDAlbumImageSize = 40;

@interface DDAssetHandle ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) dispatch_queue_t syncAssetQueue;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

// after ios 8
@property (nonatomic, strong) NSMutableArray *assetGroupArray;

@property (nonatomic, strong) NSMutableArray *collectionsFetchResults;

@end

@implementation DDAssetHandle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.syncAssetQueue = dispatch_queue_create(DDSyncAssetQueue, nil);
        self.assetGroupArray = [[NSMutableArray alloc] init];
        if ([UIDevice ddBelow8]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChangedNotification:) name:ALAssetsLibraryChangedNotification object:nil];
        }
        else {
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            PHFetchResult *typeAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
            PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            self.collectionsFetchResults = [[NSMutableArray alloc] initWithObjects:smartAlbums,typeAlbums,topLevelUserCollections,nil];
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

+ (void)requestAuthorization:(void(^)(bool granted))handler{
    if (!handler) {
        return;
    }
    if ([UIDevice ddBelow8]) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == kCLAuthorizationStatusRestricted ||
            status ==kCLAuthorizationStatusDenied){
            handler(NO);
        }
        else {
            handler(YES);
        }
    }
    else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status ==PHAuthorizationStatusDenied){
            handler(NO);
        }
        else if (status == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusRestricted ||
                    status ==PHAuthorizationStatusDenied){
                    handler(NO);
                }
                else{
                    handler(YES);
                }
            }];
        }
        else{
            handler(YES);
        }
    }
}

- (void)fetchGroupCompleteBlock:(DDFetchGroupBlock)completeBlock{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(self.syncAssetQueue, ^{
        if ([UIDevice ddBelow8]) {
            [weakSelf fetchALLibraryGroupsWithCompleteBlock:completeBlock];
        }
        else {
            [weakSelf fetchPHLibraryGroupsCompleteBlock:completeBlock];
        }
    });
}

- (void)fetchAssetWithGroup:(DDAssetGroup *)group completeBlock:(DDFetchAssetsBlock)completeBlock{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(self.syncAssetQueue, ^{
        if ([UIDevice ddBelow8]) {
            [weakSelf fetchALLibraryAssetFromGroup:group completeBlock:completeBlock];
        }
        else {
            [weakSelf fetchPHLibraryAssetWithGroup:group completeBlock:completeBlock];
        }
    });
}

- (void)fetchFirstGroupAssetCompleteBlock:(DDFetchAssetsBlock)completeBlock{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(self.syncAssetQueue, ^{
        if ([UIDevice ddBelow8]) {
            [weakSelf fetchALLibraryFirstGroupAssetsWithCompleteBlock:completeBlock];
        }
        else {
            [weakSelf fetchPHLibraryFirstGroupAssetWithCompleteBlock:completeBlock];
        }
    });
}

#pragma mark - Private Methods

#pragma mark - before iOS 8

- (void)fetchALLibraryGroupsWithCompleteBlock:(DDFetchGroupBlock)completeBlock{
    if (![self.assetGroupArray count]) {
        __weak __typeof(&*self)weakSelf = self;
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            @autoreleasepool {
                if (group && [group numberOfAssets] > 0) {
                    DDAssetGroup *assetGroup = [[DDAssetGroup alloc] initWithALAssetsGroup:group];
                    assetGroup.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                    assetGroup.thumbnail = [UIImage imageWithCGImage:group.posterImage];
                    assetGroup.numberOfAssets = group.numberOfAssets;
                    [weakSelf.assetGroupArray insertObject:assetGroup atIndex:0];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(weakSelf.assetGroupArray,nil);
                    });
                }
            }
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(nil,error);
            });
        }];
    }
    else {
        completeBlock(self.assetGroupArray,nil);
    }
}

- (void)fetchALLibraryAssetFromGroup:(DDAssetGroup *)group completeBlock:(DDFetchAssetsBlock)completeBlock{
    __block NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    [group.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        @autoreleasepool {
            if (result) {
                DDAsset *asset = [[DDAsset alloc] initWithALAsset:result];
                [tmpArray addObject:asset];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(group,tmpArray,nil);
                });
            }
        }
    }];
}

- (void)fetchALLibraryFirstGroupAssetsWithCompleteBlock:(DDFetchAssetsBlock)completeBlock{
    __weak __typeof(&*self)weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            *stop = YES;
            DDAssetGroup *assetGroup = [[DDAssetGroup alloc] initWithALAssetsGroup:group];
            assetGroup.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            assetGroup.thumbnail = [UIImage imageWithCGImage:group.posterImage];
            assetGroup.numberOfAssets = group.numberOfAssets;
            weakSelf.currentSelectGroup = assetGroup;
            [weakSelf fetchALLibraryAssetFromGroup:assetGroup completeBlock:completeBlock];
        }
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil,nil,error);
        });
    }];
}

#pragma mark - Notification

- (void)assetsLibraryChangedNotification:(NSNotification *)notification{
    if([notification.name isEqualToString:ALAssetsLibraryChangedNotification]){
        NSDictionary* info = [notification userInfo];
        if (!info || info.count == 0) {
            return;
        }
        
        NSSet *updatedAssets = [info objectForKey:ALAssetLibraryUpdatedAssetsKey];
//        NSSet *updatedAssetGroup = [info objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
//        NSSet *deletedAssetGroup = [info objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
//        NSSet *insertedAssetGroup = [info objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
        
        //更新 相册
        [self.assetGroupArray removeAllObjects];
        [self fetchALLibraryGroupsWithCompleteBlock:^(NSArray *allGroup, NSError *error) {
            if (self.currentSelectGroup) {
                NSString *currentGroupURLString = [[self.currentSelectGroup.assetsGroup valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                for (DDAssetGroup *assetGroup in allGroup) {
                    NSString *assetGroupURLString = [[assetGroup.assetsGroup valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                    if ([assetGroupURLString isEqualToString:currentGroupURLString]) {
                        self.currentSelectGroup = assetGroup;
                        break;
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetGroupDidChangedNotification object:@{DDAssetDataSourceKey:allGroup}];
        }];
    
        //更新 照片
        if (self.currentSelectGroup) {
            [self fetchAssetWithGroup:self.currentSelectGroup completeBlock:^(DDAssetGroup *group, NSArray *allAssets, NSError *error) {
                NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                [infoDict setObject:@(YES) forKey:DDAssetNeedReloadKey];
                [infoDict setObject:allAssets forKey:DDAssetDataSourceKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetsDidChangedNotification object:infoDict];
            }];
        }
    
        //更新 照片详情
        if (self.currentAsset) {
            NSString *currentAssetURLString = [[self.currentAsset.alAsset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            for (NSURL *url in [updatedAssets allObjects]) {
                if ([[url absoluteString] isEqualToString:currentAssetURLString]) {
                    [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                        self.currentAsset.alAsset = asset;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetDetailDidChangedNotification object:@{DDAssetDetailKey:self.currentAsset}];
                        });
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            }
        }
    }
}

#pragma mark - after iOS 8

- (void)fetchPHLibraryGroupsCompleteBlock:(DDFetchGroupBlock)completeBlock{
    if (![self.assetGroupArray count]) {
        __block DDAssetGroup *allPhotosGroup = nil;
        __block DDAssetGroup *filmPhotosGroup = nil;
        for (PHFetchResult *collectionFetchResult in self.collectionsFetchResults) {
            [collectionFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PHAssetCollection class]]) {
                    PHFetchOptions *options = [[PHFetchOptions alloc] init];
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
                    PHFetchResult *assetCollectionFetchResult = [PHAsset fetchAssetsInAssetCollection:obj options:options];
                    if (assetCollectionFetchResult.count > 0){
                        DDAssetGroup *group = [[DDAssetGroup alloc] initWithPHAssetCollection:obj];
                        group.assetCollectionFetchResult = assetCollectionFetchResult;
                        group.groupName = [obj localizedTitle];
                        group.numberOfAssets = assetCollectionFetchResult.count;
                        CGFloat scale = [UIScreen mainScreen].scale;
                        CGSize size = CGSizeMake(scale * DDAlbumImageSize, scale * DDAlbumImageSize);
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                        options.networkAccessAllowed = YES;
                        [[PHImageManager defaultManager] requestImageForAsset:[assetCollectionFetchResult lastObject] targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                            if (result) {
                                group.thumbnail = result;
                            }
                        }];
                        if (((PHAssetCollection *)obj).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                            allPhotosGroup = group;
                        }
                        else {
                            [self.assetGroupArray addObject:group];
                        }
                    }
                }
            }];
        }
        if (allPhotosGroup) {
            [self.assetGroupArray insertObject:allPhotosGroup atIndex:0];
        }
        if (filmPhotosGroup) {
            [self.assetGroupArray insertObject:filmPhotosGroup atIndex:0];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completeBlock(self.assetGroupArray,nil);
    });
}

- (void)fetchPHLibraryAssetWithGroup:(DDAssetGroup *)group completeBlock:(DDFetchAssetsBlock)completeBlock{
    __block NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    [group.assetCollectionFetchResult enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DDAsset *asset = [[DDAsset alloc] initWithPHAsset:obj];
        [tmpArray addObject:asset];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        completeBlock(group,tmpArray,nil);
    });
}

- (void)fetchPHLibraryFirstGroupAssetWithCompleteBlock:(DDFetchAssetsBlock)completeBlock{
    __weak __typeof(&*self)weakSelf = self;
    [self fetchPHLibraryGroupsCompleteBlock:^(NSArray *groups, NSError *error) {
        weakSelf.currentSelectGroup = [groups firstObject];
        [self fetchPHLibraryAssetWithGroup:weakSelf.currentSelectGroup completeBlock:completeBlock];
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    //更新 相册
    NSMutableArray *updatedCollectionsFetchResults = nil;
    for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
        if (changeDetails) {
            if (!updatedCollectionsFetchResults) {
                updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
            }
            [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
        }
    }
    if (updatedCollectionsFetchResults) {
        self.collectionsFetchResults = updatedCollectionsFetchResults;
    }
    
    [self.assetGroupArray removeAllObjects];
    [self fetchGroupCompleteBlock:^(NSArray *allGroup, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetGroupDidChangedNotification object:@{DDAssetDataSourceKey:allGroup}];
    }];
    
    //更新 照片
    if (self.currentSelectGroup) {
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.currentSelectGroup.assetCollectionFetchResult];
        if (collectionChanges) {
            self.currentSelectGroup.assetCollectionFetchResult = [collectionChanges fetchResultAfterChanges];
            
            BOOL needReload = NO;
            NSArray *removedIndexPaths = nil;
            NSArray *insertedIndexPaths = nil;
            NSArray *changedIndexPaths = nil;
            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                needReload = YES;
            } else {
                removedIndexPaths = [[collectionChanges removedIndexes] ddIndexPathsFromIndexesWithSection:0];
                if ([removedIndexPaths count]) {
                    [infoDict setObject:removedIndexPaths forKey:DDAssetRemovedIndexPathsKey];
                }
                insertedIndexPaths = [[collectionChanges insertedIndexes] ddIndexPathsFromIndexesWithSection:0];
                if ([insertedIndexPaths count]) {
                    [infoDict setObject:insertedIndexPaths forKey:DDAssetInsertedIndexPathsKey];
                }
                changedIndexPaths = [[collectionChanges changedIndexes] ddIndexPathsFromIndexesWithSection:0];
                if ([changedIndexPaths count]) {
                    [infoDict setObject:changedIndexPaths forKey:DDAssetChangedIndexPathsKey];
                }
            }
            [infoDict setObject:@(needReload) forKey:DDAssetNeedReloadKey];
            [self fetchAssetWithGroup:self.currentSelectGroup completeBlock:^(DDAssetGroup *group, NSArray *allAssets, NSError *error) {
                [infoDict setObject:allAssets forKey:DDAssetDataSourceKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetsDidChangedNotification object:infoDict];
            }];
        }
    }
    if (self.currentAsset) {
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.currentAsset.phAsset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.currentAsset.phAsset = [changeDetails objectAfterChanges];
            if ([changeDetails assetContentChanged]) {
                //重新获取图片
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:DDAssetDetailDidChangedNotification object:@{DDAssetDetailKey:self.currentAsset}];
                });
            }
        }
    }
}

#pragma mark - Getter and Setter

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
