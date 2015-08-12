//
//  THCZoomScrollView.h
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/29.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THCZoomScrollView : UIScrollView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage * image;

- (void)prepareForReuse;

@end
