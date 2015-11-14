//
//  DDPhotoNavigationController.m
//  FitRunning
//
//  Created by lilingang on 15/9/25.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoNavigationController.h"
#import <DDCoreCategory/DDCategoryHeader.h>

@interface DDPhotoNavigationController ()

@end

@implementation DDPhotoNavigationController

- (void)loadView {
    [super loadView];
    [self.navigationBar setBackgroundImage:[UIImage ddImageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage ddImageWithColor:[UIColor clearColor]]];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSFontAttributeName : [UIFont systemFontOfSize:17]};
    [self.navigationBar setTitleTextAttributes:titleTextAttributes];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


@end
