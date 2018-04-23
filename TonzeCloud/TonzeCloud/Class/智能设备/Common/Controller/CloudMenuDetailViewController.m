//
//  CloudMenuDetailViewController.m
//  Product
//
//  Created by 肖栋 on 17/5/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CloudMenuDetailViewController.h"
#import "TCLowerSugarDeviceViewController.h"
#import "TCLowerSuagrDetailViewController.h"
#import "TJYApplicableEquipmentCell.h"
#import "TJYCookIngredientModel.h"
#import "TJYIngredientCell.h"
#import "TJYCookSetpModel.h"
#import "TJYCookStepCell.h"
#import "TJYMenuDetailsRemarksCell.h"
#import "TimePickerView.h"
#import "StartDeviceButton.h"
#import "TCMainDeviceHelper.h"
#import "TCCookListModel.h"
#import "TCEquipmentModel.h"
#import "NSData+Extension.h"

@interface CloudMenuDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat               beginContentY;          //开始滑动的位置
    CGFloat               endContentY;            //结束滑动的位置
    CGFloat               sectionHeaderHeight;    //section的header高度
    TimePickerView        *timePicker;
    
    TCCookListModel       *cookListModel;         //菜谱基本信息
    TCEquipmentModel      *equipmentModel;        //设备
    NSMutableArray        *ingredientArray;       //食材数组
    NSMutableArray        *stepListArr;           //烹饪步骤
    
    NSInteger             orderSelectMinute;
    
    UILabel               *menuNameLabel;      /// 菜谱名称
    UILabel               *energyLabel;        /// 食物热量
    
    UIPageControl         *pageControl;
    
    BOOL                  isOrderStart;
}

@property (nonatomic, strong) UITableView  *tableView;
/// 导航栏
@property (nonatomic ,strong) UIView       *navigationView;
/// 导航栏菜谱名称
@property (nonatomic ,strong) UILabel      *menuNavLabel;
/// banner 视图
@property (nonatomic ,strong) UIScrollView *cycleScrollView;
/// 食材卡路里
@property (nonatomic, assign) NSInteger    caloriesSum;
/// 食材总卡路里
@property (nonatomic, assign) NSInteger    calories_pre100 ;



@end

@implementation CloudMenuDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = @"菜谱详情";
    self.isHiddenNavBar = YES;
    
    cookListModel   = [[TCCookListModel alloc] init];
    equipmentModel  = [[TCEquipmentModel alloc] init];
    ingredientArray = [[NSMutableArray alloc] init];
    stepListArr     = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.tableView];
    [self setNavigation];
    
    [self loadCloudMenuDetailData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDetailOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDetailOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDetailOnPipeData:) name:kOnRecvPipeSyncData object:nil];

}


#pragma mark  改变状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


