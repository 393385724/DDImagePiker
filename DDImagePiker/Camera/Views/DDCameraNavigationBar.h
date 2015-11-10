//
//  DDCameraNavigationBar.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HMCameraFlashMode) {
    HMCameraFlashModeOff  = 0,
    HMCameraFlashModeOn   = 1,
    HMCameraFlashModeAuto = 2
};

typedef NS_ENUM(NSUInteger, HMCameraPosition) {
    HMCameraPositionBack                = 1,
    HMCameraPositionFront               = 2
};

@protocol DDCameraNavigationBarDelegate <NSObject>

- (void)cameraTopBarDidSelectFlashMode:(HMCameraFlashMode)flashMode;
- (void)cameraTopBarDidSelectPosition:(HMCameraPosition)position;

@end

@interface DDCameraNavigationBar : UIView

@property (nonatomic, weak) id<DDCameraNavigationBarDelegate> delegate;

+ (DDCameraNavigationBar *)loadNibWithOwner:(id)owner;

- (void)reloadWithflashEnabled:(BOOL)flashEnabled
                     flashMode:(HMCameraFlashMode)flashMode
               positionEnabled:(BOOL)positionEnabled;

@end
