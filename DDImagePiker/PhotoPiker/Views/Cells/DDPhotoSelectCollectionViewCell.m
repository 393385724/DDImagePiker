//
//  DDPhotoSelectCollectionViewCell.m
//  FitRunning
//
//  Created by lilingang on 15/9/24.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoSelectCollectionViewCell.h"

@interface DDPhotoSelectCollectionViewCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation DDPhotoSelectCollectionViewCell

- (void)awakeFromNib {
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.iconImageView.image = image;
}

@end