#pragma  mark --  UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return kIsEmptyString(cookListModel.abstract)? 0: 1 ;
        }
            break;
        case 1:
        {
            return ingredientArray.count;
        }
            break;
        case 2:
        {
            return stepListArr.count;
        }
            break;
        case 3:
        {
            return kIsEmptyString(cookListModel.remarks) ? 0: 1;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ingredientCellIdentifier = @"ingredientCell";
    static NSString *StepCellIdentifier = @"CookStepCell";
    static NSString *remarksCellIdentifier = @"remarksCell";
    switch (indexPath.section) {
        case 0:
        {
            TJYMenuDetailsRemarksCell *remarksCell = [[TJYMenuDetailsRemarksCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remarksCellIdentifier];
            remarksCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [remarksCell cellInitWithData:cookListModel.abstract];
            return remarksCell;
        }break;
        case 1:
        {
            TJYIngredientCell *ingredientCell = [tableView dequeueReusableCellWithIdentifier:ingredientCellIdentifier];
            if (!ingredientCell) {
                ingredientCell = [[TJYIngredientCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ingredientCellIdentifier];
            }
            [ingredientCell cellInitWithData:ingredientArray[indexPath.row]];
            ingredientCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return ingredientCell;
        }
        case 2:
        {
            TJYCookStepCell *stepCell = [tableView dequeueReusableCellWithIdentifier:StepCellIdentifier];
            if (!stepCell) {
                stepCell = [[TJYCookStepCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StepCellIdentifier];
            }
            stepCell.selectionStyle = UITableViewCellSelectionStyleNone;
            stepCell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            [stepCell cellInitWithData:stepListArr[indexPath.row]];
            return stepCell;
        }break;
        case 3:
        {
            TJYMenuDetailsRemarksCell *remarksCell = [[TJYMenuDetailsRemarksCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remarksCellIdentifier];
            remarksCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [remarksCell cellInitWithData:cookListModel.remarks];
            return remarksCell;
        }break;
        default:
            break;
    }
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            CGFloat statusHeight = [TJYMenuDetailsRemarksCell tableView:tableView rowHeightForObject:cookListModel.abstract];
            return statusHeight>0? statusHeight + 16:0;
        }break;
        case 1:
        {
            return 40;
        }
        case 2:
        {/// 制作过程
            TJYCookSetpModel *stepModel  =stepListArr[indexPath.row];
            BOOL isFlay = [stepListArr count] - 1 == indexPath.row ? YES : NO;
            CGFloat cellHeight = [TJYCookStepCell returnRowHeightForObject:stepModel isScrollDown:isFlay];
            return cellHeight;
        }break;
        case 3:
        {// 小贴士动态高度
            CGFloat statusHeight = [TJYMenuDetailsRemarksCell tableView:tableView rowHeightForObject:cookListModel.remarks];
            return statusHeight>0? statusHeight + 16:0;
        }break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0){
        return 0.1;
    }else if (section==4&&cookListModel.remarks.length==0){
        return 0.1;
    }else{
        return 30;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 40; // 用于显示热量
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    sectionHeaderView.backgroundColor=kBackgroundColor;

    UILabel *sectionTitle =[[UILabel alloc] initWithFrame: CGRectMake(15,15/2, 200, 15)];
    sectionTitle.font=kFontWithSize(15);
    sectionTitle.textColor=[UIColor colorWithHexString:@"666666"];
    [sectionHeaderView addSubview:sectionTitle];

    switch (section) {
        case 1:
        {
            sectionTitle.text = @"所需食材";
        }break;
        case 2:
        {
            sectionTitle.text = @"制作步骤";
        }break;
        case 3:
        {
            sectionTitle.text = cookListModel.remarks.length==0?@"":@"小贴士";
        }break;
        default:
            break;
    }
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        UIView *sectionFooterView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        sectionFooterView.backgroundColor=[UIColor whiteColor];
        
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 0.5)];
        lineView.backgroundColor=kLineColor;
        [sectionFooterView addSubview:lineView];

        UILabel *calorieLab=[[UILabel alloc] initWithFrame:CGRectMake(15,10 , 100, 20)];
        calorieLab.textColor=[UIColor colorWithHexString:@"ff9d38"];
        calorieLab.text=@"热量";
        calorieLab.font=kFontWithSize(13);
        [sectionFooterView addSubview:calorieLab];
        
        UILabel *heatLabel =[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 160,10 , 150, 20)];
        heatLabel.textAlignment=NSTextAlignmentRight;
        heatLabel.text = [NSString stringWithFormat:@"≈%ld千卡",(long)_caloriesSum];
        heatLabel.font=kFontWithSize(13);
        heatLabel.textColor=[UIColor colorWithHexString:@"ff9d38"];
        [sectionFooterView addSubview:heatLabel];
        
        return sectionFooterView;
    }else{
        return nil;
    }
}

