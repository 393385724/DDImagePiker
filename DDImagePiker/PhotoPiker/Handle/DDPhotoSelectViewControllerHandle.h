//
//  DDPhotoSelectViewControllerHandle.h
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAssetHandle.h"

typedef NS_ENUM(NSUInteger, DDPhotoSelectViewSoureType) {
    DDPhotoSelectViewSoureTypeDefault,  /*默认相册第一个*/
    DDPhotoSelectViewSoureTypeGroup,    /*从相册选择*/
};

@interface DDPhotoSelectViewControllerHandle : NSObject

@property (nonatomic, strong, readonly) DDAssetHandle *assetHandle;
@property (nonatomic, assign, readonly) DDPhotoSelectViewSoureType soureType;

@property (nonatomic, strong) NSArray *dataSoure;

@property (nonatomic, strong) UICollectionView *collectionView;

- (instancetype)initWithAssetHandle:(DDAssetHandle *)assetHandle soureType:(DDPhotoSelectViewSoureType)soureType;

- (void)fetchGroupAssetCompleteBlock:(DDFetchAssetsBlock)completeBlock;

- (void)requestImageAtIndex:(NSInteger)index resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler;

- (void)resetCachedAssets;

- (void)updateCachedAssets;

@end
