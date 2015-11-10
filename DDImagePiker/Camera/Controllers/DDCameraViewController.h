//
//  DDCameraViewController.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCameraViewController;

@protocol DDCameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(DDCameraViewController *)cameraViewController didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)cameraViewControllerDidCancel:(DDCameraViewController *)cameraViewController;

@end

@interface DDCameraViewController : UIViewController

@property (nonatomic, weak) id<DDCameraViewControllerDelegate> delegate;

@end
