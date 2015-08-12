//
//  THCPhotoBrowserItemCell.h
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/29.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THCZoomScrollView;

@interface THCPhotoBrowserItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImage * image;

@property (nonatomic, strong, readonly) THCZoomScrollView * zoomScrollView;

@end
