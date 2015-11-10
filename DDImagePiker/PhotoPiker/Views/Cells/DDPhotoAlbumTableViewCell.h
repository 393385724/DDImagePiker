//
//  DDPhotoAlbumTableViewCell.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDAssetGroup;

@interface DDPhotoAlbumTableViewCell : UITableViewCell

- (void)updateWithAssetGroup:(DDAssetGroup *)assetGroup;

@end
