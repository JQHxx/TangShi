//
//  TCRecordDietViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRecordDietViewController.h"
#import "TCAddFoodViewController.h"
#import "TCDiningButton.h"
#import "TCFoodAddTableViewCell.h"
#import "TCFoodAddModel.h"
#import "TimePickerView.h"
#import "TCDatePickerView.h"
#import "TCFoodAddTool.h"
#import "RecordDietButton.h"

@interface TCRecordDietViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,TCDatePickerViewDelegate,UIAlertViewDelegate>{
    NSArray               *periodArray;
    NSMutableArray        *foodListArray;
    
    TimePickerView        *pickerView;
    NSString              *dietDateStr;
    NSString              *nowDateStr;
    NSString              *dietTypeStr;
    
    BOOL            isBoolBack;             //是否确定返回
}

@property (nonatomic,strong)UILabel          *colaryLabel;
@property (nonatomic,strong)TCDiningButton   *diningTimeButton;
@property (nonatomic,strong)TCDiningButton   *diningTypeButton;
@property (nonatomic,strong)UIView           *foodHeadView;
@property (nonatomic,strong)UITableView      *foodTableView;
@property (nonatomic,strong)TCBlankView      *blankView;
@property (nonatomic,strong)UIButton         *saveFoodButton;

@end

@implementation TCRecordDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"记录饮食";
    
    self.rightImageName=self.foodRecordModel?@"ic_n_del":nil;
    nowDateStr=[[TCHelper sharedTCHelper] getCurrentDate];   //今天

    self.view.backgroundColor=[UIColor bgColor_Gray];
    periodArray=@[@"早餐（00:00-08:59）",@"上午加餐（9:00-10:59）",@"午餐（11:00-13:59）",@"下午加餐（14:00-16:59）",@"晚餐（17:00-19:59）",@"晚上加餐（20:00-23:59）"];
    foodListArray=[[NSMutableArray alloc] init];
    isBoolBack = NO;
    dietDateStr=nil;
    dietTypeStr=nil;
    
    [self loadDietRecordData];  //加载饮食记录数据
    
    [self.view addSubview:self.colaryLabel];
    [self.view addSubview:self.diningTimeButton];
    [self.view addSubview:self.diningTypeButton];
    [self.view addSubview:self.foodHeadView];
    [self.view addSubview:self.foodTableView];
    [self.view addSubview:self.blankView];
    self.blankView.hidden=foodListArray.count>0;
    [self.view addSubview:self.saveFoodButton];
    
    
    [self getDietRecordData];  //计算热量
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isAddFood) {
        [self addFoodReloadAction];
        [TCHelper sharedTCHelper].isAddFood=NO;
    }
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFoodAddTableViewCell";
    TCFoodAddTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TCFoodAddTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCFoodAddModel *food=foodListArray[indexPath.row];
    [cell cellDisplayWithFood:food];
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        TCFoodAddModel *food=foodListArray[indexPath.row];
        [foodListArray removeObjectAtIndex:indexPath.row];
        [[TCFoodAddTool sharedTCFoodAddTool] deleteFood:food];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self getDietRecordData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -- Custom Delegate
#pragma mark  UIActionSheetDelegate (TimePickerView)
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        isBoolBack = YES;
        if (pickerView.pickerStyle==PickerStyle_DietTime) {
            NSInteger index=[pickerView.locatePicker selectedRowInComponent:0];
            dietTypeStr=[periodArray objectAtIndex:index];
            self.diningTypeButton.valueString=dietTypeStr;
        }
    }
}

