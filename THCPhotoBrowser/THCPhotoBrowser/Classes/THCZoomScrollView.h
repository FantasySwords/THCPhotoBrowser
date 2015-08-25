//
//  THCZoomScrollView.h
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/29.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCPhotoModel.h"

@class THCZoomScrollView;

@protocol THCZoomScrollViewDelegate <NSObject>
@optional

- (void)zoomScrollView:(THCZoomScrollView *)zoomScrollView singleTap:(UITapGestureRecognizer *)tap isInImageView:(BOOL)isInImageView;
- (void)zoomscrollview:(THCZoomScrollView *)zoomScrollView doubleTapInImageView:(UITapGestureRecognizer *)tap;

@end

@interface THCZoomScrollView : UIScrollView

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) id<THCZoomScrollViewDelegate> actionDelgate;

@property (nonatomic, assign, readonly) CGRect imageViewFrame;

@property (nonatomic, strong) THCPhotoModel * photoModel;

- (void)prepareForReuse;


@end
