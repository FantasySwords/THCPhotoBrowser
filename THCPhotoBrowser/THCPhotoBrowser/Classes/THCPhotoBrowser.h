//
//  THCPhotoBrowser.h
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCPhotoModel.h"

@class THCPhotoBrowser;
@class THCPhotoModel;

@protocol THCPhotoBrowserDelegate <NSObject>

@required
- (NSInteger)numberOfPhotosInPhotoBrowser:(THCPhotoBrowser *)photoBrowser;
- (THCPhotoModel *)photoBrowser:(THCPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@end


@interface THCPhotoBrowser : UIViewController

//图像之间的宽度
@property (nonatomic, assign) CGFloat lineSpaces;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, weak) id<THCPhotoBrowserDelegate> delegate;

@end
