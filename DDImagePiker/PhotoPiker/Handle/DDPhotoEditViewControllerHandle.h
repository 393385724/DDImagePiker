//
//  DDPhotoEditViewControllerHandle.h
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAssetHandle.h"

@interface DDPhotoEditViewControllerHandle : NSObject

@property (nonatomic, strong) DDAsset *asset;

- (instancetype)initWithDDAsset:(DDAsset *)asset;

- (UIImage *)tmpImage;

- (void)requestImageResultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler;

@end
