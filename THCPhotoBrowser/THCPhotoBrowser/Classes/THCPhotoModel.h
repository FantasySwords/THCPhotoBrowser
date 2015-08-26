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

@property (nonatomic, strong) UIImage * thumbnailPhoto;
@property (nonatomic, strong) NSURL * thumbnailPhotoURL;

@property (nonatomic, strong) UIImage * originalPhoto;
@property (nonatomic, strong) NSURL * originalphotoURL;

@property (nonatomic, weak)   UIImageView * sourceImageView;
@property (nonatomic, assign) CGRect soucreRect;
@property (nonatomic, assign) NSInteger tag;

- (id)getThumbnail;
- (id)getPhoto;

@end
