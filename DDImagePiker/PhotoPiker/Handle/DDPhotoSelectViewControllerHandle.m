//
//  DDPhotoSelectViewControllerHandle.m
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoSelectViewControllerHandle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "UICollectionView+Convenience.h"

@interface DDPhotoSelectViewControllerHandle ()

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) CGRect previousPreheatRect;

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) DDAssetHandle *assetHandle;
@property (nonatomic, assign) DDPhotoSelectViewSoureType soureType;

@end

@implementation DDPhotoSelectViewControllerHandle

- (instancetype)initWithAssetHandle:(DDAssetHandle *)assetHandle soureType:(DDPhotoSelectViewSoureType)soureType{
    self = [super init];
    if (self) {
        self.assetHandle = assetHandle;
        self.soureType = soureType;
    }
    return self;
}

- (void)fetchGroupAssetCompleteBlock:(DDFetchAssetsBlock)completeBlock{
    if (self.soureType == DDPhotoSelectViewSoureTypeDefault) {
        [self.assetHandle fetchFirstGroupAssetCompleteBlock:completeBlock];
    }
    else {
        [self.assetHandle fetchAssetWithGroup:self.assetHandle.currentSelectGroup completeBlock:completeBlock];
    }
}

- (void)requestImageAtIndex:(NSInteger)index resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler{
    DDAsset *asset = self.dataSoure[index];
    if ([UIDevice ddBelow8]) {
        CGImageRef ref = [asset.alAsset thumbnail];
        asset.thumbnail = [[UIImage alloc]initWithCGImage:ref];
        resultHandler(asset.thumbnail,nil);
    }
    else {
        [self.imageManager requestImageForAsset:asset.phAsset
                                     targetSize:self.imageSize
                                    contentMode:PHImageContentModeAspectFit
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      asset.thumbnail = result;
                                      resultHandler(result,info);
                                  }];
    }
}

- (void)resetCachedAssets{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets{
    if ([UIDevice ddBelow8]) {
        return;
    }
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenOldRect:self.previousPreheatRect newRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView ddIndexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView ddIndexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:self.imageSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:self.imageSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

#pragma mark - Private Methods

- (void)computeDifferenceBetweenOldRect:(CGRect)oldRect
                                newRect:(CGRect)newRect
                         removedHandler:(void (^)(CGRect removedRect))removedHandler
                           addedHandler:(void (^)(CGRect addedRect))addedHandler{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths{
    if (indexPaths.count == 0) {
        return nil;
    }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        DDAsset *asset = self.dataSoure[indexPath.item];
        [assets addObject:asset.phAsset];
    }
    return assets;
}

#pragma mark - Getter and setter

- (PHCachingImageManager *)imageManager{
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    CGFloat scale = [UIScreen mainScreen].scale;
    UICollectionViewFlowLayout *layOut = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGFloat width = layOut.itemSize.width;
    self.imageSize = CGSizeMake(width*scale, width*scale);
}
@end
