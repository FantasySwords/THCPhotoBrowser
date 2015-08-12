//
//  THCPhotoBrowser.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "THCPhotoBrowser.h"
#import "THCPhotoBrowserItemCell.h"
#import "THCZoomScrollView.h"

@interface THCPhotoBrowser ()<UIScrollViewDelegate>
{
    // Data
    NSUInteger _photoCount;
    
    CGPoint _lastContentOffset;
}

@property (nonatomic, strong) UIScrollView * pagingScrollView;
@property (nonatomic, assign) NSInteger currentItemIndex;

//可视视图队列
@property (nonatomic, strong) NSMutableSet * visibleViewSet;
//重用视图队列
@property (nonatomic, strong) NSMutableSet * reusableViewSet;


//是否正在旋转
@property (nonatomic, assign) BOOL isRotating;



//保存现场
@property (nonatomic ,assign) BOOL preStatusBarHidden;

@end

@implementation THCPhotoBrowser

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIApplication * application = [UIApplication sharedApplication];
    self.preStatusBarHidden = application.statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.preStatusBarHidden];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化变量
    [self initVariable];
    //配置UI
    [self configPhotoBrowserUI];
}

#pragma mark - 初始化变量
- (void)initVariable
{
    if (self.interitemSpacing == 0) {
        self.interitemSpacing = 10;
    }
    
    _photoCount = NSNotFound;
    _currentItemIndex = 0;
    _visibleViewSet = [[NSMutableSet alloc] init];
    _reusableViewSet = [[NSMutableSet alloc] init];
    
    _isRotating = NO;
}

#pragma mark - 配置UI
- (void)configPhotoBrowserUI
{
    self.view.backgroundColor = [UIColor blackColor];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    [self reloadData];
}

#pragma mark - Frame设置

/*PagingScrollView的Frame*/
- (CGRect)frameForPagingScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= self.interitemSpacing;
    frame.size.width += (2 * self.interitemSpacing);
    return frame;
}

- (CGRect)frameForZoomScrollViewAtIndex:(NSInteger)index
{
    CGFloat itemWidth = CGRectGetWidth(_pagingScrollView.bounds);
    CGFloat itemHeight =  CGRectGetHeight(_pagingScrollView.bounds);
    
    return CGRectMake(itemWidth * index + self.interitemSpacing, 0, itemWidth - 2 * self.interitemSpacing, itemHeight);
}


#pragma mark - pagingScrollView
- (CGSize)contentSizeForPagingScrollView
{
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (void)tilePages
{
    CGRect visibleBounds =  _pagingScrollView.bounds;

    NSInteger visibleStartIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds) + self.interitemSpacing*2) / CGRectGetWidth(visibleBounds));
    NSInteger visibleEndIndex = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)- self.interitemSpacing * 2 - 1) / CGRectGetWidth(visibleBounds));
    
    //NSLog(@"visibleStartIndex: %ld %ld %f %f", visibleStartIndex, visibleEndIndex, CGRectGetWidth(visibleBounds), CGRectGetMinX(visibleBounds));
    
    NSInteger itemIndex = NSIntegerMax;
    for (THCZoomScrollView * zoomScrollView in _visibleViewSet) {
        itemIndex = zoomScrollView.index;
        
        if (itemIndex < visibleStartIndex || itemIndex > visibleEndIndex) {
            [self pushZoomScrollViewToResuseQueue:zoomScrollView];
            [zoomScrollView removeFromSuperview];
        }
    }
    [_visibleViewSet minusSet:_reusableViewSet];
    
    while (_reusableViewSet.count > 2) {
        [_reusableViewSet removeObject:[_reusableViewSet anyObject]];
    }
    
    for (NSInteger i = visibleStartIndex; i <= visibleEndIndex; i++) {
        
        if (![self isItemDisplayingForIndex:i] && (i >= 0 && i < [self numberOfPhotos])) {
            
            THCZoomScrollView * zoomScrollView = [self zoomScrollViewFromResuedQueue];
            [_visibleViewSet addObject:zoomScrollView];
            
            zoomScrollView.index = i;
            zoomScrollView.frame = [self frameForZoomScrollViewAtIndex:i];
            
            THCPhotoModel * photoModel = [self photoAtIndex:i];
            zoomScrollView.image = photoModel.photoImage;
            //zoomScrollView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1];
        
            [self.pagingScrollView addSubview:zoomScrollView];
        
        }
    }
}

- (BOOL)isItemDisplayingForIndex:(NSInteger)index
{
    for (THCZoomScrollView * zoomScrollView in _visibleViewSet)
        if (zoomScrollView.index == index) return YES;
    return NO;
}

#pragma mark - ZoomScrollView显示队列，重用队列
//获取重用的ZoomScrollView
- (THCZoomScrollView *)zoomScrollViewFromResuedQueue
{
    THCZoomScrollView * zoomScrollView = nil;
    if (_reusableViewSet.count == 0) {
        zoomScrollView = [[THCZoomScrollView alloc] init];
       // NSLog(@"a new zoomScrollView");
        return zoomScrollView;
    }else{
        zoomScrollView =  [_reusableViewSet anyObject];
        [_reusableViewSet removeObject:zoomScrollView];
        
        // NSLog(@"a reuse zoomScrollView");
    }

    return zoomScrollView;
}

//将暂时不用的ZoomScrollView加入队列
- (void)pushZoomScrollViewToResuseQueue:(THCZoomScrollView *)zoomScrollView
{
    if (_reusableViewSet == nil) {
        _reusableViewSet = [[NSMutableSet alloc] init];
    }
    
    //准备复用ZoomScrollView
    [zoomScrollView prepareForReuse];
    [_reusableViewSet addObject:zoomScrollView];
}

#pragma mark - DataSource
- (NSInteger)numberOfPhotos
{
    if (_photoCount == NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (THCPhotoModel *)photoAtIndex:(NSUInteger)index
{
    THCPhotoModel * photoModel = nil;
    if (index < [self numberOfPhotos]) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
            photoModel = [_delegate photoBrowser:self photoAtIndex:index];
        }
    }

    return photoModel;
}

- (void)reloadData
{
    [self tilePages];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isRotating) {
        return;
    }
   
    [self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentItemIndex =  scrollView.contentOffset.x / scrollView.bounds.size.width;
}

#pragma mark - 配置布局
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    self.pagingScrollView.contentOffset = CGPointMake(self.currentItemIndex * self.pagingScrollView.bounds.size.width, 0);
    for (THCZoomScrollView * view in _visibleViewSet) {
        view.frame = [self frameForZoomScrollViewAtIndex:view.index];
    }
}

#pragma mark - 旋转
- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isRotating = YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _isRotating = NO;
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
