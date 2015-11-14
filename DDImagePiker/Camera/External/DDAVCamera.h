//
//  DDAVCamera.h
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@class DDAVCamera;
@protocol DDAVCameraDelegate <NSObject>
@optional
- (void)camera:(DDAVCamera *)camera didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)camera:(DDAVCamera *)camera didFailWithError:(NSError *)error;

@end

@interface DDAVCamera : NSObject

@property (nonatomic, weak) id<DDAVCameraDelegate>  delegate;

@property (nonatomic, assign) AVCaptureFocusMode focusMode;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;

@property (nonatomic, assign, readonly) BOOL hasFlash;
@property (nonatomic, assign, readonly) BOOL hasMoreDevice;//有没有前置摄像头

- (instancetype)initWithSuperView:(UIView *)superView
                   cameraPosition:(AVCaptureDevicePosition)cameraPosition;

+ (void)requestAccessCompletionHandler:(void (^)(BOOL granted))handler;

- (void)switchDevicePosition;

- (void)startRunning;

- (void)focusInPoint:(CGPoint)devicePoint;

- (void)takePicture;

- (void)stopRunning;

@end
