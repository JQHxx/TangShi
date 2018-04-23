//
//  TCRecordSportViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRecordSportViewController.h"
#import "TCSportsViewController.h"
#import "TCHomeSportsViewController.h"
#import "TimePickerView.h"
#import "TCDatePickerView.h"
#import "TCSportAddModel.h"
#import "BackScrollView.h"

@interface TCRecordSportViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,TCSportsViewControllerDelegate,TCDatePickerViewDelegate,UIAlertViewDelegate>{

    NSArray         *personInfoArray;
    NSDictionary    *sportTypeDict;        //运动类型
    NSInteger       minute;                //运动时长
    NSString        *sportbeginTime;       //运动开始时间
    NSInteger       consumeColaries;       //消耗能量
    NSString         *nowDateStr;
    TimePickerView   *Picker;               //运动时长选择器
    TCDatePickerView *datePickerView;       //开始时间选择
    UITextView      *remarkTextView;
    UILabel         *promptLabel;
    UILabel         *countLabel;
    BOOL            isBoolBack;             //是否确定返回
}
@property (nonatomic,strong)BackScrollView *rootScrollView;
@property (nonatomic,strong)UITableView    *sportTableView;
@end

@implementation TCRecordSportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"记录运动";
    self.rightImageName=self.sportModel?@"ic_n_del":nil;
    nowDateStr=[[TCHelper sharedTCHelper] getCurrentDateTime];   //今天

    self.view.backgroundColor = [UIColor bgColor_Gray];
    isBoolBack=NO;
    
    personInfoArray=@[@"运动类型",@"运动时长",@"运动开始时间"];
    sportTypeDict=[[NSDictionary alloc] init];
    minute=0;
    consumeColaries=0;
    sportbeginTime=[[TCHelper sharedTCHelper] getCurrentDateTime];
    
    [self initsportView];
    [self initSportsRecordData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0?3:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=personInfoArray[indexPath.row];
        if (indexPath.row==0) {
            NSString *sportType=sportTypeDict[@"name"];
            cell.detailTextLabel.text=kIsEmptyString(sportType)?@"请选择运动类型":sportType;
        }else if(indexPath.row==1){
            cell.detailTextLabel.text=minute==0?@"请选择运动时长":[NSString stringWithFormat:@"%ld分钟",(long)minute];
        }else{
            cell.detailTextLabel.text=sportbeginTime;
        }
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }else {
        cell.textLabel.text=@"消耗热量";
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)consumeColaries]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f39800"] range:NSMakeRange(0, attributeStr.length-2)];
        cell.detailTextLabel.attributedText=attributeStr;
//        cell.detailTextLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)consumeColaries];
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            [MobClick event:@"102_002036"];
            TCSportsViewController *sportsVC = [[TCSportsViewController alloc] init];
            sportsVC.controllerDelegate = self;
            [self.navigationController pushViewController:sportsVC animated:YES];
        }else if(indexPath.row ==1){
            [MobClick event:@"102_002037"];
            Picker =[[TimePickerView alloc]initWithTitle:@"运动时长" delegate:self];
            Picker.pickerStyle=PickerStyle_sportTime;
            minute = minute < 1? 30:minute;
            [Picker.locatePicker selectRow:minute-1 inComponent:0 animated:YES];
            [Picker showInView:self.view];
            [Picker pickerView:Picker.locatePicker didSelectRow:minute-1 inComponent:0];
        }else if (indexPath.row == 2){
            [MobClick event:@"102_002038"];
            datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:sportbeginTime pickerType:DatePickerViewTypeDateTime];
            datePickerView.pickerDelegate=self;
            [datePickerView datePickerViewShowInView:self.view];
        }
    }else{
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section==0?20:0.1;
}


