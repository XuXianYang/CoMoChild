#import "XXYMeController.h"

#import "XXYSettingController.h"
#import <AFNetworking.h>
#import "CropImageViewController.h"
#import "BSHttpRequest.h"
#import "UIImageView+WebCache.h"
#import "XXYSettingDetailController.h"
#import"XXYJoinSchoolController.h"
@interface XXYMeController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIAlertController *_alertCon;
}
@property(nonatomic,strong)UIImage*selImage;

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@property(nonatomic,strong)UIImageView*iconImageView;

@property(nonatomic,strong)UIView*bgIconImageView;

@property(nonatomic,strong)UIView*bgTableView;

@property(nonatomic,strong)UIButton*settingBtn;

@property(nonatomic,strong)UILabel*nameLabel;

@end

@implementation XXYMeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    
   // [self.navigationController setNavigationBarHidden:YES animated:YES];
    //设置导航栏为透明色
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
    
    [self setUpSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name: @"CropOK" object: nil];
    
    [self getUpNewData];
}

-(void)getUpNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];

    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        [self.dataList removeAllObjects];
        
        NSString*schoolName;
        NSString*userName;
        if(objString[@"data"][@"studentInfo"][@"schoolName"])
        {
            schoolName=[NSString stringWithFormat:@"%@%@",@"学校:",objString[@"data"][@"studentInfo"][@"schoolName"]];
        }
        else
        {
            schoolName=@"学校:请加入班级";
        }
        if(objString[@"data"][@"realName"])
        {
            _nameLabel.text=objString[@"data"][@"realName"];
            userName=[NSString stringWithFormat:@"%@%@",@"姓名:",objString[@"data"][@"realName"]];
        }
        else
        {
            _nameLabel.text=@"请填写真实姓名";
            userName=@"姓名:请填写真实姓名";
        }
                self.dataList=[NSMutableArray arrayWithArray:@[schoolName,[NSString stringWithFormat:@"%@%@",@"手机:",objString[@"data"][@"mobileNo"]],userName,[NSString stringWithFormat:@"%@%@",@"昵称:",objString[@"data"][@"username"]],[NSString stringWithFormat:@"%@%@",@"学生码:",objString[@"data"][@"studentInfo"][@"code"]]]];
        
        [BSHttpRequest archiverObject:self.dataList ByKey:@"myInfoCache" WithPath:@"myInfo.plist"];
        
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:objString[@"data"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        
        [self.tableView reloadData];
           } failure:^(NSError *error) {
           self.dataList =[BSHttpRequest unarchiverObjectByKey:@"myInfoCache" WithPath:@"myInfo.plist"];
           [self.tableView reloadData];
           }];
}
-(void)setUpSubViews
{
    
    UIScrollView*scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,-64, MainScreenW, MainScreenH)];
    scrollView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.contentSize=CGSizeMake(0, MainScreenH-64);
    [self.view addSubview:scrollView];

    
    _bgIconImageView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH*1/3+20)];
    _bgIconImageView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [scrollView addSubview:_bgIconImageView];
    
    _bgTableView=[[UIView alloc]initWithFrame:CGRectMake(12, MainScreenH*1/3-25+20, MainScreenW-24, 225)];
    _bgTableView.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:_bgTableView];
    
    [_bgTableView addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.bounces=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    _settingBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _settingBtn.frame=CGRectMake(12, MainScreenH*1/3+245, MainScreenW-24, 50);
    [_settingBtn setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:_settingBtn];
    
    
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageView.image=[UIImage imageNamed:@"settingiocn"];;
    [_settingBtn addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 50)];
    label.text=@"设置";
    label.font=[UIFont systemFontOfSize:18];
    [_settingBtn addSubview:label];
    
    UIImageView*indicatorImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_settingBtn.frame.size.width-40, 10, 30, 30)];
    indicatorImageView.image=[UIImage imageNamed:@"Indicator"];;
    [_settingBtn addSubview:indicatorImageView];
    
    
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2,50, 100, 100)];
    _iconImageView.backgroundColor=[UIColor lightGrayColor];
    [_bgIconImageView addSubview:_iconImageView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary*userInfoDict=[defaults objectForKey:@"userInfo"];

    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:userInfoDict[@"user"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    
     //_iconImageView.image=[UIImage imageNamed:@"iconOfUserHead.jpg"];
    _iconImageView.layer.cornerRadius=50;
    _iconImageView.layer.masksToBounds=YES;
    _iconImageView.userInteractionEnabled=YES;
    _iconImageView.contentMode=UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer * pictureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    [_iconImageView addGestureRecognizer:pictureTap];
    
    _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,50+_iconImageView.frame.size.width+5, MainScreenW, 30)];
    
    _nameLabel.font=[UIFont systemFontOfSize:18];
    _nameLabel.text=@"";
    _nameLabel.textAlignment=NSTextAlignmentCenter;
    _nameLabel.textColor=[UIColor whiteColor];
    _nameLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNameClieked:)];
    [_nameLabel addGestureRecognizer:tap];

    [_bgIconImageView addSubview:_nameLabel];
}
-(void)tapNameClieked:(UITapGestureRecognizer*)tap
{
    XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
    detailCon.titleName=@"修改姓名";
    detailCon.index=3;
    detailCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}

