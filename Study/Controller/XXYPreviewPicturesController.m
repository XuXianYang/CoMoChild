#import "XXYPreviewPicturesController.h"
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface XXYPreviewPicturesController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UILabel*titleLabel;
@property(nonatomic,assign)NSInteger picCount;

@end

@implementation XXYPreviewPicturesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
    [self.view addGestureRecognizer:tapGes];
    [self setUpTitleView];
}
-(void)viewDidAppear:(BOOL)animated
{
    for(int i=0;i<=9;i++)
    {
        //UIView *singleMapView = [[UIView alloc]
                                // initWithFrame:CGRectMake(10, 150, 300, 250)];
        UIImageView*singleMapView=[self.view viewWithTag:500+i];
        singleMapView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             singleMapView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }completion:^(BOOL finish){
                                                      }];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
   }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)setUpTitleView
{
    UIScrollView*scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH)];
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView];
    
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 20, MainScreenW-200, 44)];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor whiteColor];
    _titleLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_titleLabel];
    
    NSInteger imgType=0;
    if(self.dataArray)
    {
        _picCount=self.dataArray.count;
        imgType=0;
        scrollView.contentOffset=CGPointMake(MainScreenW*(self.picIndex-500), 0);
        scrollView.contentSize=CGSizeMake(MainScreenW*self.dataArray.count, 0);
        _titleLabel.text=[NSString stringWithFormat:@"%i / %i",self.picIndex-500+1,self.dataArray.count];
    }
    else if (self.campusImgArray)
    {
        _picCount=self.campusImgArray.count;
        imgType=1;
        scrollView.contentOffset=CGPointMake(MainScreenW*(self.picIndex-500), 0);
        scrollView.contentSize=CGSizeMake(MainScreenW*self.campusImgArray.count, 0);
        _titleLabel.text=[NSString stringWithFormat:@"%i / %i",self.picIndex-500+1,self.campusImgArray.count];
    }
    
    for(int i=0;i<_picCount;i++)
    {
        UIImageView*imageView=[[UIImageView alloc]init];
        if(!imgType)
        {
            UIImage*image=self.dataArray[i];
            imageView.frame=CGRectMake(MainScreenW*i, 0, MainScreenW, image.size.height/image.size.width*MainScreenW);
            imageView.center=CGPointMake(MainScreenW/2+MainScreenW*i, MainScreenH/2);
            imageView.image=image;
        
        }
        else
        {
            NSString*imageUrl=self.campusImgArray[i];
            
            imageView.frame=CGRectZero;
            imageView.center=CGPointMake(MainScreenW/2+MainScreenW*i, MainScreenH/2);
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:[UIImage imageNamed:@"school_bg_pic"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
                [SVProgressHUD showWithStatus:@"正在加载..."];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [SVProgressHUD dismiss];
                if(!error&&image)
                {
                    imageView.frame=CGRectMake(MainScreenW*i, 0, MainScreenW, image.size.height/image.size.width*MainScreenW);
                }
                else
                {
                    imageView.frame=CGRectMake(MainScreenW*i, 0, MainScreenW, MainScreenW);
                }
                imageView.center=CGPointMake(MainScreenW/2+MainScreenW*i, MainScreenH/2);
            }];
            UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClicked:)];
            [imageView addGestureRecognizer:longGes];
        }
        imageView.userInteractionEnabled=YES;
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag=500+i;
        [scrollView addSubview:imageView];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchClicked:)];
        [imageView addGestureRecognizer:pinch];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
        [imageView addGestureRecognizer:tapGes];
    }
}

-(void)tapGesClicked:(UITapGestureRecognizer*)tap
{
    for(int i=0;i<9;i++)
    {
        UIImageView*singleMapView=[self.view viewWithTag:500+i];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             singleMapView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         }completion:^(BOOL finish){
                             
                             
                             if(i==8)

                             {
                                 [self dismissViewControllerAnimated:NO completion:nil];

                             }
                         }];
    }
   }
-(void)longClicked:(UILongPressGestureRecognizer*)longTap
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImageView*imageView=[self.view viewWithTag:self.picIndex];
        //保存图片
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
    }
}

- (void)pinchClicked:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.state==UIGestureRecognizerStateChanged || pinch.state == UIGestureRecognizerStateEnded) {
        pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    }
    pinch.scale = 1.0;
}

#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / MainScreenW;
    self.picIndex=500+index;
    _titleLabel.text=[NSString stringWithFormat:@"%i / %i",index+1,_picCount];
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        NSInteger index = scrollView.contentOffset.x / MainScreenW;
        self.picIndex=500+index;
        _titleLabel.text=[NSString stringWithFormat:@"%i / %i",index+1,_picCount];
    }
}


@end
