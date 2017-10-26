//
//  YXScrollMenuCell.m
//  YXScrollMenuDemo
//
//  Created by Yangxin on 16/3/29.
//  Copyright © 2016年 51Baishi.net. All rights reserved.
//

#import "YXScrollMenuCell.h"
#import "YXScrollMenu.h"
#import "UIView+Extension.h"
#import "YXMenuModel.h"


@interface YXScrollMenuCell ()
@property (nonatomic, weak) UILabel *showLabel;
@property (nonatomic, weak) UILabel *separatorLabel;
@end

@implementation YXScrollMenuCell

+ (instancetype)cellWithTableView:(UITableView *)tableView index:(NSInteger)index count:(NSInteger)count{
    static NSString *ID = @"YXScrollMenuCell";
    
    YXScrollMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setUpSubviews:index count:count];
    }
    
    return cell;
}

- (void)setUpSubviews:(NSInteger)index count:(NSInteger)count{
    
    UILabel *showLabel = [[UILabel alloc] init];
    showLabel.textAlignment = NSTextAlignmentCenter;
    showLabel.center = CGPointMake(self.width / 2, self.height / 2);
    showLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:showLabel];
    
    _showLabel = showLabel;
    
    
    UILabel *separatorLabel = [[UILabel alloc] init];
    separatorLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separatorLabel];
   
    if (count - 1 ==  index) {
        separatorLabel.hidden = YES;
    }
    
    _separatorLabel = separatorLabel;
}



- (void)setMenuModel:(YXMenuModel *)menuModel {
    _menuModel = menuModel;
    
    _showLabel.text = menuModel.text;
    
    if (menuModel.isSelected) {
        _showLabel.font = [UIFont systemFontOfSize:18.0f];
        _showLabel.textColor = _scrollMenu.selectedTextColor;
        
        if (_scrollMenu.selectedBackgroundImage) {
            _showLabel.backgroundColor = [UIColor clearColor];
            self.backgroundView = [[UIImageView alloc] initWithImage:_scrollMenu.selectedBackgroundImage];
        } else {
            _showLabel.backgroundColor = _scrollMenu.selectedBackgroundColor;
            self.backgroundView = nil;
        }
    } else {
        _showLabel.font = [UIFont systemFontOfSize:15.0f];
        _showLabel.textColor = [UIColor blackColor];
        _showLabel.backgroundColor = _scrollMenu.normalBackgroundColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _showLabel.frame = self.bounds;
    
    if (_scrollMenu.isHiddenSeparator) {
        _separatorLabel.hidden = YES;
    } else {
        _separatorLabel.frame = CGRectMake(0, _showLabel.height - 1, self.width, 1);
        _separatorLabel.hidden = NO;
    }
    
}

@end