-(void)tapAvatarView:(UITapGestureRecognizer*)tap
{
    UIAlertController*al=[UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIPopoverPresentationController *popover = al.popoverPresentationController;
    
    if (popover) {
        popover.sourceView = _iconImageView;
        popover.sourceRect = _iconImageView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  
                                  [self pickPicture:UIImagePickerControllerSourceTypeCamera];
                                                                }];
    [al addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [self pickPicture:UIImagePickerControllerSourceTypePhotoLibrary];
                              }];
    [al addAction:action2];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消 " style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                              {
                              }];
    [al addAction:action4];
    
    [self presentViewController:al animated:YES completion:nil];
}
-(void)pickPicture:(UIImagePickerControllerSourceType)sourceType
{
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    if(![XXYMyTools isCameraValid]&&sourceType==1)
    {
        [SVProgressHUD showErrorWithStatus:@"如果不能访问相机,请在iPhone的“设置-隐私-相机”选项中，允许程序访问你的相机"];
    }
        if(sourceType==0)
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }
    
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    _selImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    CropImageViewController*cropCon=[[CropImageViewController alloc]init];
    _selImage=[XXYMyTools fixOrientation:_selImage];
    cropCon.image=_selImage;
    cropCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cropCon animated:NO];
}
- (void)notificationHandler: (NSNotification *)notification {
    UIImage*image = notification.object;

    [self uploadPicture:image];
}

//保存图片
//- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
//{
//    NSData* imageData = UIImagePNGRepresentation(tempImage);
//    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* totalPath = [documentPath stringByAppendingPathComponent:imageName];
//    
//    //保存到 document
//    [imageData writeToFile:totalPath atomically:NO];
//}
//从document取得图片
//- (UIImage *)getImage:(NSString *)urlStr
//{
//    return [UIImage imageWithContentsOfFile:urlStr];
//}
-(void)uploadPicture:(UIImage*)image
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获取图片数据
    NSData *fileData = UIImageJPEGRepresentation(image, 0.2);
    // 设置上传图片的名字
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    NSString*urlString=[NSString stringWithFormat:@"%@/user/avatar/upload?sid=%@",BaseUrl,userSidString];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSNumber*imageWidth=[NSNumber numberWithFloat:image.size.width-1];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"topX"] = @0;
    parameter[@"topY"] = @0;
    parameter[@"width"] = imageWidth;
    [manager POST:urlString parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (fileData != nil)
        {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"image/jpg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            _iconImageView.image=image;
            [self setUpAlertController:@"更换头像成功"];
        }
        else
        {
            [self setUpAlertController:objString[@"message"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // NSLog(@"error=%@",error.localizedDescription);
        [self setUpAlertController:@"更换头像失败"];
    }];
}
-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:_alertCon animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

-(void)settingBtnClicked:(UIButton*)btn
{
    XXYSettingController*settingCon=[[XXYSettingController alloc]init];
    settingCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:settingCon];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.textLabel.text=self.dataList[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:16];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==2)
    {
        [self tapNameClieked:nil];
    }
    if(indexPath.row==3)
    {
        XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
        detailCon.titleName=@"修改昵称";
        detailCon.index=4;
        detailCon.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewControllerWithAnimation:detailCon];
    }
    if(indexPath.row==0)
    {
        [self getUpNewUserInfoData];
    }
}
-(void)getUpNewUserInfoData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSDictionary*userInfoDict=[defaults objectForKey:@"joinClass"];
    
    if(userInfoDict[@"classId"]&&userInfoDict[@"schoolId"])
    {
    }
    else
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            //        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary*dict=objString[@"data"][@"studentInfo"];
            NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
            [defaultss setObject:dict forKey:@"joinClass"];
            
            if(dict[@"classId"]&&dict[@"schoolId"])
            {
            }
            else
            {
                XXYJoinSchoolController*messCon=[[XXYJoinSchoolController alloc]init];
                [self presentViewController:messCon animated:YES completion:nil];
            }
        } failure:^(NSError *error) {}];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageView.image=[UIImage imageNamed:@"infoicon"];;
    [view addSubview:imageView];
    
    UILabel*lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,49,_bgTableView.frame.size.width, 1)];
    lineLabel.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [view addSubview:lineLabel];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 50)];
    label.text=@"个人信息";
    label.font=[UIFont systemFontOfSize:18];
    [view addSubview:label];
    
    
    return view;
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,_bgTableView.frame.size.width, 225) style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor whiteColor];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray arrayWithArray:@[@"学校:",@"手机:",@"姓名:",@"昵称:",@"学生码"]];
        
    }
    return _dataList;
}
-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title=@"";
    //状态栏颜色为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getUpNewData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
