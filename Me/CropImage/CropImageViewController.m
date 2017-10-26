#import "CropImageViewController.h"
#import "TKImageView.h"

#import "XXYBackButton.h"
@interface CropImageViewController ()
@property (strong, nonatomic)  TKImageView *tkImageView;
@property (strong, nonatomic)  UIButton *confirmBtn;

@end

@implementation CropImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"裁剪照片";
    
    [self setUpTKImageView];
    
    _tkImageView.scaleFactor = 0.6;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickOkBtn:)];
  
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_confirmBtn];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}
- (void)setUpTKImageView {
    
    _tkImageView=[[TKImageView alloc ]initWithFrame:CGRectMake(2, 10, MainScreenW-4, MainScreenH-100)];
    _tkImageView.toCropImage = self.image;
    _tkImageView.showMidLines = NO;
    _tkImageView.needScaleCrop = YES;
    _tkImageView.showCrossLines = NO;
    _tkImageView.cornerBorderInImage = NO;
    _tkImageView.cropAreaCornerWidth = 44;
    _tkImageView.cropAreaCornerHeight = 44;
    _tkImageView.minSpace = 30;
    _tkImageView.cropAreaCornerLineColor = [UIColor lightGrayColor];
    _tkImageView.cropAreaBorderLineColor = [UIColor grayColor];
    _tkImageView.cropAreaCornerLineWidth = 8;
    _tkImageView.cropAreaBorderLineWidth = 6;
    _tkImageView.cropAreaMidLineWidth = 30;
    _tkImageView.cropAreaMidLineHeight = 8;
    _tkImageView.cropAreaMidLineColor = [UIColor grayColor];
    _tkImageView.cropAreaCrossLineColor = [UIColor lightGrayColor];
    _tkImageView.cropAreaCrossLineWidth = 6;
    _tkImageView.cropAspectRatio = 1;
    [self.view addSubview:_tkImageView];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchClicked:)];
    [_tkImageView addGestureRecognizer:pinch];
    
    _confirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame=CGRectMake(0,0,40,40);
    [_confirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(clickOkBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)pinchClicked:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.state==UIGestureRecognizerStateChanged || pinch.state == UIGestureRecognizerStateEnded) {
        pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    }
    pinch.scale = 1.0;
}


#pragma mark - IBActions
- (void)clickOkBtn:(UIButton*)btn
{
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CropOK" object: [_tkImageView currentCroppedImage]];
}
@end
