//
//  BSTabBarButton.m
//  51微博分享
//
//  Created by zhangxueming on 16/4/12.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "BSTabBarButton.h"
#import "BSBadgeView.h"
#import "UIView+BSFrame.h"

//11
@interface BSTabBarButton()

@property (nonatomic,strong)BSBadgeView *badgeView;

@end


@implementation BSTabBarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置字体颜色
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        // 图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置文字字体
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.badgeView];
    }
    return self;
}

- (BSBadgeView *)badgeView
{
    if (_badgeView==nil) {
        _badgeView = [[BSBadgeView alloc] init];
    }
    return _badgeView;
}

- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    //KVO
    [_item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
   // [_item addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:nil];
}

//一但模型数据的值发生改变,该方法就被调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self setImage:_item.image forState:UIControlStateNormal];
    [self setImage:_item.selectedImage forState:UIControlStateSelected];
    [self setTitle:_item.title forState:UIControlStateNormal];
    //self.badgeView.badgeValue = _item.badgeValue;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.imageView
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = self.bounds.size.width;
    CGFloat imageH = self.bounds.size.height * 0.7;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    
    // 2.title
    CGFloat titleX = 0;
    CGFloat titleY = imageH - 3;
    CGFloat titleW = self.bounds.size.width;
    CGFloat titleH = self.bounds.size.height - titleY;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    // 3.badgeView
    CGFloat badgeW = 19;
    CGFloat badgeH = 19;
    CGFloat badgeX = self.W/2+5;
    CGFloat badgeY = 0;
    self.badgeView.frame = CGRectMake(badgeX, badgeY, badgeW, badgeH);
}


@end
