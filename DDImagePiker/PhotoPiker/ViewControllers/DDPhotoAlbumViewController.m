//
//  DDPhotoAlbumViewController.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoAlbumViewController.h"
#import "DDPhotoSelectViewController.h"

#import "DDPhotoAlbumTableViewCell.h"

#import "DDAssetHandle.h"

NSString * const DDPhotoAlbumTableViewCellReuseIdentifier = @"DDPhotoAlbumTableViewCell";

@interface DDPhotoAlbumViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) DDAssetHandle *assetHandle;

@property (nonatomic, strong) NSArray *dataSoure;

@end

@implementation DDPhotoAlbumViewController

- (void)dealloc {
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
}

- (instancetype)initWithAssetHandle:(DDAssetHandle *)assetHandle{
    self = [super init];
    if (self) {
        self.assetHandle = assetHandle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片";
    self.navigationItem.leftBarButtonItem = nil;
    [self.myTableView registerNib:[UINib nibWithNibName:DDPhotoAlbumTableViewCellReuseIdentifier bundle:nil] forCellReuseIdentifier:DDPhotoAlbumTableViewCellReuseIdentifier];
    self.myTableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetGroupDidChangedNotification:) name:DDAssetGroupDidChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak __typeof(&*self)weakSelf = self;
    [self.assetHandle fetchGroupCompleteBlock:^(NSArray *allGroup, NSError *error) {
        weakSelf.dataSoure = allGroup;
        [weakSelf.myTableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSoure count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DDPhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPhotoAlbumTableViewCellReuseIdentifier];
    [cell updateWithAssetGroup:self.dataSoure[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.assetHandle.currentSelectGroup = self.dataSoure[indexPath.row];
    
    DDPhotoSelectViewController *viewController = [[DDPhotoSelectViewController alloc] initWithAssetHandle:self.assetHandle soureType:DDPhotoSelectViewSoureTypeGroup];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Notification

- (void)assetGroupDidChangedNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        self.dataSoure = notification.object[DDAssetDataSourceKey];
        [self.myTableView reloadData];
    }
}

@end