#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    NSInteger data =[[TCHelper sharedTCHelper] compareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        isBoolBack  = YES;
        dietDateStr=dateStr;
        self.diningTimeButton.valueString=dietDateStr;
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *body=[NSString stringWithFormat:@"id=%ld",(long)self.foodRecordModel.id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDietRecordDelete body:body success:^(id json) {
            [TCHelper sharedTCHelper].isDietReload=YES;
            [TCHelper sharedTCHelper].isHomeDietReload=YES;
            
            [[TCFoodAddTool sharedTCFoodAddTool] removeAllFood];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark -- Event response
#pragma mark 用餐时间
-(void)addDiningTimeAction:(TCDiningButton *)button{
    [MobClick event:@"102_002031"];
    TCDatePickerView *datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:dietDateStr pickerType:DatePickerViewTypeDate];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}

#pragma mark 用餐类别
-(void)addDiningTypeAction:(TCDiningButton *)button{
    [MobClick event:@"102_002032"];
    pickerView=[[TimePickerView alloc] initWithTitle:@"" delegate:self];
    pickerView.pickerStyle=PickerStyle_DietTime;
    pickerView.valuesArray=periodArray;
    NSUInteger index=[periodArray indexOfObject:dietTypeStr];
    [pickerView.locatePicker selectRow:index inComponent:0 animated:YES];
    [pickerView showInView:self.view];
}

#pragma mark 添加食物
-(void)addFoodAction:(UIButton *)sender{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-06"];
#endif
    [MobClick event:@"102_002033"];
    TCAddFoodViewController *addFoodVC=[[TCAddFoodViewController alloc] init];
    [self.navigationController pushViewController:addFoodVC animated:YES];
}

#pragma mark 保存食物记录
-(void)saveDietDataAction:(UIButton *)sender{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-05"];
#endif
    [MobClick event:@"102_002034"];
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (TCFoodAddModel *model in foodListArray) {
        NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.id],model.weight,[NSNumber numberWithInteger:model.energykcal*[model.weight doubleValue]/100]] forKeys:@[@"ingredient_id",@"ingredient_weight",@"ingredient_calories"]];
        [tempArr addObject:dict];
    }
    if (tempArr.count>0) {
        NSString *jsonStr=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:tempArr]; //数组转json
        NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dietDateStr format:@"yyyy-MM-dd"];
        NSString *period=[[TCHelper sharedTCHelper] getDietPeriodEnNameWithPeriod:dietTypeStr];
        
        NSString *body=nil;
        NSString *url=nil;
        if (self.foodRecordModel) {  //更新饮食记录
            body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&ingredient=%@&id=%ld",period,(long)timeSp,jsonStr,(long)self.foodRecordModel.id];
            url=kDietRecordUpdate;
        }else{  //添加饮食记录
            body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&ingredient=%@",period,(long)timeSp,jsonStr];
            url=kDietRecordAdd;
        }
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
            [TCHelper sharedTCHelper].isDietReload=YES;
            [TCHelper sharedTCHelper].isHomeDietReload=YES;
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [[TCFoodAddTool sharedTCFoodAddTool] removeAllFood];
            if (!self.foodRecordModel) {
                [self getTaskPointsWithActionType:7 isTaskList:_isTadkListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                    if (clickIndex == 1001 || isBack) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }];// 获取积分
            }else{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
 
    } else {
        [self.view makeToast:@"请添加食物" duration:1.0 position:CSToastPositionCenter];

    }
}

#pragma mark 返回按钮事件
-(void)leftButtonAction{
    
    if (isBoolBack == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TCFoodAddTool sharedTCFoodAddTool] removeAllFood];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        [[TCFoodAddTool sharedTCFoodAddTool] removeAllFood];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)addFoodReloadAction{
    NSMutableArray *foodArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    
    NSMutableArray *foodIds=[[NSMutableArray alloc] init];
    for (TCFoodAddModel *model in foodListArray) {
        [foodIds addObject:[NSNumber numberWithInteger: model.id]];
    }
    for (NSInteger i=0; i<foodArr.count; i++) {
        TCFoodAddModel *foodModel=foodArr[i];
        if ([foodIds containsObject:[NSNumber numberWithInteger:foodModel.id]]) {
            [foodListArray replaceObjectAtIndex:i withObject:foodModel];
        }else{
            [foodListArray addObject:foodModel];
        }
    }
    isBoolBack = YES;
    [self.foodTableView reloadData];
    
    [self getDietRecordData];
    self.blankView.hidden=foodListArray.count>0;
}

#pragma mark 删除
-(void)rightButtonAction{
    if (self.foodRecordModel) {
        [MobClick event:@"102_002035"];
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"您确定要删除该条饮食记录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

#pragma mark -- Private Methods
#pragma mark 加载饮食记录
-(void)loadDietRecordData{
    if (self.foodRecordModel) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        NSArray *list=self.foodRecordModel.ingredient;
        for (NSInteger i=0; i<list.count; i++) {
            NSDictionary *dict=list[i];
            TCFoodAddModel *model=[[TCFoodAddModel alloc] init];
            model.id=[dict[@"ingredient_id"] integerValue];
            model.image_url=dict[@"image_url"];
            model.name=dict[@"ingredient_name"];
            model.energykcal=[dict[@"ingredient_calories"] integerValue];
            model.calory=[NSNumber numberWithInteger:[dict[@"ingredient_calorie"]  integerValue]];

            model.weight=[NSNumber numberWithInteger:[dict[@"ingredient_weight"] integerValue]];
            model.isSelected=[NSNumber numberWithBool:YES];
            [tempArr addObject:model];
        }
        [TCFoodAddTool sharedTCFoodAddTool].selectFoodArray=tempArr;
        foodListArray=tempArr;
    }
}

#pragma mark 计算能量值
-(void)getDietRecordData{
    NSInteger totalColaries=0;
    if (foodListArray.count>0) {
        for (TCFoodAddModel *model in foodListArray) {
            if ([TCHelper sharedTCHelper].isHistoryDiet == YES) {
                totalColaries+=model.calory>0?model.energykcal:model.energykcal*[model.weight integerValue]/100;
            }else{
                totalColaries+=model.energykcal*[model.weight doubleValue]/100;
            }
        }
    }
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld  千卡",(long)totalColaries]];
    [attributeStr addAttributes:@{NSForegroundColorAttributeName:kRGBColor(244, 182, 123),NSFontAttributeName:[UIFont systemFontOfSize:25]} range:NSMakeRange(0, attributeStr.length-2)];
    self.colaryLabel.attributedText=attributeStr;
}

#pragma mark -- Getters and Setters
#pragma mark 能量值
-(UILabel *)colaryLabel{
    if (_colaryLabel==nil) {
        _colaryLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 60)];
        _colaryLabel.backgroundColor=[UIColor whiteColor];
        _colaryLabel.textColor=[UIColor blackColor];
        _colaryLabel.font=[UIFont systemFontOfSize:13.0f];
        _colaryLabel.textAlignment=NSTextAlignmentCenter;
        _colaryLabel.text=self.foodRecordModel?[NSString stringWithFormat:@"%ld",(long)self.foodRecordModel.all_calories_record]:@"0";
    }
    return _colaryLabel;
}

