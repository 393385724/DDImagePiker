//
//  DDAssetGroup.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDAssetGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface DDAssetGroup ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

@implementation DDAssetGroup

- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)group{
    self = [super init];
    if (self) {
        self.assetsGroup = group;
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
    return self;
}

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection{
    self = [super init];
    if (self) {
        self.assetCollection = collection;
    }
    return self;
}

@end
