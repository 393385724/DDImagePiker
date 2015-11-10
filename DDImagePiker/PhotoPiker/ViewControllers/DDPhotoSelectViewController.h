//
//  DDPhotoSelectViewController.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoBaseViewController.h"
#import "DDPhotoSelectViewControllerHandle.h"

@interface DDPhotoSelectViewController : DDPhotoBaseViewController

- (instancetype)initWithAssetHandle:(DDAssetHandle *)assetHandle soureType:(DDPhotoSelectViewSoureType)type;

@end
