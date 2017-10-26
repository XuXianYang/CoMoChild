//
//  XXYTimeTableViewCell.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYTimeTableViewCell.h"
#import "XXYTimeTableModel.h"
@interface XXYTimeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *weekDayName;
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;

@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UIImageView *teacherImage;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UIView *courseContent;

@end

@implementation XXYTimeTableViewCell


-(void)setDataModel:(XXYTimeTableModel *)dataModel
{
    _dataModel=dataModel;
    _weekDayName.text=dataModel.courseNum;
    _courseName.text=dataModel.courseName;
    _teacherName.text=dataModel.teacherName;
    
    if(self.index<4)
    {
        _courseImage.image=[UIImage imageNamed:@"timeTable0@2x 4"];
        _teacherImage.image=[UIImage imageNamed:@"timeTable1@2x 4"];
        
        _weekDayName.backgroundColor=[UIColor colorWithRed:76.0/255 green:223.0/255 blue:215.0/255 alpha:1.0];//4cdfd7
        
        _courseContent.backgroundColor=[UIColor colorWithRed:227.0/255 green:255.0/255 blue:254.0/255 alpha:1.0];//e3fffe
    }
    else
    {
        _courseImage.image=[UIImage imageNamed:@"timeTable3@2x 4"];
        _teacherImage.image=[UIImage imageNamed:@"timeTable2@2x 4"];
        
        _weekDayName.backgroundColor=[UIColor colorWithRed:253.0/255 green:194.0/255 blue:102.0/255 alpha:1.0];//fdc068
        
        _courseContent.backgroundColor=[UIColor colorWithRed:253.0/255 green:241.0/255 blue:227.0/255 alpha:1.0];//fdf1e3
    }
}
-(void)layoutSubviews
{
    _weekDayName.textColor=[UIColor whiteColor];
    _weekDayName.textAlignment=NSTextAlignmentCenter;
    _courseName.font=[UIFont systemFontOfSize:14];
    _teacherName.font=[UIFont systemFontOfSize:14];
    _weekDayName.font=[UIFont systemFontOfSize:15];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
