//
//  ImageViewCell.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "ImageViewCell.h"

@implementation ImageViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configImageViewCellUI];
    }
    
    return self;
}


#pragma mark - 配置UI
- (void) configImageViewCellUI
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
}

- (void)layoutSubviews
{
    self.imageView.frame = self.bounds;
}

@end
