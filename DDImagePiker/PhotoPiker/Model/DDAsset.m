//
//  DDAsset.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation DDAsset

- (instancetype)initWithALAsset:(ALAsset *)asset{
    self = [super init];
    if (self) {
        self.alAsset = asset;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    self = [super init];
    if (self) {
        self.phAsset = asset;
    }
    return self;
}

@end
