#import "XXYCampusDynamicFrame.h"
#import "XXYCampusDynamicModel.h"
#define GFMargin 10.0f
#define GFDcrcH  35.0f
@implementation XXYCampusDynamicFrame

-(void)setDataModel:(XXYCampusDynamicModel *)dataModel
{
    _dataModel=dataModel;
    
    _cellHeight=55;
    _originalIconFrame=CGRectMake(10, 10, 35, 35) ;
    _originalNickFrame=CGRectMake(55, 10, MainScreenW- 135, 20);
    _originalTimeFrame=CGRectMake(55, 30, MainScreenW- 135, 15);
    _originalMoreBtnFrame=CGRectMake(MainScreenW-40, 10, 30, 30);
    
    _horizontalLineViewFrame=CGRectMake(0, 0, MainScreenW, 1) ;
    _verticalLineViewFrame=CGRectMake(MainScreenW/2-0.5, 1, 1, 34);
    _praiseButtonFrame=CGRectMake(0, 0, MainScreenW/2, 35);
    _commentButtonFrame=CGRectMake(MainScreenW/2, 0, MainScreenW/2, 35);
    
    //文字
    CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 2 * GFMargin;
    CGSize textMaxSize = CGSizeMake(textMaxW, MAXFLOAT);
    CGSize textSize = [self.dataModel.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    _cellHeight += textSize.height + GFMargin;
    
    _originalTextFrame=CGRectMake(10, 55, MainScreenW-20, textSize.height);
    
    if(self.dataModel.vedioUrl)
    {
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
        CGSize size=[self.dataModel.text sizeWithAttributes:attrs];
        
        int btnWidth=size.width/(MainScreenW-20);
        
        CGFloat bwidth=MainScreenW-20-(size.width-btnWidth/(MainScreenW-20));
        
        if(bwidth<125)
        {
            //中间内容的Frame
            CGRect middleFrame = CGRectMake(10, _cellHeight, 80, 15);
            _videoButtonFrame = middleFrame;
            _cellHeight += 15+ GFMargin;
        }
        else
        {
            if(self.dataModel.text.length<1)
            {
                //中间内容的Frame
                CGRect middleFr = CGRectMake(MainScreenW-bwidth-10, _cellHeight-10, 80, 15);
                _videoButtonFrame = middleFr;
                _cellHeight += 15;
            }
            else
            {
                CGRect middleFr = CGRectMake(MainScreenW-bwidth-10, _cellHeight-26, 80, 15);
                _videoButtonFrame = middleFr;
                //_cellHeight +=GFMargin;
            }
        }
    }
    else
    {
        _videoButtonFrame = CGRectZero;
    }
    
    _originalViewFrame=CGRectMake(0, 0, MainScreenW, _cellHeight) ;
    
    if(self.dataModel.picCount>0)
    {
        NSInteger count=(self.dataModel.picCount-1)/3+1;
        CGFloat picWidth=(MainScreenW-30)/3;
        CGFloat contentH = picWidth*count +(count-1)*5;
        //中间内容的Frame
        CGRect middleF = CGRectMake(0, _cellHeight, MainScreenW, contentH);
        
        _pictureViewFrame = middleF;
        _cellHeight += contentH+ GFMargin;
    }
    
    if(self.dataModel.vedioUrl&&self.dataModel.picCount==0)
    {
        CGFloat videoHeight=(MainScreenW-20)*0.56;
        
        //中间内容的Frame
        CGRect middleF = CGRectMake(0, _cellHeight, MainScreenW, videoHeight);
        _pictureViewFrame = middleF;
        _cellHeight += videoHeight+ GFMargin;
    }
    if(!self.dataModel.vedioUrl&&self.dataModel.picCount==0)
    {
        _pictureViewFrame=CGRectZero;
    }
    _toolsViewFrame=CGRectMake(0, _cellHeight, MainScreenW, 35);
        //底部工具条
    _cellHeight += GFDcrcH + GFMargin;
    
    _cellHeight =CGRectGetMaxY(_toolsViewFrame);
}

@end