#pragma mark --
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.tableView) {
        if (scrollView.contentOffset.y > 80) {
            [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                // 导航条加颜色（不再透明）
                _navigationView.backgroundColor = kSystemColor;
                // 滑动范围下移动至导航条下从64开始（确保分区头视图贴着导航条下边缘显示）
                scrollView.contentInset =UIEdgeInsetsMake(kNewNavHeight,0, 0,0);
                _menuNavLabel.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                //导航条透明
                _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
                _menuNavLabel.hidden = YES;
                //滑动范围熊0开始
                scrollView.contentInset =UIEdgeInsetsMake(0,0, 0,0);
            }];
        }
    }else if (scrollView==self.cycleScrollView){
        pageControl.currentPage=scrollView.contentOffset.x/kScreenWidth+0.5;
    }
}

#pragma mark UIActionSheetDelegate (TimePickerView)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSInteger hour=[timePicker.locatePicker selectedRowInComponent:0]+1;
        NSInteger minute=[timePicker.locatePicker selectedRowInComponent:2];
        if (hour==1) {
            if (minute>=orderSelectMinute) {
                minute=minute-orderSelectMinute;
            }
        }else{
            if (minute>=orderSelectMinute) {
                minute=minute-orderSelectMinute;
            }else{
                minute=minute+60-orderSelectMinute;
                hour--;
            }
            
        }
        MyLog(@"预约时间：%@",[NSString stringWithFormat:@"%li时%li分",(long)hour,(long)minute]);
        
        [self.model.stateDict setObject:@"云菜谱" forKey:@"state"];
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)hour] forKey:@"orderHour"];
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)minute] forKey:@"orderMin"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",[self loadTitleAsc],equipmentModel.code];
        [self.model.stateDict setObject:urlStr forKey:@"cloudMenu"];
        [self.model.stateDict setObject:self.model.deviceName forKey:@"name"];
        
        Byte byte[2] = {};
        byte[0]=(Byte) ((_caloriesSum>>8) & 0xFF);
        byte[1]=(Byte) (_caloriesSum & 0xFF);
        
        MyLog(@"calorie1:%hhu,calorie2:%hhu",byte[0],byte[1]);
        
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%hhu",byte[0]] forKey:@"calorie1"];
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%hhu",byte[1]] forKey:@"calorie2"];
        
        
        [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.model];
    }
}


#pragma mark -- NSNotification
#pragma mark 收到信息回调
-(void)menuDetailOnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    
    MyLog(@"menuDetailOnPipeData mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,[recvData hexString]);

    if ([[device getMacAddressSimple] isEqualToString:self.model.mac]) {
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];

        if (cmd_data[5]==0x13 && cmd_data[8]==0x05){
            //设置偏好成功
            MyLog(@"设备(%@)，设置偏好成功",self.model.deviceName);
            NSDictionary *menuDict=@{@"name":cookListModel.name,@"image_id_cover":self.imageUrl};
            [[NSNotificationCenter defaultCenter] postNotificationName:KSetPeferenceMenuSuccess object:nil userInfo:menuDict];
            
            kSelfWeak;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[TCLowerSugarDeviceViewController class]]) {
                            [weakSelf.navigationController popToViewController:controller animated:YES];
                            return;
                        }
                    }
                });
            });
        }else{
            
        }
    }
}
 

