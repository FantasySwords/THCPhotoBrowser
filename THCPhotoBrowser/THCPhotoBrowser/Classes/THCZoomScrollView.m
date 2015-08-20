//
//  THCZoomScrollView.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/29.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "THCZoomScrollView.h"
#import "UIImageView+WebCache.h"
#import "DACircularProgressView.h"

@interface THCZoomScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) UIInterfaceOrientation lastInterfaceOrientaion;
@property (nonatomic, strong) DACircularProgressView * progressView;



@end

@implementation THCZoomScrollView

#pragma mark - 构造函数

- (id)init
{
    if (self = [super init]) {
        [self initVariable];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initVariable];
        [self configZoomScrollViewUI];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initVariable];
    }
    return self;
}

#pragma mark - 初始化变量
- (void)initVariable
{
    _isZooming = NO;
    _lastInterfaceOrientaion = [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark - 配置UI
- (void)configZoomScrollViewUI
{
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self setClipsToBounds:NO];
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 2.5f;
    self.multipleTouchEnabled = YES;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setClipsToBounds:NO];
    [self addSubview:self.imageView];
    
    //手势
    UITapGestureRecognizer * imageViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewSingleClicked:)];
    imageViewSingleTap.numberOfTouchesRequired = 1;
    imageViewSingleTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:imageViewSingleTap];
    
    UITapGestureRecognizer * imageViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleClicked:)];
    imageViewDoubleTap.numberOfTapsRequired = 2;
    imageViewDoubleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:imageViewDoubleTap];
    
    [imageViewSingleTap requireGestureRecognizerToFail:imageViewDoubleTap];
    
    UITapGestureRecognizer * scrollViewSingleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleClicked:)];
    [self addGestureRecognizer:scrollViewSingleTap];
    
    //DACircularProgressView
    _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    _progressView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f, CGRectGetHeight(self.bounds) / 2.f);
    _progressView.roundedCorners = YES;
    _progressView.trackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
 
    [_progressView setProgress:0.4 animated:YES];
    [self addSubview:_progressView];
    _progressView.hidden = YES;
}

#pragma mark - 布局
- (void)layoutSubviews
{
    if ([[UIApplication sharedApplication] statusBarOrientation] != _lastInterfaceOrientaion) {
        [self zoomScrollViewWillRotate];
    }
    
    _progressView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f, CGRectGetHeight(self.bounds) / 2.f);
    
    _lastInterfaceOrientaion = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)zoomScrollViewWillRotate
{
    _isZooming = NO;
    self.zoomScale = 1.0f;
    self.imageView.frame = [self frameForImageView];
}

#pragma mark - Frame
- (CGRect) frameForImageView
{
    if (!self.imageView.image) {
        return CGRectZero;
    }
    
    UIImage * image = self.imageView.image;
    
    CGSize imageSize = image.size;
    CGFloat scaleWidth = 0;
    CGFloat scaleHeight = 0;
    CGFloat scaleOriginX = 0;
    CGFloat scaleOriginY = 0;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        scaleWidth = CGRectGetWidth(self.frame);
        scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
        scaleOriginY = (CGRectGetHeight(self.frame) - scaleHeight) / 2;
        
    }else{
        //长图
        if (imageSize.height / imageSize.width  > 2) {
            scaleWidth = CGRectGetWidth(self.frame);
            scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
            scaleOriginY = (CGRectGetHeight(self.frame) - scaleHeight) / 2;
            scaleOriginX = (CGRectGetWidth(self.frame) - scaleWidth) / 2;
        }else { //一般图
            scaleHeight = CGRectGetHeight(self.frame);
            scaleWidth = image.size.width / (image.size.height / scaleHeight);
            scaleOriginX = (CGRectGetWidth(self.frame) - scaleWidth) / 2;
        }
    }
    
    self.contentSize = self.bounds.size;
    
    if (scaleHeight > CGRectGetHeight(self.frame)) {
        scaleOriginY = 0;
        self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), scaleHeight);
    }
    return CGRectMake(scaleOriginX, scaleOriginY, scaleWidth, scaleHeight);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = CGRectGetHeight(self.bounds) / scale;
    zoomRect.size.width = CGRectGetWidth(self.bounds)  / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (CGRectGetWidth(scrollView.bounds) > scrollView.contentSize.width) ?(CGRectGetWidth(scrollView.bounds) - scrollView.contentSize.width) / 2 : 0.f;
    CGFloat offsetY = (CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) ?(CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height) / 2 : 0.f;
    self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Public
- (void)prepareForReuse
{
    _index = 0;
    _photoModel = nil;
    _imageView.image = nil;
    _isZooming = NO;
    self.zoomScale = 1.0f;
    self.progressView.hidden = YES;
    [self.progressView setProgress:0.f];
    
    self.contentOffset = CGPointZero;
}

- (void) setImage:(UIImage *)image
{
    self.imageView.image = image;
    if (image == nil) {
        return;
    }
    
    self.imageView.frame = [self frameForImageView];
}

- (CGRect)imageViewFrame
{
    return _imageView.frame;
}

- (void)setPhotoModel:(THCPhotoModel *)photoModel
{
    [self.imageView sd_setImageWithURL:photoModel.originalphotoURL placeholderImage:photoModel.sourceImageView.image options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:((float)receivedSize) / expectedSize animated:YES];
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.progressView.hidden = YES;
        [self setImage:image];
    }];
}

#pragma mark - Tap Action

- (void)imageViewSingleClicked:(UITapGestureRecognizer *)tap
{
    if ([self.actionDelgate respondsToSelector:@selector(zoomScrollView:singleTap:isInImageView:)]) {
        [self.actionDelgate zoomScrollView:self singleTap:tap isInImageView:YES];
    }
}

- (void)imageViewDoubleClicked:(UITapGestureRecognizer *)tap
{
    float newScale = 0.f;
    if (_isZooming) { //执行缩小动作
        newScale = 1.0f;
        _isZooming = NO;
    }else { //执行放大动作
        newScale = 2.5;
        _isZooming = YES;
    }
    
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[tap locationInView:tap.view]];
    [self zoomToRect:zoomRect animated:YES];
    
    if ([self.actionDelgate respondsToSelector:@selector(zoomscrollview:doubleTapInImageView:)]) {
        [self.actionDelgate zoomscrollview:self doubleTapInImageView:tap];
    }
}

- (void)scrollViewSingleClicked:(UITapGestureRecognizer *)tap
{
    CGPoint pt =  [tap locationInView:self.imageView];
    
    if (!(pt.x >= CGRectGetMinX(_imageView.bounds)
          && pt.x <= CGRectGetMaxX(_imageView.bounds)
          && pt.y >= CGRectGetMinY(_imageView.bounds)
          && pt.y <= CGRectGetMaxY(_imageView.bounds))) {
        
        if ([self.actionDelgate respondsToSelector:@selector(zoomScrollView:singleTap:isInImageView:)]) {
            [self.actionDelgate zoomScrollView:self singleTap:tap isInImageView:NO];
        }
    }
}

@end
