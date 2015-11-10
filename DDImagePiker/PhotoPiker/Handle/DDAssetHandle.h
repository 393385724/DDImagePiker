//
//  DDAssetHandle.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAssetGroup.h"
#import "DDAsset.h"

UIKIT_EXTERN NSString *const DDAssetGroupDidChangedNotification;
UIKIT_EXTERN NSString *const DDAssetsDidChangedNotification;
UIKIT_EXTERN NSString *const DDAssetDetailDidChangedNotification;

//info key
UIKIT_EXTERN NSString *const DDAssetDataSourceKey;

UIKIT_EXTERN NSString *const DDAssetNeedReloadKey;
UIKIT_EXTERN NSString *const DDAssetRemovedIndexPathsKey;
UIKIT_EXTERN NSString *const DDAssetInsertedIndexPathsKey;
UIKIT_EXTERN NSString *const DDAssetChangedIndexPathsKey;

UIKIT_EXTERN NSString *const DDAssetDetailKey;


typedef void (^DDFetchGroupBlock) (NSArray *allGroup, NSError *error);
typedef void (^DDFetchAssetsBlock) (DDAssetGroup *group, NSArray *allAssets, NSError *error);

@interface DDAssetHandle : NSObject

@property (nonatomic, strong) DDAssetGroup *currentSelectGroup;

@property (nonatomic, strong) DDAsset *currentAsset;

+ (void)requestAuthorization:(void(^)(bool granted))handler;

- (void)fetchGroupCompleteBlock:(DDFetchGroupBlock)completeBlock;

- (void)fetchFirstGroupAssetCompleteBlock:(DDFetchAssetsBlock)completeBlock;

- (void)fetchAssetWithGroup:(DDAssetGroup *)group completeBlock:(DDFetchAssetsBlock)completeBlock;


@end
