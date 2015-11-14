//
//  DDMainViewController.m
//  DDImagePikerDemo
//
//  Created by lilingang on 15/11/11.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDMainViewController.h"
#import "DDImagePiker.h"

@interface DDMainViewController ()<DDImagePikerDelegate>

@property (nonatomic, strong) DDImagePiker *imagePiker;

@end

@implementation DDMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagePiker = [[DDImagePiker alloc] init];
    self.imagePiker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)takePhoto:(id)sender {
    [self.imagePiker showInViewController:self soureType:DDImagePickerSourceTypeCamera animated:YES];
}

- (IBAction)photoLibrary:(id)sender {
    [self.imagePiker showInViewController:self soureType:DDImagePickerSourceTypePhotoLibrary animated:YES];
}


- (void)imagePicker:(DDImagePiker *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
}
- (void)imagePickerDidCancel:(DDImagePiker *)picker{
    
}

@end
