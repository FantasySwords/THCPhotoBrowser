//
//  THCPhotoBrowser.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "THCPhotoBrowser.h"
#import "THCZoomScrollView.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface THCPhotoBrowser ()<UIScrollViewDelegate, THCZoomScrollViewDelegate>
{
    // Data
    NSUInteger _photoCount;
    CGPoint _lastContentOffset;
    UIView * _presentingSnapshotView;
}

@property (nonatomic, weak) UIViewController * fromViewController;

@property (nonatomic, strong) UIScrollView * pagingScrollView;
//当前呈现图像index
@property (nonatomic, assign) NSInteger currentItemIndex;
//可视视图队列
@property (nonatomic, strong) NSMutableSet * visibleViewSet;
//重用视图队列
@property (nonatomic, strong) NSMutableSet * reusableViewSet;
//是否正在旋转
@property (nonatomic, assign) BOOL isRotating;
//保存现场
@property (nonatomic ,assign) BOOL preStatusBarHidden;

@property (nonatomic, strong) UILabel * pagingLabel;
@property (nonatomic, strong) UIButton * saveButton;



@end

@implementation THCPhotoBrowser

- (instancetype)init
{
    if (self = [super init]) {
        [self initVariable];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initVariable];
    }
    return self;
}

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
    //配置UI
    [self configPhotoBrowserUI];
}

#pragma mark - 初始化变量
- (void)initVariable
{
    self.interitemSpacing = 10;
    _photoCount = NSNotFound;
    _currentItemIndex = 0;
    _presnetAnimateDuration = 0.35;
    _dismissAnimateDuration = 0.25;
    
    _presnetAnimateDuration = 6;
    _dismissAnimateDuration = 6;
    _visibleViewSet = [[NSMutableSet alloc] init];
    _reusableViewSet = [[NSMutableSet alloc] init];
    
    _isRotating = NO;
}

#pragma mark - 配置UI
- (void)configPhotoBrowserUI
{
    self.view.backgroundColor = [UIColor clearColor];
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
    [self showIndexItem:_currentItemIndex];
    _pagingScrollView.hidden = YES;
    
    _pagingLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 100.f, 20.f)];
    _pagingLabel.center = CGPointMake(self.view.frame.size.width / 2, 30.f);
    _pagingLabel.font = [UIFont systemFontOfSize:18 weight:0.5];
    _pagingLabel.textAlignment = NSTextAlignmentCenter;
    _pagingLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_pagingLabel];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake(15, CGRectGetHeight([UIScreen mainScreen].bounds) - 40 , 45, 25);
    _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _saveButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _saveButton.layer.cornerRadius = 3;
    _saveButton.layer.masksToBounds = YES;
    _saveButton.layer.borderWidth = 1;
    _saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
   
    if ([self numberOfPhotos] > 1) {
        _pagingLabel.text = [NSString stringWithFormat:@"%ld/%ld", _currentItemIndex + 1, [self numberOfPhotos]];
    }
}

