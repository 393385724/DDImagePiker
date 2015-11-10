//
//  DDPhotoBaseViewController.m
//  FitRunning
//
//  Created by lilingang on 15/9/25.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoBaseViewController.h"

NSString *const DDPhotoPikerDidFinishedImageNotification = @"DDPhotoPikerDidFinishedImageNotification";
NSString *const DDPhotoPikerDidCancelNotification = @"DDPhotoPikerDidCancelNotification";

@interface DDPhotoBaseViewController ()

@end

@implementation DDPhotoBaseViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        _rightBarButtonItemTitle = @"取消";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(22, 24, 25);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dd_photo_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonAction)];

    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [rightButton setTitle:_rightBarButtonItemTitle forState:UIControlStateNormal];
    [rightButton setTitleShadowColor:RGBCOLOR(127, 127, 127) forState:UIControlStateNormal];
    [rightButton setTitleColor:RGBCOLOR(255, 95, 0) forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Action

- (void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DDPhotoPikerDidCancelNotification object:nil];
    }];
}

@end
