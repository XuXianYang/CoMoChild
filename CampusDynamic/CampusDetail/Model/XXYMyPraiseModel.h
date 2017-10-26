//
//  XXYMyPraiseModel.h
//  点线
//
//  Created by 徐显洋 on 17/2/21.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXYMyPraiseModel : NSObject

@property(nonatomic,copy)NSString*dynamicId;

@property(nonatomic,copy)NSString*uName;
@property(nonatomic,copy)NSString*uTime;
@property(nonatomic,copy)NSString*uIcon;

@property(nonatomic,copy)NSString*uContent;
@property(nonatomic,copy)NSString*uImage;
@property(nonatomic,copy)NSString*uMyName;
@property(nonatomic,copy)NSString*uMyontent;
@property(nonatomic,copy)NSString*uVideoUrl;
@property(nonatomic,assign)NSInteger hasImg;


@property (nonatomic, assign) CGFloat cellHeight;


@end
