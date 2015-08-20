//
//  THCPhoto.m
//  THCPhotoBrowser
//
//  Created by hejianyuan on 15/7/28.
//  Copyright (c) 2015年 Thinkcode. All rights reserved.
//

#import "THCPhotoModel.h"

@implementation THCPhotoModel

- (id)getThumbnail
{
    if (self.sourceImageView.image) {
        return self.sourceImageView.image;
    }
    
    if (self.thumbnailPhoto) {
        return self.thumbnailPhoto;
    }
    
    if (self.thumbnailPhotoURL) {
        return self.thumbnailPhotoURL;
    }
    
    if (self.originalPhoto) {
        return self.originalPhoto;
    }
    
    if (self.originalphotoURL) {
        return self.originalphotoURL;
    }
    
    return nil;
}

- (id)getPhoto
{
    
    if (self.originalPhoto) {
        return self.originalPhoto;
    }
    
    if (self.originalphotoURL) {
        return self.originalphotoURL;
    }
    
    if (self.sourceImageView.image) {
        return self.sourceImageView.image;
    }
    
    if (self.thumbnailPhoto) {
        return self.thumbnailPhoto;
    }
    
    if (self.thumbnailPhotoURL) {
        return self.thumbnailPhotoURL;
    }
    
    return nil;
}


@end