#pragma mark -- Event response
#pragma mark  立即启动／预约启动／设置偏好
- (void)deviceAction:(UIButton *)button{
    if (self.isLowerSugarCook) {
        [self.model.stateDict setObject:@"00" forKey:@"WorkHour"];
        [self.model.stateDict setObject:@"00" forKey:@"WorkMin"];
        
        NSString *menuCommand = [NSString stringWithFormat:@"%@%@",[self loadTitleAsc],equipmentModel.code];
        [self.model.stateDict setObject:menuCommand forKey:@"cloudMenu"];
        [self.model.stateDict setObject:self.model.deviceName forKey:@"name"];
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%ld",(long)cookListModel.allenergykcal] forKey:@"calorie"];
        //降糖比
        [self.model.stateDict setObject:[NSString stringWithFormat:@"%ld",(long)cookListModel.hypoglycemic] forKey:@"lowerSugarPercent"];
        [self.model.stateDict setObject:@"降糖煮" forKey:@"state"];
        
        
        [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendSetPreferenceCommandForDevice:self.model];
    }else{
        if (button.tag==100) { //立即启动
            [self.model.stateDict setObject:@"云菜谱" forKey:@"state"];
            [self.model.stateDict setObject:@"00" forKey:@"orderHour"];
            [self.model.stateDict setObject:@"00" forKey:@"orderHourMin"];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@",[self loadTitleAsc],equipmentModel.code];
            [self.model.stateDict setObject:urlStr forKey:@"cloudMenu"];
            [self.model.stateDict setObject:self.model.deviceName forKey:@"name"];
            
            Byte byte[2] = {};
            byte[0]=(Byte) ((_caloriesSum>>8) & 0xFF);
            byte[1]=(Byte) (_caloriesSum & 0xFF);
            
            MyLog(@"calorie1:%hhu,calorie2:%hhu",byte[0],byte[1]);
            
            [self.model.stateDict setObject:[NSString stringWithFormat:@"%hhu",byte[0]] forKey:@"calorie1"];
            [self.model.stateDict setObject:[NSString stringWithFormat:@"%hhu",byte[1]] forKey:@"calorie2"];
            
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.model];
            
        }else if (button.tag == 101){ //预约启动
            timePicker =[[TimePickerView alloc]initWithTitle:@"预约时间" delegate:self];
            timePicker.pickerStyle=PickerStyle_OrderTime;
            //获取当前时间
            NSString *time=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
            NSInteger selectHour=[time substringWithRange:NSMakeRange(11, 2)].integerValue;
            orderSelectMinute=[time substringWithRange:NSMakeRange(14, 2)].integerValue;
            
            timePicker.minHours=selectHour+1;
            timePicker.minMinutes=orderSelectMinute;
            timePicker.maxHours=selectHour+8;
            MyLog(@"selectHour:%ld,selectmin:%ld maxhours:%ld",(long)selectHour,(long)orderSelectMinute,(long)timePicker.maxHours);
            
            timePicker.descLabel.text=@"预约时间范围1～8小时";
            timePicker.descLabel.hidden=NO;
            
            [timePicker.locatePicker selectRow:0 inComponent:0 animated:YES];
            [timePicker.locatePicker selectRow:0 inComponent:2 animated:YES];
            [timePicker showInView:self.view];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:0 inComponent:0];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:0  inComponent:2];
        }
    }
}

