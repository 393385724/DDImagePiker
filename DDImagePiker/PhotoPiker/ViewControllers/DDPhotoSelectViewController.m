//
//  DDPhotoSelectViewController.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDPhotoSelectViewController.h"
#import "DDPhotoEditViewController.h"

#import "DDPhotoSelectCollectionViewCell.h"


NSString * const DDPhotoSelectCollectionViewCellReuseIdentifier = @"DDPhotoSelectCollectionViewCell";

@interface DDPhotoSelectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (nonatomic, strong) DDPhotoSelectViewControllerHandle *viewControllerHandle;

@end

@implementation DDPhotoSelectViewController

- (void)dealloc{
    self.myCollectionView.dataSource = nil;
    self.myCollectionView.delegate = nil;
}

- (instancetype)initWithAssetHandle:(DDAssetHandle *)assetHandle soureType:(DDPhotoSelectViewSoureType)type{
    self = [super init];
    if (self) {
        self.viewControllerHandle = [[DDPhotoSelectViewControllerHandle alloc] initWithAssetHandle:assetHandle soureType:type];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.viewControllerHandle.assetHandle.currentSelectGroup.groupName;
    [self.myCollectionView registerNib:[UINib nibWithNibName:DDPhotoSelectCollectionViewCellReuseIdentifier bundle:nil] forCellWithReuseIdentifier:DDPhotoSelectCollectionViewCellReuseIdentifier];
    self.myCollectionView.backgroundColor = [UIColor clearColor];

    self.viewControllerHandle.collectionView = self.myCollectionView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsDidChangedNotification:) name:DDAssetsDidChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak __typeof(&*self)weakSelf = self;
    [self.viewControllerHandle fetchGroupAssetCompleteBlock:^(DDAssetGroup *group, NSArray *allAssets, NSError *error) {
        weakSelf.title = group.groupName;
        [weakSelf didFinishFetchAsset:allAssets];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

#pragma mark - Private Methods

- (void)didFinishFetchAsset:(NSArray *)assets{
    self.viewControllerHandle.dataSoure = assets;
    [self.myCollectionView reloadData];
    if ([self.viewControllerHandle.dataSoure count] > 1) {
        [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewControllerHandle.dataSoure.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }

}

- (void)updateCachedAssets{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }
    [self.viewControllerHandle updateCachedAssets];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewControllerHandle.dataSoure count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DDPhotoSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DDPhotoSelectCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    [self.viewControllerHandle requestImageAtIndex:indexPath.row resultHandler:^(UIImage *result, NSDictionary *info) {
        if (cell.tag == currentTag) {
            cell.image = result;
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.viewControllerHandle.assetHandle.currentAsset = self.viewControllerHandle.dataSoure[indexPath.row];
    DDPhotoEditViewController *viewController = [[DDPhotoEditViewController alloc] initWithAsset:self.viewControllerHandle.assetHandle.currentAsset];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateCachedAssets];
}

#pragma mark - Notification
- (void)assetsDidChangedNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        [self.viewControllerHandle resetCachedAssets];
        self.viewControllerHandle.dataSoure = notification.object[DDAssetDataSourceKey];
        BOOL onlyReload = [notification.object[DDAssetNeedReloadKey] boolValue];
        if (onlyReload) {
            [self.myCollectionView reloadData];
        }
        else {
            NSArray *removedIndexPaths = notification.object[DDAssetRemovedIndexPathsKey];
            NSArray *insertedIndexPaths = notification.object[DDAssetInsertedIndexPathsKey];
            NSArray *changedIndexPaths = notification.object[DDAssetChangedIndexPathsKey];
            [self.myCollectionView performBatchUpdates:^{
                if (removedIndexPaths) {
                    [self.myCollectionView deleteItemsAtIndexPaths:removedIndexPaths];
                }
                if (insertedIndexPaths) {
                    [self.myCollectionView insertItemsAtIndexPaths:insertedIndexPaths];
                }
                if (changedIndexPaths) {
                    [self.myCollectionView reloadItemsAtIndexPaths:changedIndexPaths];
                }
            } completion:NULL];
        }
    }
}

@end
