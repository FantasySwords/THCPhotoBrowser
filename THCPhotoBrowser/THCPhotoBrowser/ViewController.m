//
//  ViewController.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewCell.h"
#import "THCPhotoBrowser.h"
#import "THCPhotoModel.h"


@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,THCPhotoBrowserDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"THC图片浏览器";
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 40) / 3;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[ImageViewCell class] forCellWithReuseIdentifier:@"ImageViewCell"];
    [self.view addSubview:self.collectionView];
    
    
    self.dataSource = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 11; i++) {
        THCPhotoModel * photoModel = [[THCPhotoModel alloc] init];
        photoModel.photoImage = [UIImage imageNamed:[NSString stringWithFormat:@"pic%ld.jpg", i]];
        photoModel.tag = i;
        [self.dataSource addObject:photoModel];
    }
    
 }

- (void)viewWillLayoutSubviews
{
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDelegate、UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ImageViewCell";
    ImageViewCell * cell =  [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic%ld.jpg", indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    THCPhotoBrowser * photoBrowser = [[THCPhotoBrowser alloc] init];
    photoBrowser.delegate = self;
    [photoBrowser presentFromViewController:self index:indexPath.row];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10,10);
}


#pragma mark - THCPhotoBrowserDelegate
- (NSInteger)numberOfPhotosInPhotoBrowser:(THCPhotoBrowser *)photoBrowser
{
    return self.dataSource.count;
}

-(THCPhotoModel*)photoBrowser:(THCPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    THCPhotoModel * photoModel = self.dataSource[index];
     ImageViewCell * cell = (ImageViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    photoModel.sourceImageView = cell.imageView;
    
    return photoModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
