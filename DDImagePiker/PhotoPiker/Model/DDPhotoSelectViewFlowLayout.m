//
//  DDPhotoSelectViewFlowLayout.m
//  FitRunning
//
//  Created by lilingang on 15/9/24.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoSelectViewFlowLayout.h"

@implementation DDPhotoSelectViewFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGFloat width = floor(([UIDevice ddScreenWidth] - 5*5)/4.0);
        self.itemSize = CGSizeMake(width, width);
        self.minimumInteritemSpacing = 5;
        self.minimumLineSpacing = 5;
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return self;
}

@end
