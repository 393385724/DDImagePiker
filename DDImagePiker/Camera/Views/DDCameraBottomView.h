//
//  DDCameraBottomView.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDCameraBottomViewDelegate <NSObject>

- (void)cameraBottomBarAlbumButtonAction;
- (void)cameraBottomBarTakePhotoButtonAction;
- (void)cameraBottomBarCancelButtonAction;

@end

@interface DDCameraBottomView : UIView

@property (nonatomic, weak) id<DDCameraBottomViewDelegate> delegate;

@property (nonatomic, assign) BOOL albumHiden;

+ (DDCameraBottomView *)loadNibWithOwner:(id)owner;

@end
