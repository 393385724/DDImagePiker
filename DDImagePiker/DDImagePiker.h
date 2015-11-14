//
//  DDImagePiker.h
//  FitRunning
//
//  Created by lilingang on 15/10/13.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//资源选取途径
typedef NS_ENUM(NSInteger, DDImagePickerSourceType) {
    DDImagePickerSourceTypePhotoLibrary = 0,
    DDImagePickerSourceTypeCamera,
};

@class DDImagePiker;

@protocol DDImagePikerDelegate <NSObject>
@optional
- (void)imagePicker:(DDImagePiker *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerDidCancel:(DDImagePiker *)picker;
@end

@interface DDImagePiker : NSObject

@property (nonatomic, weak) id<DDImagePikerDelegate> delegate;

+ (void)requestAuthorization:(void(^)(bool granted))handler;

- (void)showInViewController:(UIViewController *)viewController
                   soureType:(DDImagePickerSourceType)soureType
                    animated:(BOOL)animated;

@end