- (void)navBarBackAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- Private Methods
#pragma mark  加载菜谱详情数据
- (void)loadCloudMenuDetailData{
    NSString *url = [NSString stringWithFormat:@"%@?id=%ld",kCloudMenuDetail,(long)_menuid];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:url success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        [weakSelf initDataWithDic:resultDic];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 解析数据
- (void)initDataWithDic:(NSDictionary *)resultDic{
    /* 每100克卡路里 */
    _calories_pre100 =[[resultDic objectForKey:@"calories_pre100"] integerValue];
    /* 食材总热量 */
    _caloriesSum = [[resultDic objectForKey:@"calories_sum"] integerValue];
    
    /* 菜谱简介 */
    NSDictionary *cookListDic = [resultDic objectForKey:@"cookList"];
    [cookListModel setValues:cookListDic];
    
    menuNameLabel.text=cookListModel.name;
    energyLabel.text  =[NSString stringWithFormat:@"%ld千卡/100克(可食部分)",(long)_calories_pre100];
    
  
     _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
     _menuNavLabel.hidden = YES;
     _menuNavLabel.text = cookListModel.name;//导航栏菜谱名称
     NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
     CGSize size=[_menuNavLabel.text sizeWithAttributes:attrs];
     [_menuNavLabel setFrame:CGRectMake((kScreenWidth- size.width)/2, 20, size.width, 44)];
    
    
    /* banner图片 */
    NSArray *imgArr = [resultDic objectForKey:@"imageList"];
    if (imgArr.count>0) {
        for (NSInteger i=0; i<imgArr.count; i++) {
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(i*kScreenWidth, 0, kScreenWidth, 3 *(kScreenWidth/4))];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imgArr[i]] placeholderImage:[UIImage imageNamed:@"img_recommend"]];
            imageView.contentMode=UIViewContentModeScaleAspectFill;
            [self.cycleScrollView addSubview:imageView];
        }
        self.cycleScrollView.contentSize=CGSizeMake(kScreenWidth*imgArr.count, 3 *(kScreenWidth/4));
    }else{
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 3 *(kScreenWidth/4))];
        imageView.image=[UIImage imageNamed:@"img_recommend"];
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        [self.cycleScrollView addSubview:imageView];
        self.cycleScrollView.contentSize=CGSizeMake(kScreenWidth, 3 *(kScreenWidth/4));
    }
    
    pageControl.hidden=imgArr.count<2;
    pageControl.numberOfPages=imgArr.count;
    pageControl.currentPage=0;
    
    /*  设备 */
    NSArray *equipmentArry = [resultDic objectForKey:@"equipment"];
    if (equipmentArry.count > 0) {
        [equipmentModel setValues:equipmentArry[0]];
    }

    /* 食材 */
    NSArray *ingredientArr = [resultDic objectForKey:@"ingredient"];
    if (ingredientArr.count > 0) {
        for (NSDictionary *ingredientDict in ingredientArr) {
            TJYCookIngredientModel *ingredientModel = [TJYCookIngredientModel new];
            [ingredientModel setValues:ingredientDict];
            [ingredientArray addObject:ingredientModel];
        }
    }
    
    /* 制作步骤 */
    NSArray *stepList = [resultDic objectForKey:@"stepList"];
    for (NSDictionary *stepDic in stepList) {
        TJYCookSetpModel *stepModel = [TJYCookSetpModel new];
        [stepModel setValues:stepDic];
        [stepListArr addObject:stepModel];
    }
    
    [_tableView reloadData];
}

#pragma mark  Navigation 导航栏
- (void)setNavigation{
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
    _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
    [self.view addSubview:_navigationView];
    
    UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(navBarBackAction) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:backBtn];
    
    _menuNavLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, 44)];
    _menuNavLabel.textAlignment=NSTextAlignmentCenter;
    _menuNavLabel.font=kFontWithSize(18);
    _menuNavLabel.textColor=[UIColor whiteColor];
    [_navigationView addSubview:_menuNavLabel];
}

#pragma mark -- 获取菜谱的asc编码
- (NSString *)loadTitleAsc{
    NSString *string = cookListModel.name;
    NSString *str = @"";
    for (int i=0; i<string.length; i++) {
        int asciiCode = [string characterAtIndex:i]; //65
        NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",asciiCode]];
        str = [NSString stringWithFormat:@"%@%@",str,hexString];
    }
    NSInteger length = str.length;
    for (int i=0; i<40-length; i++) {
        str = [NSString stringWithFormat:@"%@0",str];
    }
    return str;
}

#pragma mark -- tableHeaderView
- (UIView *)tableViewHeaderView{
     UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0 , kScreenWidth,3*kScreenWidth/4 + 80)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:self.cycleScrollView];
    
    pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, 3 *(kScreenWidth/4)-30, 120, 20)];
    pageControl.pageIndicatorTintColor=[UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor= kSystemColor;
    [headerView insertSubview:pageControl aboveSubview:self.cycleScrollView];
    
    // 菜谱相关信息
    menuNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,self.cycleScrollView.bottom+20, kScreenWidth-40, 20)];
    menuNameLabel.font = [UIFont systemFontOfSize:18];
    menuNameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
    [headerView addSubview:menuNameLabel];
    
    /// 卡路里
    energyLabel =[[UILabel alloc] initWithFrame:CGRectMake(20, menuNameLabel.bottom +10, kScreenWidth-40, 20)];
    energyLabel.font=kFontWithSize(14);
    energyLabel.textColor=[UIColor colorWithHexString:@"0x999999"];
    [headerView addSubview:energyLabel];
    
    UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(15,energyLabel.bottom+10, kScreenWidth - 15, 0.5)];
    line.backgroundColor=kLineColor;
    [headerView addSubview:line];
    
    return headerView;
}

