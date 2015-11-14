//
//  DDCameraBottomView.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDCameraBottomView.h"
#import <UIKit/UIKit.h>
#import <DDCoreCategory/DDCategoryHeader.h>

@interface DDCameraBottomView ()

@property (weak, nonatomic) IBOutlet UIView *takePhotoView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;

@end

@implementation DDCameraBottomView

+ (DDCameraBottomView *)loadNibWithOwner:(id)owner{
    NSString *xibName = [[self class] description];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:owner options:nil];
    return [nib objectAtIndex:0];
}

#pragma mark - init

- (void)layoutSubviews{
    [super layoutSubviews];
    self.takePhotoView.layer.masksToBounds = YES;
    self.takePhotoView.layer.borderWidth = 5.0;
    self.takePhotoView.layer.cornerRadius = self.takePhotoView.ddWidth/2.0;
    self.takePhotoView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.takePhotoButton.layer.masksToBounds = YES;
    self.takePhotoButton.layer.borderWidth = 2.5;
    self.takePhotoButton.layer.cornerRadius = self.takePhotoButton.ddWidth/2.0;
    self.takePhotoButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (IBAction)albumButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomBarAlbumButtonAction)]) {
        [self.delegate cameraBottomBarAlbumButtonAction];
    }
}

- (IBAction)photoButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomBarTakePhotoButtonAction)]) {
        [self.delegate cameraBottomBarTakePhotoButtonAction];
    }
}

- (IBAction)cancelButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBottomBarCancelButtonAction)]) {
        [self.delegate cameraBottomBarCancelButtonAction];
    }
}

#pragma mark - Getter and Setter

- (void)setAlbumHiden:(BOOL)albumHiden{
    _albumHiden = albumHiden;
    self.albumButton.hidden = albumHiden;
}
@end