#pragma mark  用餐日期
-(TCDiningButton *)diningTimeButton{
    if (_diningTimeButton==nil) {
        _diningTimeButton=[[TCDiningButton alloc] initWithFrame:CGRectMake(0, self.colaryLabel.bottom+10, kScreenWidth, 50) title:@"用餐日期"];
        [_diningTimeButton addTarget:self action:@selector(addDiningTimeAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *dietDate=[[TCHelper sharedTCHelper] getCurrentDate];
        if (self.foodRecordModel) {
            dietDateStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.foodRecordModel.feeding_time format:@"yyyy-MM-dd"];
        }
        dietDateStr=kIsEmptyString(dietDateStr)?dietDate:dietDateStr;
        _diningTimeButton.valueString=dietDateStr;
    }
    return _diningTimeButton;
}

#pragma mark 用餐类别
-(TCDiningButton *)diningTypeButton{
    if (_diningTypeButton==nil) {
        _diningTypeButton=[[TCDiningButton alloc] initWithFrame:CGRectMake(0, self.diningTimeButton.bottom, kScreenWidth, 50) title:@"用餐类别"];
        [_diningTypeButton addTarget:self action:@selector(addDiningTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *dietPeriod=[[TCHelper sharedTCHelper] getDietPeriodOfCurrentTime];
        if (self.foodRecordModel) {
            dietTypeStr=[[TCHelper sharedTCHelper] getDietPeriodChTimeNameWithPeriod:self.foodRecordModel.time_slot];
        }
        dietTypeStr=kIsEmptyString(dietTypeStr)?dietPeriod:dietTypeStr;
        _diningTypeButton.valueString=dietTypeStr;
        
        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [_diningTypeButton addSubview:lineLabel];
    }
    return _diningTypeButton;
}

#pragma mark 添加食物
-(UIView *)foodHeadView{
    if (_foodHeadView==nil) {
        _foodHeadView=[[UIView alloc] initWithFrame:CGRectMake(0, self.diningTypeButton.bottom+10, kScreenWidth, 50)];
        _foodHeadView.backgroundColor=[UIColor whiteColor];
        
        RecordDietButton *addBtn=[[RecordDietButton alloc] initWithFrame:CGRectMake(40, 5, kScreenWidth-80, 40) title:@"添加食物"];
        [addBtn addTarget:self action:@selector(addFoodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_foodHeadView addSubview:addBtn];
        
        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [_foodHeadView addSubview:lineLabel];
    }
    return _foodHeadView;
}

#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (_foodTableView==nil) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.foodHeadView.bottom, kScreenWidth, kScreenHeight-self.foodHeadView.bottom-50) style:UITableViewStylePlain];
        _foodTableView.delegate=self;
        _foodTableView.dataSource=self;
        _foodTableView.showsVerticalScrollIndicator=NO;
        _foodTableView.backgroundColor=[UIColor whiteColor];
        _foodTableView.tableFooterView=[[UIView alloc] init];
    }
    return _foodTableView;
}

#pragma mark 尚未添加食物
-(UIView *)blankView{
    if (_blankView==nil) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, self.foodHeadView.bottom+10, kScreenWidth, 200) img:@"img_tips_no" text:@"尚未添加食物"];
    }
    return _blankView;
}

#pragma mark 保存
-(UIButton *)saveFoodButton{
    if (_saveFoodButton==nil) {
        _saveFoodButton=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-KTabbarSafeBottomMargin-50, kScreenWidth, 50)];
        [_saveFoodButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveFoodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveFoodButton.backgroundColor=kSystemColor;
        [_saveFoodButton addTarget:self action:@selector(saveDietDataAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveFoodButton;
}

@end