#pragma mark - saveButtonClicked Action
- (void)saveButtonClicked
{
    for (THCZoomScrollView * view in _visibleViewSet) {
        view.frame = [self frameForZoomScrollViewAtIndex:view.index];
        
        if (view.index == _currentItemIndex) {
         
            if (view.imageView.image) {
                self.saveButton.enabled = NO;
                UIImageWriteToSavedPhotosAlbum(view.imageView.image, self, @selector(photoSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
            return;
        }
    }
}

- (void)photoSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.cornerRadius = 5.f;
    hud.opacity = 0.75f;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.margin = 10;
    hud.mode = MBProgressHUDModeCustomView;
    
    UIView * hudCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    UIImageView * alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    alertImageView.image = [UIImage imageNamed:@"thc_pb_error_icon"];
    alertImageView.center = CGPointMake(CGRectGetMidX(hudCustomView.frame), CGRectGetMidY(hudCustomView.frame));
    
    [hudCustomView addSubview:alertImageView];
    NSString * alertImageName = nil;
    if (!error) {
        alertImageName = @"thc_pb_success_icon.png";
        hud.labelText = @"保存成功";
    }else
    {
        alertImageName = @"thc_pb_error_icon.png";
        hud.labelText = @"保存失败";
    }
    
    NSString *imagePathInBundle = [NSString stringWithFormat:@"THCPhotoBrowser.bundle/%@",  alertImageName];
    alertImageView.image = [UIImage imageNamed:imagePathInBundle];
    hud.customView = hudCustomView;
    [hud show:YES];
    [hud hide:YES afterDelay:2];
    
    self.saveButton.enabled = YES;
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
            zoomScrollView.actionDelgate = self;
            THCPhotoModel * photoModel = [self photoAtIndex:i];
            zoomScrollView.photoModel = photoModel;
            
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
        return zoomScrollView;
    }else{
        zoomScrollView =  [_reusableViewSet anyObject];
        [_reusableViewSet removeObject:zoomScrollView];
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

- (void)showIndexItem:(NSInteger) index
{
    self.pagingScrollView.contentOffset = CGPointMake(CGRectGetWidth(_pagingScrollView.bounds) * index, _pagingScrollView.contentOffset.y);
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

#pragma mark - 配置布局
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    self.pagingScrollView.contentOffset = CGPointMake(self.currentItemIndex * self.pagingScrollView.bounds.size.width, 0);
    for (THCZoomScrollView * view in _visibleViewSet) {
        view.frame = [self frameForZoomScrollViewAtIndex:view.index];
    }
    
    _pagingLabel.center = CGPointMake(self.view.frame.size.width / 2, 30.f);
    _saveButton.frame = CGRectMake(15, CGRectGetHeight([UIScreen mainScreen].bounds) - 40 , 45, 25);
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
    
    if ([self numberOfPhotos] > 1) {
        _pagingLabel.text = [NSString stringWithFormat:@"%ld/%ld", _currentItemIndex + 1, [self numberOfPhotos]];
    }
}

#pragma mark - THCZoomScrollViewDelegate
- (void)zoomScrollView:(THCZoomScrollView *)zoomScrollView singleTap:(UITapGestureRecognizer *)tap isInImageView:(BOOL)isInImageView
{
    [self dismiss:YES];
}

- (void)zoomscrollview:(THCZoomScrollView *)zoomScrollView doubleTapInImageView:(UITapGestureRecognizer *)tap
{
    
}

#pragma mark - Private

- (CGRect) frameForImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGFloat scaleWidth = 0;
    CGFloat scaleHeight = 0;
    CGFloat scaleOriginX = 0;
    CGFloat scaleOriginY = 0;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        
        if (imageSize.height / imageSize.width  > 2) {
            scaleWidth = CGRectGetWidth(self.view.frame);
            scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
            scaleOriginY = 0;
            scaleOriginX = (CGRectGetWidth(self.view.frame) - scaleWidth) / 2;
        }else {
            scaleWidth = CGRectGetWidth(self.view.frame);
            scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
            scaleOriginY = (CGRectGetHeight(self.view.frame) - scaleHeight) / 2;
        }
       
    }else{
        //长图
        if (imageSize.height / imageSize.width  > 2) {
            scaleWidth = CGRectGetWidth(self.view.frame);
            scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
            scaleOriginY = 0;
            scaleOriginX = (CGRectGetWidth(self.view.frame) - scaleWidth) / 2;
        }else { //一般图
            scaleHeight = CGRectGetHeight(self.view.frame);
            scaleWidth = image.size.width / (image.size.height / scaleHeight);
            scaleOriginX = (CGRectGetWidth(self.view.frame) - scaleWidth) / 2;
        }
    }
    
    return CGRectMake(scaleOriginX, scaleOriginY, scaleWidth, scaleHeight);
}

/*这段代码来自JTSImageVC*/
- (UIView *)snapshotFromParentingViewController:(UIViewController *)viewController {
    
    UIViewController *presentingViewController = viewController.view.window.rootViewController;
    while (presentingViewController.presentedViewController) presentingViewController = presentingViewController.presentedViewController;
    UIView *snapshot = [presentingViewController.view snapshotViewAfterScreenUpdates:YES];
    snapshot.clipsToBounds = NO;
    return snapshot;
}

- (void)prepareForDismiss
{
    self.pagingLabel.hidden = YES;
    self.pagingScrollView.hidden = YES;
}

#pragma mark - Public
- (void)presentFromViewController:(UIViewController *)fromViewController index:(NSInteger)index
{
    _currentItemIndex = index;
    _fromViewController = fromViewController;
    
    _presentingSnapshotView = [self snapshotFromParentingViewController:fromViewController];
    
    [_fromViewController presentViewController:self animated:NO completion:^{
        
        [self showIndexItem:index];
        
        THCPhotoModel * photoModel = [self photoAtIndex:index];
        CGRect sourceFrame = [photoModel.sourceImageView convertRect:photoModel.sourceImageView.bounds toView:fromViewController.view ];
        
        UIImageView * transitionImageView = [[UIImageView alloc] initWithFrame:sourceFrame];
        transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
        [transitionImageView sd_setImageWithURL:photoModel.thumbnailPhotoURL];
        [self.view addSubview:transitionImageView];
        self.pagingScrollView.hidden = YES;
        
        [UIView animateWithDuration:self.presnetAnimateDuration animations:^{
            
            transitionImageView.frame = [self frameForImage:transitionImageView.image];
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                [transitionImageView removeFromSuperview];
                self.pagingScrollView.hidden = NO;
                
            }
        }];
    }];
}

- (void)dismiss:(BOOL)animated
{
    if (!animated) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }else {

        [self prepareForDismiss];
        [self.view addSubview:_presentingSnapshotView];
        [self.view sendSubviewToBack:_presentingSnapshotView];
        
        THCPhotoModel * photoModel = [self photoAtIndex:_currentItemIndex];
        CGRect sourceFrame = [photoModel.sourceImageView convertRect:photoModel.sourceImageView.bounds toView:_fromViewController.view ];
        UIImage * image = photoModel.sourceImageView.image;
        
        UIImageView * transitionImageView = [[UIImageView alloc]initWithFrame:[self frameForImage:image]];
        transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
        transitionImageView.image = image;
        transitionImageView.clipsToBounds = YES;
        [self.view addSubview:transitionImageView];
        
        [UIView animateWithDuration:self.dismissAnimateDuration animations:^{
            transitionImageView.frame = sourceFrame;
        } completion:^(BOOL finished) {
            
            [self dismissViewControllerAnimated:NO completion:^{
               
            }];
        }];
        
    }
}


#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
