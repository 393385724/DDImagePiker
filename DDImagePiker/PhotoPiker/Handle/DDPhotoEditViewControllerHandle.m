//
//  DDPhotoEditViewControllerHandle.m
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoEditViewControllerHandle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation DDPhotoEditViewControllerHandle

- (instancetype)initWithDDAsset:(DDAsset *)asset{
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

- (UIImage *)tmpImage{
    if ([UIDevice ddBelow8]) {
        CGImageRef ref = [[self.asset.alAsset defaultRepresentation] fullScreenImage];
        return [[UIImage alloc]initWithCGImage:ref];
    }
    else {
        return self.asset.thumbnail;
    }
}

- (void)requestImageResultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler{
    if ([UIDevice ddBelow8]) {
        CGImageRef ref = [[self.asset.alAsset defaultRepresentation] fullResolutionImage];
        UIImage *image = [[UIImage alloc]initWithCGImage:ref];
        resultHandler(image,nil);
    }
    else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:self.asset.phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:resultHandler];
    }
}

@end
