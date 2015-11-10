//
//  DDPhotoCropView.h
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPhotoCropView : UIView

@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign, readonly) CGRect cropFrame;

- (instancetype)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame;

- (UIImage *)getSubImage;

@end
