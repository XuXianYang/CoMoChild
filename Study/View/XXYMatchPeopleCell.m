#import "XXYMatchPeopleCell.h"
#import "UIImageView+WebCache.h"
#import "XXYMatchListModel.h"
@interface XXYMatchPeopleCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *telBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;


@end
@implementation XXYMatchPeopleCell
-(void)setDataModel:(XXYMatchListModel *)dataModel
{
    _dataModel=dataModel;
    
    [_telBtn setTitle:dataModel.userName forState:UIControlStateNormal];
    _timeLabel.text=dataModel.strCreateAt;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.imageUrl] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    _noteLabel.text=dataModel.userNote;
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    _iconImageView.layer.cornerRadius = 20;
    _iconImageView.clipsToBounds = YES;

}
-(void)telBtnClicked
{
//    if(_dataModel.userName)
//    {
//        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",_telBtn.currentTitle];
//        UIWebView * callWebview = [[UIWebView alloc] init];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//        [self addSubview:callWebview];    }
}
-(void)layoutSubviews
{
    [_telBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    _telBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    _telBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _telBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    [_telBtn addTarget:self action:@selector(telBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _noteLabel.font=[UIFont systemFontOfSize:14];
    _noteLabel.textColor=[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0];

    _timeLabel.font=[UIFont systemFontOfSize:13];
    _timeLabel.textAlignment=NSTextAlignmentRight;
    _timeLabel.textColor=[UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0];
    
    _lineView.backgroundColor=[UIColor colorWithRed:201.0/255 green:201.0/255 blue:201.0/255 alpha:1.0];
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
