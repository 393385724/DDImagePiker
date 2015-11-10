//
//  DDPhotoEditViewController.m
//  FitRunning
//
//  Created by lilingang on 15/10/10.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoEditViewController.h"
#import "DDPhotoCropView.h"

@interface DDPhotoEditViewController ()

@property (nonatomic, strong) DDPhotoCropView *photoCropView;

@property (nonatomic, strong) DDPhotoEditViewControllerHandle *viewControllerHandle;

@end

@implementation DDPhotoEditViewController

- (instancetype)initWithAsset:(DDAsset *)asset{
    self = [super init];
    if (self) {
        self.viewControllerHandle = [[DDPhotoEditViewControllerHandle alloc] initWithDDAsset:asset];
        _rightBarButtonItemTitle = @"完成";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片裁剪";
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat photoCropViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - 64;
    self.photoCropView = [[DDPhotoCropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, photoCropViewHeight) cropFrame:CGRectMake(0, (photoCropViewHeight - screenWidth)/2.0, screenWidth, screenWidth)];
    self.photoCropView.originalImage = [self.viewControllerHandle tmpImage];
    [self.view addSubview:self.photoCropView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetDetailDidChangedNotification:) name:DDAssetDetailDidChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    __weak __typeof(&*self)weakSelf = self;
    [self.viewControllerHandle requestImageResultHandler:^(UIImage *result, NSDictionary *info) {
        weakSelf.photoCropView.originalImage = result;
    }];
}

#pragma mark - Private Methods

- (void)rightButtonAction{
    UIImage *image = [self.photoCropView getSubImage];
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
    [infoDictionary setObject:image forKey:UIImagePickerControllerEditedImage];
    [infoDictionary setObject:self.photoCropView.originalImage forKey:UIImagePickerControllerOriginalImage];
    [infoDictionary setObject:NSStringFromCGRect(self.photoCropView.cropFrame) forKey:UIImagePickerControllerCropRect];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DDPhotoPikerDidFinishedImageNotification object:infoDictionary];
    }];
}

#pragma mark - Notification

- (void)assetDetailDidChangedNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        self.viewControllerHandle.asset = notification.object[DDAssetDetailKey];
        [self.viewControllerHandle requestImageResultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                self.photoCropView.originalImage = result;
            }
        }];
    }
}

@end
