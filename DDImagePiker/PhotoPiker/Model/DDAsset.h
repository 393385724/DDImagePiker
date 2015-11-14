//
//  DDAsset.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAsset;
@class PHAsset;

@interface DDAsset : NSObject

@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, strong) PHAsset *phAsset;

//默认 nil
@property (nonatomic, strong) UIImage *thumbnail;

- (instancetype)initWithALAsset:(ALAsset *)asset;

- (instancetype)initWithPHAsset:(PHAsset *)asset;

@end