#pragma mark -- TableViewfooterView
- (UIView *)tableViewfooterView{
    UIView *footerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth , 160)];
    footerView.backgroundColor=[UIColor bgColor_Gray];
    
    UIView *whiteBgView =[[UIView alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth -30, 120)];
    whiteBgView.backgroundColor=[UIColor bgColor_Gray];
    [footerView addSubview:whiteBgView];
    
    NSArray *footerBtnTitleArray =self.isLowerSugarCook?@[@"设为偏好"]:@[@"立即启动",@"预约启动"];
    NSArray *colorArray =self.isLowerSugarCook?@[@"0xff8314"]:@[@"0xffc72f",@"0x81d570"];
    NSArray *footerBtnImgArray =self.isLowerSugarCook? @[@"ic_caipu_like"]:@[@"ic_caipu_shebei",@"ic_caipu_time"];
    
    for (NSInteger i = 0; i < footerBtnTitleArray.count; i++) {
        StartDeviceButton *footerBtn = [[StartDeviceButton alloc]initWithFrame:CGRectMake( i * whiteBgView.width/2+(whiteBgView.width/2-80)/2, 10 ,80, 80) dict:footerBtnImgArray[i]];
        if (footerBtnTitleArray.count==1) {
            footerBtn.frame=CGRectMake((whiteBgView.width-80)/2, 10, 80, 80);
        }
        footerBtn.tag = 100+i;
        footerBtn.layer.cornerRadius =40;
        footerBtn.backgroundColor = [UIColor colorWithHexString:colorArray[i]];
        [footerBtn addTarget:self action:@selector(deviceAction:) forControlEvents:UIControlEventTouchUpInside];
        [whiteBgView addSubview:footerBtn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(footerBtn.left, footerBtn.bottom+5, footerBtn.width, 20)];
        titleLabel.text = footerBtnTitleArray[i];
        titleLabel.textAlignment  = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [whiteBgView addSubview:titleLabel];
    }
    return footerView;
}

#pragma mark -- Getters
#pragma mark 主视图
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackgroundColor;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableHeaderView = [self tableViewHeaderView];
        _tableView.tableFooterView = [self tableViewfooterView];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark Banner视图
-(UIScrollView *)cycleScrollView{
    if (_cycleScrollView==nil) {
        _cycleScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 3 *(kScreenWidth/4))];
        _cycleScrollView.pagingEnabled=YES;
        _cycleScrollView.showsHorizontalScrollIndicator=NO;
        _cycleScrollView.delegate=self;
    }
    return _cycleScrollView;
}


#pragma mark 获取时间间隔
-(NSTimeInterval )getDateIntervalWithHour:(NSInteger )hour Min:(NSInteger )min{
    NSTimeInterval interval;
    //生成时间
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone systemTimeZone];//系统所在时区
    [df setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    NSString *dateStr=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
    dateStr=[[dateStr substringToIndex:11] stringByAppendingString:[NSString stringWithFormat:@"%li:%li:00",(long)hour,(long)min]];
    
    NSDate *date=[df dateFromString:dateStr];
    interval=[date timeIntervalSinceDate:[NSDate date]];
    
    //避免一分钟差异
    if (interval>60) {
        interval+=60;
    }
    
    //避免一分钟立刻操作
    if (interval<60 && interval > 0) {
        interval+=60;
    }
    
    //如果比当前时间少则计算到明天
    if (interval<-60) {
        interval+=24*60*60+60;
    }
    return interval;
}


-(void)dealloc{
    self.cycleScrollView.delegate=nil;
    self.tableView.delegate=nil;
    self.tableView.dataSource=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
}



@end
