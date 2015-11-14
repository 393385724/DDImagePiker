//
//  DDCameraViewController.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDCameraViewController.h"
#import "DDCameraNavigationBar.h"
#import "DDCameraBottomView.h"
#import "DDAVCamera.h"

#import <DDCoreCategory/DDCategoryHeader.h>


@interface DDCameraViewController ()<DDAVCameraDelegate,DDCameraNavigationBarDelegate,DDCameraBottomViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) DDCameraNavigationBar *navigationBar;
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) DDCameraBottomView *bottomView;

@property (nonatomic, strong) DDAVCamera *camera;

@end

@implementation DDCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = [UIDevice ddScreenWidth];
    CGFloat height = [UIDevice ddScreenHeight];
    CGFloat navibarHeight = 64.0;
    self.navigationBar = [DDCameraNavigationBar loadNibWithOwner:self];
    self.navigationBar.frame = CGRectMake(0, 0, width, navibarHeight);
    self.navigationBar.backgroundColor = RGBCOLOR(22, 24, 25);
    self.navigationBar.delegate = self;
    
    self.preView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBar.ddBottom, width, ddFloor(width/3*4))];
    [self.preView ddAddTarget:self tapAction:@selector(camerafocus:)];
    self.preView.backgroundColor = RGBCOLOR(22, 24, 25);
   
    self.bottomView = [DDCameraBottomView loadNibWithOwner:self];
    self.bottomView.frame = CGRectMake(0, self.navigationBar.ddHeight + width , width, height - width - self.navigationBar.ddHeight);
    self.bottomView.albumHiden = YES;
    self.bottomView.backgroundColor = RGBCOLOR(22, 24, 25);
    self.bottomView.delegate = self;

    [self.view addSubview:self.preView];
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationBar reloadWithflashEnabled:self.camera.hasFlash flashMode:(HMCameraFlashMode)self.camera.flashMode positionEnabled:self.camera.hasMoreDevice];
    [DDAVCamera requestAccessCompletionHandler:^(BOOL granted) {
        if (granted) {
            [self.camera startRunning];
        }
        else {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"无法开启相机,请点击设置开放权限" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            alterView.tag = 1001;
            [alterView show];
        }
    }];
}

#pragma mark - Template Methods

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIGestureRecognizer
- (void)camerafocus:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint locationInPreView = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    CGPoint locationInView = [tapGestureRecognizer.view convertPoint:locationInPreView toView:self.view];
    [self focusViewInPoint:locationInView];
    [self.camera focusInPoint:locationInPreView];
}

- (void)focusViewInPoint:(CGPoint)point{
    UIImageView *tapFocusImageView = [self.view viewWithTag:100000];
    [tapFocusImageView.layer removeAllAnimations];
    if (!tapFocusImageView) {
        tapFocusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd_camera_focus_point"]];
        tapFocusImageView.tag = 100000;
        [tapFocusImageView sizeToFit];
        tapFocusImageView.center = point;
        [self.view addSubview:tapFocusImageView];
    }
    CGFloat preViewWidth = self.preView.ddWidth;
    CGFloat tapFocusWidth = tapFocusImageView.ddWidth;
    
    CGPoint center = point;
    //焦点框不能出边界的处理
    if (point.x - tapFocusWidth/2.0 < 0) {
        center.x = tapFocusWidth/2.0;
    }
    if (point.y - tapFocusWidth/2.0 < self.preView.ddTop){
        center.y = tapFocusWidth/2.0 + self.preView.ddTop;
    }
    if (point.x + tapFocusWidth/2.0 > preViewWidth) {
        center.x = preViewWidth - tapFocusWidth/2.0;
    }
    if (point.y + tapFocusWidth/2.0 > preViewWidth) {
        center.y = preViewWidth - tapFocusWidth/2.0 + self.preView.ddTop;
    }
    tapFocusImageView.center = center;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tapFocusImageView.alpha = 0.3f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            tapFocusImageView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [tapFocusImageView removeFromSuperview];
        }];
    }];
}

#pragma mark - DDAVCameraDelegate

- (void)camera:(DDAVCamera *)camera didFailWithError:(NSError *)error{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"camera failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新拍照", nil];
    alterView.tag = 1000;
    [alterView show];
}

- (void)camera:(DDAVCamera *)camera didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewController:didFinishPickingMediaWithInfo:)]) {
            [self.delegate cameraViewController:self didFinishPickingMediaWithInfo:info];
        }
    }];
}

#pragma mark - DDCameraBottomViewDelegate

- (void)cameraBottomBarAlbumButtonAction{
    [self.camera stopRunning];
}

- (void)cameraBottomBarTakePhotoButtonAction{
    [self.camera takePicture];
}

- (void)cameraBottomBarCancelButtonAction{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewControllerDidCancel:)]) {
            [self.delegate cameraViewControllerDidCancel:self];
        }
    }];
}

#pragma mark - DDCameraNavigationBarDelegate
- (void)cameraTopBarDidSelectFlashMode:(HMCameraFlashMode)flashMode{
    self.camera.flashMode = (AVCaptureFlashMode)flashMode;
}

- (void)cameraTopBarDidSelectPosition:(HMCameraPosition)position{
    [self.camera switchDevicePosition];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000) {
        if (buttonIndex == 0) {
            [self cameraBottomBarCancelButtonAction];
        }
        else {
            [self.camera startRunning];
        }
    }
    
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark - Getter and Setter

- (DDAVCamera *)camera{
    if (!_camera) {
        _camera = [[DDAVCamera alloc] initWithSuperView:self.preView cameraPosition:AVCaptureDevicePositionBack];
        _camera.delegate = self;
    }
    return _camera;
}

@end
