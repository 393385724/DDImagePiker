//
//  DDAssetGroup.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@class PHAssetCollection;
@class PHFetchResult;

@interface DDAssetGroup : NSObject

@property (nonatomic, strong) NSArray *assets;

@property (nonatomic, strong, readonly) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong, readonly) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *assetCollectionFetchResult;

@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, assign) NSInteger numberOfAssets;

- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)group;

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection;

@end
