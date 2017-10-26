//
//  XXYMyPraiseModel.m
//  点线
//
//  Created by 徐显洋 on 17/2/21.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import "XXYMyPraiseModel.h"
/*全局变量 */
static NSDateFormatter *fmt_;
static NSCalendar *calendar_;

@implementation XXYMyPraiseModel
-(CGFloat)cellHeight
{
    //如果cell高度已经计算处理 就直接返回
    if (_cellHeight) return _cellHeight;
    //头像
    _cellHeight = 55;
    
    //文字
    CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 20;
    CGSize textMaxSize = CGSizeMake(textMaxW, MAXFLOAT);
    CGSize textSize = [self.uContent boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    _cellHeight += textSize.height + 10+75;
    return _cellHeight;
}
/**
 只调用一次
 */
+(void)initialize
{
    fmt_ = [[NSDateFormatter alloc] init];
    calendar_ = [NSCalendar gf_calendar];
}

/**
 日期处理get方法
 */
-(NSString *)uTime
{
    //将服务器返回的数据进行处理
    fmt_.dateFormat = @"yyyy-MM-dd HH-mm-ss";
    NSDate *creatAtDate = [fmt_ dateFromString:_uTime];
    
    //判断
    if (creatAtDate.isThisYear) {//今年
        if ([calendar_ isDateInToday:creatAtDate]) {//今天
            //当前时间
            NSDate *nowDate = [NSDate date];
            
            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [calendar_ components:unit fromDate:creatAtDate toDate:nowDate options:0];
            
            if (comps.hour >= 1) {
                return [NSString stringWithFormat:@"%zd小时前",comps.hour];
            }else if (comps.minute >= 1){
                return [NSString stringWithFormat:@"%zd分钟前",comps.minute];
            }else
            {
                return @"刚刚";
            }
            
        }else if ([calendar_ isDateInYesterday:creatAtDate]){//昨天
            fmt_.dateFormat = @"昨天 HH:mm:ss";
            return [fmt_ stringFromDate:creatAtDate];
            
        }else{//其他
            fmt_.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt_ stringFromDate:creatAtDate];
            
        }
        
    }else{//非今年
        return _uTime;
    }
    
    return _uTime;
}

@end
