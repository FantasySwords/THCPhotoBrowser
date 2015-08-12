//
//  THCPhoto.h
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface THCPhotoModel : NSObject

@property (nonatomic, strong) UIImage * photoImage;
@property (nonatomic, strong) NSURL * photoURL;

@property (nonatomic, assign) NSInteger tag;



@end
