//
//  YXScrollMenuCell.h
//  YXScrollMenuDemo
//
//  Created by Yangxin on 16/3/29.
//  Copyright © 2016年 51Baishi.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXMenuModel, YXScrollMenu;

@interface YXScrollMenuCell : UITableViewCell

@property (nonatomic, strong) YXMenuModel *menuModel;

@property (nonatomic, strong) YXScrollMenu *scrollMenu;

+ (instancetype)cellWithTableView:(UITableView *)tableView index:(NSInteger)index count:(NSInteger)count;

@end
