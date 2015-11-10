//
//  DDPhotoCropView.m
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoCropView.h"

@interface DDPhotoCropView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIImageView *cropImageView;

@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, assign) CGPoint defaultConentOffset;

@end

@implementation DDPhotoCropView

- (instancetype)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame{
    self = [super initWithFrame:frame];
    if (self) {
        self.cropFrame = cropFrame;
        self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.contentScrollView.delegate = self;
        self.contentScrollView.showsHorizontalScrollIndicator = YES;
        self.contentScrollView.showsVerticalScrollIndicator = YES;
        self.contentScrollView.decelerationRate = 0.5;
        self.contentScrollView.minimumZoomScale = 1.0;
        self.contentScrollView.maximumZoomScale = 5.0;
        
        self.showImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.showImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.cropImageView = [[UIImageView alloc] initWithFrame:self.cropFrame];
        self.cropImageView.image = [UIImage imageNamed:@"dd_photo_clipping_mask"];

        [self.contentScrollView addSubview:self.showImageView];
        [self addSubview:self.contentScrollView];
        [self addSubview:self.cropImageView];
    }
    return self;
}

#pragma mark - Private Methods

- (UIImage *)getSubImage{
    CGRect latestFrame = self.showImageView.frame;
    CGFloat scaleRatio = latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = fabs(self.defaultConentOffset.x - self.contentScrollView.contentOffset.x) / scaleRatio;
    CGFloat y = fabs(self.defaultConentOffset.y - self.contentScrollView.contentOffset.y) / scaleRatio;
    CGFloat w = self.cropFrame.size.width / scaleRatio;
    CGFloat h = self.cropFrame.size.height / scaleRatio;
    if (latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height - scrollView.contentInset.top - scrollView.contentInset.bottom) * 0.5 , 0.0);
    self.showImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.showImageView;
}

#pragma mark - getter And setter

- (void)setOriginalImage:(UIImage *)originalImage{
    _originalImage = [originalImage ddImageRotatedWithOrientation];
    self.showImageView.image = _originalImage;
    
    // scale to fit the screen
    if (self.originalImage.size.width < self.originalImage.size.height) {
        CGFloat minWidth = CGRectGetWidth(self.cropFrame);
        CGFloat minHeight = _originalImage.size.height * (minWidth / _originalImage.size.width);
        CGFloat originY = (self.cropFrame.size.height - minHeight) / 2;
        self.showImageView.frame = CGRectMake(0, originY, minWidth, minHeight);
    }
    else {
        CGFloat minHeight = CGRectGetHeight(self.cropFrame);
        CGFloat minWidth = _originalImage.size.width * (minHeight / _originalImage.size.height);
        self.showImageView.frame = CGRectMake(0, 0, minWidth, minHeight);
    }
    self.contentScrollView.contentInset = UIEdgeInsetsMake(self.cropFrame.origin.y, 0, self.contentScrollView.frame.size.height - CGRectGetMaxY(self.cropFrame),0);
    self.contentScrollView.contentSize = self.showImageView.frame.size;

    if (self.originalImage.size.width < self.originalImage.size.height) {
        CGFloat offsetY = (self.bounds.size.height - self.showImageView.frame.size.height)/2.0;
        self.contentScrollView.contentOffset = CGPointMake(0, -offsetY);
        self.showImageView.center = CGPointMake(self.contentScrollView.contentSize.width * 0.5,
                                                self.contentScrollView.contentSize.height * 0.5);
        self.defaultConentOffset = CGPointMake(0,(CGRectGetHeight(self.cropFrame) - CGRectGetHeight(self.showImageView.frame))/2.0 + self.contentScrollView.contentOffset.y);
    }
    else {
        self.defaultConentOffset = self.contentScrollView.contentOffset;;
    }
}
@end
