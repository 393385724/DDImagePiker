//
//  DDCameraNavigationBar.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDCameraNavigationBar.h"

@interface DDCameraNavigationBar ()

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *positionButton;

@property (weak, nonatomic) IBOutlet UIView *flashControlView;
@property (weak, nonatomic) IBOutlet UIButton *autoFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *openFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *closeFlashButton;

@property (nonatomic, assign) HMCameraFlashMode flashMode;
@property (nonatomic, assign) HMCameraPosition position;
@end

@implementation DDCameraNavigationBar

+ (DDCameraNavigationBar *)loadNibWithOwner:(id)owner{
    NSString *xibName = [[self class] description];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:owner options:nil];
    return [nib objectAtIndex:0];
}

#pragma mark - Public Methods

- (void)reloadWithflashEnabled:(BOOL)flashEnabled
                     flashMode:(HMCameraFlashMode)flashMode
               positionEnabled:(BOOL)positionEnabled{
    self.flashMode = flashMode;
    self.position = HMCameraPositionBack;
    if (positionEnabled && flashEnabled) {
        self.flashButton.hidden = NO;
        self.positionButton.hidden = NO;
    } else if (flashEnabled) {
        self.flashButton.hidden = NO;
    } else if (positionEnabled){
        self.positionButton.hidden = NO;
    }
}

#pragma mark - Button Actions

- (IBAction)flashButtonAction:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.flashControlView.alpha = 1.0 - self.flashControlView.alpha;
    }];
}

- (IBAction)positionButtonAction:(id)sender {
    if (self.position == HMCameraPositionBack) {
        self.position = HMCameraPositionFront;
    } else {
        self.position = HMCameraPositionBack;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraTopBarDidSelectPosition:)]) {
        [self.delegate cameraTopBarDidSelectPosition:self.position];
    }
}

- (IBAction)autoButtonAction:(id)sender {
    [self didSelectFlashMode:HMCameraFlashModeAuto];
}

- (IBAction)openButtonAction:(id)sender {
    [self didSelectFlashMode:HMCameraFlashModeOn];
}

- (IBAction)closeButtonAction:(id)sender {
    [self didSelectFlashMode:HMCameraFlashModeOff];
}

#pragma mark - Logic

- (void)didSelectFlashMode:(HMCameraFlashMode)flashMode{
    self.flashMode = flashMode;
    [UIView animateWithDuration:0.25 animations:^{
        self.flashControlView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraTopBarDidSelectFlashMode:)]) {
            [self.delegate cameraTopBarDidSelectFlashMode:flashMode];
        }
    }];
}

- (void)resetFlashControlView{
    [self.autoFlashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.openFlashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeFlashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark - Getter and setter

- (void)setFlashMode:(HMCameraFlashMode)flashMode{
    _flashMode = flashMode;
    [self resetFlashControlView];
    if (flashMode == HMCameraFlashModeAuto) {
        [self.autoFlashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else if (flashMode == HMCameraFlashModeOff){
        [self.closeFlashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else {
        [self.openFlashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
}

- (void)setPosition:(HMCameraPosition)position{
    _position = position;
    if (position == HMCameraPositionBack) {
        [self.positionButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    else if (position == HMCameraPositionFront){
        [self.positionButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
}


@end
