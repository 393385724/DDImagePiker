//
//  DDPhotoBaseViewController.h
//  FitRunning
//
//  Created by lilingang on 15/9/25.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DDCoreCategory/DDCategoryHeader.h>

extern NSString *const DDPhotoPikerDidFinishedImageNotification;
extern NSString *const DDPhotoPikerDidCancelNotification;

@interface DDPhotoBaseViewController : UIViewController{
    NSString *_rightBarButtonItemTitle;
}

- (void)leftButtonAction;

- (void)rightButtonAction;

@end
