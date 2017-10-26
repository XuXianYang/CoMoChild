//
//  BSBadgeView.m
//  51微博分享
//
//  Created by zhangxueming on 16/4/12.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "BSBadgeView.h"

#define BSBadgeFontSize  10

@interface BSBadgeView ()

@property (nonatomic,strong)UIImageView *moreImageView;
@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation BSBadgeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage imageNamed:@"main_badge"];
        _moreImageView.userInteractionEnabled  = YES;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:BSBadgeFontSize];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.userInteractionEnabled = YES;
        [self addSubview:_moreImageView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = badgeValue;
    if (_badgeValue.length==0 || [_badgeValue isEqualToString:@" "]) {
        _moreImageView.image = nil;
        return;
    }
    NSInteger value = badgeValue.integerValue;
    if (value>99) {
        _moreImageView.image = [UIImage imageNamed:@"text_new_badge"];
        _titleLabel.text = nil;
        _moreImageView.frame = CGRectMake(0, 0, 10, 10);
    }
    else
    {
        _moreImageView.image = [UIImage imageNamed:@"main_badge"];
        _titleLabel.text = _badgeValue;
        [_moreImageView sizeToFit];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.bounds;
    _moreImageView.center =CGPointMake(rect.size.width*0.5,rect.size.height*0.5);
    _titleLabel.frame = CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4);
}



@end
