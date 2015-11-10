//
//  DDPhotoAlbumTableViewCell.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoAlbumTableViewCell.h"
#import "DDAssetGroup.h"

@interface DDPhotoAlbumTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

@implementation DDPhotoAlbumTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:22 green:24 blue:25 alpha:0.5];
    }
    return self;
}

- (void)updateWithAssetGroup:(DDAssetGroup *)assetGroup{
    self.iconImageView.image = assetGroup.thumbnail;
    self.titleLabel.text = assetGroup.groupName;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)assetGroup.numberOfAssets];
}

@end
