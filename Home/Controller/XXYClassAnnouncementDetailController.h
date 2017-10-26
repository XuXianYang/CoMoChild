//
//  XXYClassAnnouncementDetailController.h
//  点线
//
//  Created by 徐显洋 on 16/12/7.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXYClassAnnouncementModel.h"
@interface XXYClassAnnouncementDetailController : UIViewController
@property(nonatomic,strong)XXYClassAnnouncementModel*announcementModel;
@property(nonatomic,copy)NSString*timeString;
@end