#pragma mark -- NSNotification
#pragma mark 键盘弹出
-(void)sportsKeyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void(^animation)() = ^{
        if (remarkTextView.bottom+10>keyBoardBounds.origin.y) {
            self.rootScrollView.frame=CGRectMake(0, -(remarkTextView.bottom+10-keyBoardBounds.origin.y), kScreenWidth, kRootViewHeight);
        }
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark  键盘退出
-(void)sportsKeyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.rootScrollView.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark -- CustomDelegate
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    NSInteger data =[[TCHelper sharedTCHelper] comSuderpareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        sportbeginTime=dateStr;
        isBoolBack=YES;
        [_sportTableView reloadData];
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark  TCSportsViewControllerDelegate
-(void)sportsViewControllerDidSelectDict:(NSDictionary *)dict{
    sportTypeDict=dict;
    isBoolBack=YES;
    NSInteger calory=[sportTypeDict[@"calory"] integerValue];
    consumeColaries =minute*calory/60;
    [self.sportTableView reloadData];
}

#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_sportTime) {
            isBoolBack=YES;
            minute=[Picker.locatePicker selectedRowInComponent:0]+1;
            NSInteger calory=[sportTypeDict[@"calory"] integerValue];
            consumeColaries =minute*calory/60;
            [_sportTableView reloadData];
        }
    }
}   
#pragma mark--UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
    countLabel.text = tString;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]!= 0) {
        promptLabel.hidden = YES;
    }else{
        promptLabel.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    isBoolBack=YES;
    if (textView==remarkTextView) {
        
        if ([textView.text length]+text.length>100) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *body=[NSString stringWithFormat:@"id=%ld",(long)self.sportModel.id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSportRecordDelete body:body success:^(id json) {
            [TCHelper sharedTCHelper].isSportsReload=YES;
            [TCHelper sharedTCHelper].isHomeSportsReload=YES;
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark -- Event Response
#pragma mark 保存
-(void)preserveAction{
    [MobClick event:@"102_002039"];
    BOOL isEmojiBool = [[TCHelper sharedTCHelper] strIsContainEmojiWithStr:remarkTextView.text];
    if (isEmojiBool) {
        [self.view makeToast:@"不能保存特殊符号" duration:1.0 position:CSToastPositionCenter];
    } else {
    NSInteger beginTime=[[TCHelper sharedTCHelper] timeSwitchTimestamp:sportbeginTime format:@"yyyy-MM-dd HH:mm"];
    NSString *body=nil;
    NSString *url=nil;
    if (self.sportModel) {
        body=[NSString stringWithFormat:@"doSubmit=1&motion_bigin_time=%ld&motion_type=%@&motion_time=%ld&calorie=%ld&remark=%@&id=%ld",(long)beginTime,sportTypeDict[@"name"],(long)minute,(long)consumeColaries,remarkTextView.text,(long)self.sportModel.id];
        url=kSportRecordUpdate;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
            [self.navigationController popViewControllerAnimated:YES];
            [TCHelper sharedTCHelper].isSportsReload=YES;
            [TCHelper sharedTCHelper].isHomeSportsReload=YES;
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

    }else{
        NSString *motiontype =sportTypeDict[@"name"];
        if (!(motiontype.length>0)) {
            [self.view makeToast:@"请选择运动类型" duration:1.0 position:CSToastPositionCenter];
        }else if (!(minute>0)) {
            [self.view makeToast:@"请选择运动时长" duration:1.0 position:CSToastPositionCenter];
        }else{
        body=[NSString stringWithFormat:@"doSubmit=1&motion_bigin_time=%ld&motion_type=%@&motion_time=%ld&calorie=%ld&remark=%@",(long)beginTime,sportTypeDict[@"name"],(long)minute,(long)consumeColaries,remarkTextView.text];
        url=kSportRecordAdd;
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
            
                [TCHelper sharedTCHelper].isSportsReload=YES;
                [TCHelper sharedTCHelper].isHomeSportsReload=YES;
                [TCHelper sharedTCHelper].isTaskListRecord = YES;
                [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            if (!self.sportModel) {
                [self getTaskPointsWithActionType:8 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                    if (clickIndex == 1001 || isBack) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }]; // 获取积分
            }else{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

        }
    }
    }
}
#pragma mark 返回按钮事件
-(void)leftButtonAction{
    if (isBoolBack == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- 完成
- (void)resignKeyboard{
    [self.view endEditing:YES];
}

#pragma mark 删除
-(void)rightButtonAction{
    if (self.sportModel) {
        [MobClick event:@"102_002040"];
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"您确定要删除该条运动记录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

#pragma mark -- Pravite Methods
#pragma mark 初始化运动记录
-(void)initSportsRecordData{
    if (self.sportModel) {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"sports" ofType:@"plist"];
        NSArray *sportArray=[[NSArray alloc] initWithContentsOfFile:path];
        for (NSDictionary *dict in sportArray) {
            if ([dict[@"name"] isEqualToString:self.sportModel.motion_type]) {
                sportTypeDict=dict;
            }
        }
        minute=[self.sportModel.motion_time integerValue];
        sportbeginTime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.sportModel.motion_bigin_time format:@"yyyy-MM-dd HH:mm"];
        NSInteger calory=[sportTypeDict[@"calory"] integerValue];
        consumeColaries =minute*calory/60;
        [self.sportTableView reloadData];
        
        remarkTextView.text=self.sportModel.remark;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)remarkTextView.text.length];
        countLabel.text = tString;
        promptLabel.hidden=remarkTextView.text.length>0;
    }
}
#pragma mark -- toolbar
- (void)initToolBarTextView{

    //定义一个toolBar
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    topView.backgroundColor = [UIColor whiteColor];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    [remarkTextView setInputAccessoryView:topView];
}
#pragma mark 初始化界面
- (void)initsportView{
    [self.view insertSubview:self.rootScrollView atIndex:0];
    [self.rootScrollView addSubview:self.sportTableView];
    
    remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, _sportTableView.bottom+30, kScreenWidth, 120)];
    remarkTextView.layer.borderColor = [UIColor bgColor_Gray].CGColor;
    remarkTextView.layer.borderWidth = 1;
    remarkTextView.layer.cornerRadius = 6;
    remarkTextView.layer.masksToBounds = YES;
    remarkTextView.delegate = self;
    remarkTextView.font=[UIFont systemFontOfSize:14];
    [self.rootScrollView addSubview:remarkTextView];
    [self initToolBarTextView];
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, remarkTextView.top+5, 200, 20)];
    promptLabel.text = @"请填写备注（选填）";
    promptLabel.font = [UIFont systemFontOfSize:15];
    promptLabel.textColor = [UIColor grayColor];
    [self.rootScrollView addSubview:promptLabel];
    
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, remarkTextView.bottom-30, 80, 20)];
    countLabel.text = @"0/100";
    countLabel.textColor = [UIColor grayColor];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:14];
    [self.rootScrollView addSubview:countLabel];
    
    UIButton *preserveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kRootViewHeight-KTabbarSafeBottomMargin-50, kScreenWidth, 50)];
    preserveButton.backgroundColor = kSystemColor;
    [preserveButton setTitle:@"保存" forState:UIControlStateNormal];
    [preserveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [preserveButton addTarget:self action:@selector(preserveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.rootScrollView addSubview:preserveButton];
}

#pragma mark -- Getters and Setters
#pragma mark 根滚动视图
-(BackScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[BackScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    }
    return _rootScrollView;
}

#pragma mark 个人数据
-(UITableView *)sportTableView{
    if (_sportTableView==nil) {
        _sportTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 5, kScreenWidth, 220) style:UITableViewStylePlain];
        _sportTableView.delegate=self;
        _sportTableView.dataSource=self;
        _sportTableView.showsVerticalScrollIndicator=NO;
        _sportTableView.tableFooterView=[[UIView alloc] init];
        _sportTableView.scrollEnabled =NO; //设置tableview 不能滚动
    }
    return _sportTableView;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
