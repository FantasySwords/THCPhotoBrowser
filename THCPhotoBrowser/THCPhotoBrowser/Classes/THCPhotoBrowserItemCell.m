//
//  THCPhotoBrowserItemCell.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/29.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "THCPhotoBrowserItemCell.h"
#import "THCZoomScrollView.h"

@interface THCPhotoBrowserItemCell ()

@property (nonatomic, strong) THCZoomScrollView * zoomScrollView;

@end


@implementation THCPhotoBrowserItemCell


#pragma mark - 初始化函数
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configPhotoBrowserItemCellUI];
    }
    
    return self;
}


#pragma mark - 配置UI

- (void)configPhotoBrowserItemCellUI
{
    self.zoomScrollView = [[THCZoomScrollView alloc] initWithFrame:self.bounds];
   // self.zoomScrollView.backgroundColor = [UIColor brownColor];
    [self addSubview:self.zoomScrollView];
}



#pragma mark - public
- (void)setImage:(UIImage *)image
{
    self.zoomScrollView.image = image;
}





@end
