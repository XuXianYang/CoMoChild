//
//  XXYPublishDynamicController.h
//  点线
//
//  Created by 徐显洋 on 17/1/18.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXYReloadNewDataDelegate <NSObject>


-(void)reloadNewDataOfPublished;


@end


@interface XXYPublishDynamicController : UIViewController

@property(nonatomic,weak)id<XXYReloadNewDataDelegate>reloadDelegate;


@property(nonatomic,assign)NSInteger index;

//判断是否是分享
@property(nonatomic,assign)NSInteger shareIndex;
//分享的内容
@property(nonatomic,copy)NSString* shareString;


@property(nonatomic,copy)NSString*actId;

@end
