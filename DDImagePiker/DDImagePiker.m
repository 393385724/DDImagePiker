//
//  DDImagePiker.m
//  FitRunning
//
//  Created by lilingang on 15/10/13.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDImagePiker.h"

#import "DDPhotoNavigationController.h"
#import "DDCameraViewController.h"
#import "DDPhotoAlbumViewController.h"
#import "DDPhotoSelectViewController.h"

#import "DDAssetHandle.h"

@interface DDImagePiker ()<DDCameraViewControllerDelegate>

@property (nonatomic, strong) DDAssetHandle *assetHandle;

@end

@implementation DDImagePiker

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPikerDidCancelNotification:) name:DDPhotoPikerDidCancelNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPikerDidFinishedImageNotification:) name:DDPhotoPikerDidFinishedImageNotification object:nil];
    }
    return self;
}

+ (void)requestAuthorization:(void(^)(bool granted))handler{
    return [DDAssetHandle requestAuthorization:handler];
}

- (void)showInViewController:(UIViewController *)viewController
                   soureType:(DDImagePickerSourceType)soureType
                    animated:(BOOL)animated;{
    if (soureType == DDImagePickerSourceTypePhotoLibrary) {
        [DDAssetHandle requestAuthorization:^(bool granted) {
            if (granted) {
                DDPhotoAlbumViewController *albumViewController = [[DDPhotoAlbumViewController alloc] initWithAssetHandle:self.assetHandle];
                DDPhotoSelectViewController *selectViewController = [[DDPhotoSelectViewController alloc] initWithAssetHandle:self.assetHandle soureType:DDPhotoSelectViewSoureTypeDefault];
                DDPhotoNavigationController *navigationController = [[DDPhotoNavigationController alloc] init];
                navigationController.viewControllers = @[albumViewController,selectViewController];
                [viewController presentViewController:navigationController animated:YES completion:nil];
            }
        }];

    }
    else if (soureType == DDImagePickerSourceTypeCamera){
        DDCameraViewController *cameraViewController = [[DDCameraViewController alloc] init];
        cameraViewController.delegate = self;
        DDPhotoNavigationController *navigationController = [[DDPhotoNavigationController alloc] initWithRootViewController:cameraViewController];
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}



#pragma mark - DDCameraViewControllerDelegate

- (void)cameraViewController:(DDCameraViewController *)camera didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didFinishPickingMediaWithInfo:)]) {
        [self.delegate imagePicker:self didFinishPickingMediaWithInfo:info];
    }
}

- (void)cameraViewControllerDidCancel:(DDCameraViewController *)camera{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}

#pragma mark - Notification

- (void)photoPikerDidFinishedImageNotification:(NSNotification *)notification{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didFinishPickingMediaWithInfo:)]) {
        [self.delegate imagePicker:self didFinishPickingMediaWithInfo:notification.object];
    }
}

- (void)photoPikerDidCancelNotification:(NSNotification *)notification{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}

#pragma mark - Getter and Setter

- (DDAssetHandle *)assetHandle {
    if (!_assetHandle) {
        _assetHandle = [[DDAssetHandle alloc] init];
    }
    return _assetHandle;
}

@end
