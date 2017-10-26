//
//  YXScrollMenu.h
//  YXScrollMenuDemo
//
//  Created by Yangxin on 16/3/29.
//  Copyright © 2016年 51Baishi.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXScrollMenu;

@protocol YXScrollMenuDelegate <NSObject>

- (void)scrollMenu:(YXScrollMenu *)scrollMenu selectedIndex:(NSInteger)selectedIndex;

@end

@interface YXScrollMenu : UIView

@property (nonatomic, weak) id<YXScrollMenuDelegate> delegate;

/** 标题数组 */
@property (nonatomic, copy) NSArray *titleArray;

/** 当前选中下标 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 菜单每个单元格的宽度, 默认为80. */
@property (nonatomic, assign) CGFloat cellWidth;

/** 被选中单元格背景颜色, 默认为紫色 */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

/** 普通单元格的背景颜色, 默认为浅灰色 */
@property (nonatomic, strong) UIColor *normalBackgroundColor;

/** 被选中单元格的文字颜色, 默认为橙黄色 */
@property (nonatomic, strong) UIColor *selectedTextColor;

/** 被选中单元格的背景图片, 默认为nil, 如果设置会覆盖背景颜色 */
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

/** 是否隐藏分割线, 默认为YES */
@property (nonatomic, assign) BOOL isHiddenSeparator;



@end
