//
//  XXYTimeTableViewCell.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXYTimeTableModel;

@interface XXYTimeTableViewCell : UITableViewCell

@property(nonatomic,strong)XXYTimeTableModel*dataModel;
@property(nonatomic,assign)NSInteger index;

@end
