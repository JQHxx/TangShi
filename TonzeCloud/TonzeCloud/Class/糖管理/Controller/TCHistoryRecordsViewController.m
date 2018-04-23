//
//  TCHistoryRecordsViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHistoryRecordsViewController.h"
#import "TCRecordSugarViewController.h"
#import "TCRecordDietViewController.h"
#import "TCRecordSportViewController.h"
#import "TCSuagrHistoryCell.h"
#import "TCDietHistoryCell.h"
#import "TCSportHistoryCell.h"
#import "TCSugarModel.h"
#import "TCFoodRecordModel.h"
#import "TCSportRecordModel.h"
#import "TCBloodModel.h"
#import "TCGlycosylateModel.h"
#import "TCExaminationModel.h"
#import "TCBloodHistoryCell.h"
#import "TCGlyHistoryTableViewCell.h"
#import "TCExamteHistoryCell.h"
#import "TCPertainViewController.h"
#import "TCAddBloodViewController.h"
#import "TCCheckListViewController.h"
#import "TCHistoryMenuView.h"

@interface TCHistoryRecordsViewController ()<TCHistoryMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger              bloodPage;    //血糖记录页数
    NSInteger              dietPage;     //饮食记录页数
    NSInteger              sportPage;    //运动记录页数
    NSInteger              sugarPage;    //血压记录页数
    NSInteger              glycosyPage;  //糖化血红蛋白记录页数
    NSInteger              examinaPage;  //检查表记录页数
    NSInteger              selectIndex;
    NSArray                *cateArray;
    NSMutableArray         *sugarTimeArray;
    NSMutableArray         *sugarRecordsArray;
    NSMutableArray         *sugarLoadRecordsArray;
    NSMutableArray         *dietTimeArray;
    NSMutableArray         *dietRecordsArray;
    NSMutableArray         *sportTimeArray;
    NSMutableArray         *sportRecordsArray;
    NSMutableArray         *bloodTimeArray;
    NSMutableArray         *bloodRecordsArray;
    NSMutableArray         *glycosylateTimeArray;
    NSMutableArray         *glycosylateRecordsArray;
    NSMutableArray         *examinationTimeArray;
    NSMutableArray         *examinationRecordsArray;
    BOOL                   isBloodHistoryReload;
    BOOL                   isDietHistoryReload;
    BOOL                   isSportsHistoryReload;
    BOOL                   isSugarHistoryReload;
    BOOL                   isGlycosylateHistoryReload;
    BOOL                   isExaminationHistoryReload;
}

@property (nonatomic,strong)TCHistoryMenuView  *itemGroupView;
@property (nonatomic,strong)UITableView     *recordsTableView;
@property (nonatomic,strong)TCBlankView     *recordBlankView;

@end

@implementation TCHistoryRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"历史记录";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    bloodPage=dietPage=sportPage=sugarPage=glycosyPage=examinaPage=1;
    sugarTimeArray=[[NSMutableArray alloc] init];
    sugarRecordsArray=[[NSMutableArray alloc] init];
    dietTimeArray=[[NSMutableArray alloc] init];
    dietRecordsArray=[[NSMutableArray alloc] init];
    sportTimeArray=[[NSMutableArray alloc] init];
    sportRecordsArray=[[NSMutableArray alloc] init];
    bloodTimeArray=[[NSMutableArray alloc] init];
    bloodRecordsArray=[[NSMutableArray alloc] init];
    glycosylateTimeArray=[[NSMutableArray alloc] init];
    glycosylateRecordsArray=[[NSMutableArray alloc] init];
    examinationTimeArray=[[NSMutableArray alloc] init];
    examinationRecordsArray=[[NSMutableArray alloc] init];
    
    cateArray=@[@"血糖",@"饮食",@"运动",@"血压",@"糖化血红蛋白",@"检查单"];

    [self.view addSubview:self.itemGroupView];
    [self.view addSubview:self.recordsTableView];
    [self.recordsTableView addSubview:self.recordBlankView];
    self.recordBlankView.hidden=YES;
    
    [self jumpIntoSelectedItem];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isRecordsReload) {
        [self loadNewRecordData];
        [TCHelper sharedTCHelper].isRecordsReload=NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (selectIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"005-01-04" type:1];
#endif
    }else if (selectIndex==1){

    }else if (selectIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"005-03-04" type:1];
#endif
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isBloodHistoryReload=isDietHistoryReload=isSportsHistoryReload=isExaminationHistoryReload=isSugarHistoryReload=isGlycosylateHistoryReload=NO;
    if (selectIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"005-01-04" type:2];
#endif
    }else if (selectIndex==1){

    }else if (selectIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"005-03-04" type:2];
#endif
    }
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (selectIndex==0) {
        return sugarTimeArray.count;
    }else if (selectIndex==1){
        return dietTimeArray.count;
    }else if (selectIndex==2){
        return sportTimeArray.count;
    }else if (selectIndex==3){
        return bloodTimeArray.count;
    }else if (selectIndex==4){
        return glycosylateTimeArray.count;
    }else{
        return examinationTimeArray.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    if (selectIndex==0) {
        NSString *timeStr=sugarTimeArray[section];
        for (TCSugarModel *model in sugarRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measurement_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
    }else if (selectIndex==1){
        NSString *timeStr=dietTimeArray[section];
        for (TCFoodRecordModel *model in dietRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
    }else if (selectIndex==2){
        NSString *timeStr=sportTimeArray[section];
        for (TCSportRecordModel *model in sportRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
    }else if (selectIndex==3){
        NSString *timeStr=bloodTimeArray[section];
        for (TCBloodModel *model in bloodRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
    
    }else if (selectIndex==4){
        NSString *timeStr=glycosylateTimeArray[section];
        for (TCGlycosylateModel *model in glycosylateRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
    
    }else{
        NSString *timeStr=examinationTimeArray[section];
        for (TCExaminationModel *model in examinationRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }

    }
    return tempList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCHistoryRecordCell";
    if (selectIndex==0) {
        TCSuagrHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCSuagrHistoryCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=sugarTimeArray[indexPath.section];
        for (TCSugarModel *model in sugarRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measurement_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }

        TCSugarModel *sugar=tempList[indexPath.row];
        [cell cellDisplayWithSugar:sugar];
        return cell;
    }else if (selectIndex==1){
        TCDietHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCDietHistoryCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=dietTimeArray[indexPath.section];
        for (TCFoodRecordModel *model in dietRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCFoodRecordModel *diet=tempList[indexPath.row];
        [cell cellDisplayWithModel:diet];
        return cell;
    }else if (selectIndex==2){
        TCSportHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCSportHistoryCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=sportTimeArray[indexPath.section];
        for (TCSportRecordModel *model in sportRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCSportRecordModel *sport=tempList[indexPath.row];
        [cell cellDisplayWithModel:sport];
        
        return cell;
    }else if (selectIndex==3){
        TCBloodHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCBloodHistoryCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=bloodTimeArray[indexPath.section];
        for (TCBloodModel *model in bloodRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCBloodModel *blood=tempList[indexPath.row];
        [cell cellBloodHsitoryModel:blood];
        
        return cell;
    
    }else if (selectIndex==4){
        TCGlyHistoryTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCGlyHistoryTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=glycosylateTimeArray[indexPath.section];
        for (TCGlycosylateModel *model in glycosylateRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCGlycosylateModel *glycosylate=tempList[indexPath.row];
        [cell cellGlycosylateHsitoryModel:glycosylate];
        
        return cell;
    }else{
        TCExamteHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCExamteHistoryCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=examinationTimeArray[indexPath.section];
        for (TCExaminationModel *model in examinationRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCExaminationModel *examination=tempList[indexPath.row];
        [cell cellExamteHsitoryModel:examination];
        
        return cell;

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-01-04"];
#endif
    
    NSArray *mobArr = @[@"102_002020",@"102_002022",@"102_002024",@"102_002026",@"102_002028",@"102_002030"];
    [MobClick event:mobArr[selectIndex]];
    
    if (selectIndex==0) {
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=sugarTimeArray[indexPath.section];
        for (TCSugarModel *model in sugarRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measurement_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        
        TCSugarModel *sugar=tempList[indexPath.row];
        TCRecordSugarViewController *recordSugarVC=[[TCRecordSugarViewController alloc] init];
        recordSugarVC.sugarModel=sugar;
        recordSugarVC.way = [sugar.way integerValue];
        [self.navigationController pushViewController:recordSugarVC animated:YES];
    }else if (selectIndex==1){
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=dietTimeArray[indexPath.section];
        for (TCFoodRecordModel *model in dietRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCFoodRecordModel *diet=tempList[indexPath.row];
        
        TCRecordDietViewController *dietVC=[[TCRecordDietViewController alloc] init];
        [TCHelper sharedTCHelper].isHistoryDiet=YES;
        dietVC.foodRecordModel=diet;
        [self.navigationController pushViewController:dietVC animated:YES];
    }else if (selectIndex==2){
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=sportTimeArray[indexPath.section];
        for (TCSportRecordModel *model in sportRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCSportRecordModel *sport=tempList[indexPath.row];
        
        TCRecordSportViewController *sportVC=[[TCRecordSportViewController alloc] init];
        sportVC.sportModel=sport;
        [self.navigationController pushViewController:sportVC animated:YES];
    }else if (selectIndex==3){
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=bloodTimeArray[indexPath.section];
        for (TCBloodModel *model in bloodRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCBloodModel *sport=tempList[indexPath.row];
        
        TCAddBloodViewController *sportVC=[[TCAddBloodViewController alloc] init];
        sportVC.bloodModel=sport;
        [self.navigationController pushViewController:sportVC animated:YES];

    
    }else if (selectIndex==4){
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=glycosylateTimeArray[indexPath.section];
        for (TCGlycosylateModel *model in glycosylateRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCGlycosylateModel *glycosylate=tempList[indexPath.row];
        
        TCPertainViewController *pertainVC=[[TCPertainViewController alloc] init];
        pertainVC.pertainModel=glycosylate;
        [self.navigationController pushViewController:pertainVC animated:YES];

    
    }else{
        NSMutableArray *tempList=[[NSMutableArray alloc] init];
        NSString *timeStr=examinationTimeArray[indexPath.section];
        for (TCExaminationModel *model in examinationRecordsArray) {
            NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd"];
            if ([timeStr isEqualToString:timeKey]) {
                [tempList addObject:model];
            }
        }
        TCExaminationModel *examination=tempList[indexPath.row];
        
        TCCheckListViewController *checkListViewVC=[[TCCheckListViewController alloc] init];
        checkListViewVC.checkListModel=examination;
        [self.navigationController pushViewController:checkListViewVC animated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *timeStr=nil;
    if (selectIndex==0) {
        timeStr=sugarTimeArray[section];
    }else if (selectIndex==1){
        timeStr=dietTimeArray[section];
    }else if (selectIndex==2){
        timeStr=sportTimeArray[section];
    }else if (selectIndex==3){
        timeStr=bloodTimeArray[section];
    }else if (selectIndex==4){
        timeStr=glycosylateTimeArray[section];
    }else{
        timeStr=examinationTimeArray[section];
    }
    return timeStr;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark -- Custom Methods
#pragma mark  ClickViewGroupDelegate
-(void)foodHistoryMenuView:(TCHistoryMenuView *)menuView actionWithIndex:(NSInteger)index{
    NSArray *mobArr = @[@"102_002019",@"102_002021",@"102_002023",@"102_002025",@"102_002027",@"102_002029"];
    [MobClick event:mobArr[selectIndex]];

    if (index==0) {
        [[TCHelper sharedTCHelper] loginClick:@"005-01-07:血糖"];
    }else if (index==2){
        [[TCHelper sharedTCHelper] loginClick:@"005-01-07:运动"];
    }
    selectIndex=index;
    if (selectIndex==0) {
        if (!isBloodHistoryReload) {
           [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=sugarRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=sugarRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
    }else if (selectIndex==1){
        if (!isDietHistoryReload) {
           [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=dietRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=dietRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
    }else if(selectIndex==2){
        if (!isSportsHistoryReload) {
             [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=sportRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=sportRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
        
    }else if (selectIndex==3){
    
        if (!isSugarHistoryReload) {
            [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=bloodRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=bloodRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
    }else if (selectIndex==4){
        if (!isGlycosylateHistoryReload) {
            [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=glycosylateRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=glycosylateRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
    }else{
        if (!isExaminationHistoryReload) {
            [self loadNewRecordData];
        }else{
            self.recordBlankView.hidden=examinationRecordsArray.count>0;
            self.recordsTableView.mj_footer.hidden=examinationRecordsArray.count%20<20;
            [self.recordsTableView reloadData];
        }
    }
}

#pragma mark -- Event Response
-(void)swipRecordTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex+1>cateArray.count) {
            selectIndex=cateArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectIndex--;
        if (selectIndex<0) {
            selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in _itemGroupView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.itemGroupView changeHistoryViewWithButton:btn];
}

#pragma mark -- Private Methods
#pragma mark  选择对应标签
-(void)jumpIntoSelectedItem{
    NSInteger index=[cateArray indexOfObject:self.typeStr];
    UIButton *btn;
    for (UIView  *view in _itemGroupView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)index+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.itemGroupView changeHistoryViewWithButton:btn];
}

#pragma mark 加载最新记录
-(void)loadNewRecordData{
    if (selectIndex==0) {
        bloodPage=1;
        
        [self loadBloodSugarRecordsData];
    }else if (selectIndex==1){
        dietPage=1;
        [self loadDietRecordsData];
    }else if (selectIndex==2){
        sportPage=1;
        [self loadSportRecordsData];
    }else if (selectIndex==3){
        sugarPage=1;
        [self loadBloodRecordsData];
    }else if (selectIndex==4){
        glycosyPage=1;
        [self loadGlycosylateData];
        
    }else{
        examinaPage=1;
        [self loadExaminationData];
    
    }
}

#pragma mark 加载更多记录
-(void)loadMoreRecordData{
    if (selectIndex==0) {
        bloodPage++;
        [self loadBloodSugarRecordsData];
    }else if (selectIndex==1){
        dietPage++;
        [self loadDietRecordsData];
    }else if (selectIndex==2){
        sportPage++;
        [self loadSportRecordsData];
    }else if (selectIndex==3){
        sugarPage++;
        [self loadBloodRecordsData];
    }else if (selectIndex==4){
        glycosyPage++;
        [self loadGlycosylateData];
    }else{
        examinaPage++;
        [self loadExaminationData];
    }
}

#pragma mark 加载血糖记录
-(void)loadBloodSugarRecordsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&output-way=3",(long)bloodPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordLists body:body success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCSugarModel *sugar=[[TCSugarModel alloc] init];
                [sugar setValues:dict];
                [tempArr addObject:sugar];
                
                NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:sugar.measurement_time format:@"yyyy-MM-dd"];
                [tempTimeArr addObject:timeStr];
            }
            
            weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
            if (bloodPage==1) {
                sugarRecordsArray=tempArr;
                sugarTimeArray=tempTimeArr;
                weakSelf.recordBlankView.hidden=sugarTimeArray.count>0?YES:NO;
            }else{
                [sugarRecordsArray addObjectsFromArray:tempArr];
                [sugarTimeArray addObjectsFromArray:tempTimeArr];
            }
            
            NSSet *set = [NSSet setWithArray:sugarTimeArray]; //去重
            NSArray *timeArr=[set allObjects];
            timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1]; //降序
            }];
            sugarTimeArray=[NSMutableArray arrayWithArray:timeArr];
        }else{
            sugarRecordsArray = [[NSMutableArray alloc] init];
            sugarTimeArray = [[NSMutableArray alloc] init];
            weakSelf.recordBlankView.hidden=sugarTimeArray.count>0?YES:NO;
        }
        isBloodHistoryReload=YES;
        [weakSelf.recordsTableView reloadData];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 加载饮食记录
-(void)loadDietRecordsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&output-way=3",(long)dietPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDietRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSArray *dietRecord=[result valueForKey:@"dietrecord"];
            if (kIsArray(dietRecord)) {
                
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in dietRecord) {
                    TCFoodRecordModel *food=[[TCFoodRecordModel alloc] init];
                    [food setValues:dict];
                    [tempArr addObject:food];
                    
                    NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:food.feeding_time format:@"yyyy-MM-dd"];
                    [tempTimeArr addObject:timeStr];
                }
                
                weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
                if (dietPage==1) {
                    dietRecordsArray=tempArr;
                    dietTimeArray=tempTimeArr;
                    weakSelf.recordBlankView.hidden=dietTimeArray.count>0?YES:NO;
                }else{
                    [dietRecordsArray addObjectsFromArray:tempArr];
                    [dietTimeArray addObjectsFromArray:tempTimeArr];
                }
                
                NSSet *set = [NSSet setWithArray:dietTimeArray];  //去重
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                dietTimeArray=[NSMutableArray arrayWithArray:timeArr];
            }
            
            isDietHistoryReload=YES;
            [weakSelf.recordsTableView reloadData];
            [weakSelf.recordsTableView.mj_header endRefreshing];
            [weakSelf.recordsTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    }];
}

#pragma mark 加载运动记录
-(void)loadSportRecordsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&output-way=3",(long)sportPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSArray *sportRecord=[result valueForKey:@"motionrecord"];
            if (kIsArray(sportRecord)) {
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in sportRecord) {
                    TCSportRecordModel *sport=[[TCSportRecordModel alloc] init];
                    [sport setValues:dict];
                    [tempArr addObject:sport];
                    
                    NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:sport.motion_bigin_time format:@"yyyy-MM-dd"];
                    [tempTimeArr addObject:timeStr];
                }
                weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
                if (sportPage==1) {
                    sportRecordsArray=tempArr;
                    sportTimeArray=tempTimeArr;
                    weakSelf.recordBlankView.hidden=sportTimeArray.count>0?YES:NO;
                }else{
                    [sportRecordsArray addObjectsFromArray:tempArr];
                    [sportTimeArray addObjectsFromArray:tempTimeArr];
                }
                
                NSSet *set = [NSSet setWithArray:sportTimeArray];
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                sportTimeArray=[NSMutableArray arrayWithArray:timeArr];
            }
            isSportsHistoryReload=YES;
            [weakSelf.recordsTableView reloadData];
            [weakSelf.recordsTableView.mj_header endRefreshing];
            [weakSelf.recordsTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    }];
}
#pragma mark 加载血压记录
-(void)loadBloodRecordsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)sugarPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodLists body:body success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCBloodModel *bloodModel=[[TCBloodModel alloc] init];
                [bloodModel setValues:dict];
                [tempArr addObject:bloodModel];
                
                NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:bloodModel.measure_time format:@"yyyy-MM-dd"];
                [tempTimeArr addObject:timeStr];
            }
            
            weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
            if (sugarPage==1) {
                bloodRecordsArray=tempArr;
                bloodTimeArray=tempTimeArr;
                weakSelf.recordBlankView.hidden=bloodTimeArray.count>0?YES:NO;
            }else{
                [bloodRecordsArray addObjectsFromArray:tempArr];
                [bloodTimeArray addObjectsFromArray:tempTimeArr];
            }
            
            NSSet *set = [NSSet setWithArray:bloodTimeArray]; //去重
            NSArray *timeArr=[set allObjects];
            timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1]; //降序
            }];
            bloodTimeArray=[NSMutableArray arrayWithArray:timeArr];
        }else{
            bloodRecordsArray = [[NSMutableArray alloc] init];
            bloodTimeArray = [[NSMutableArray alloc] init];
            weakSelf.recordBlankView.hidden=bloodTimeArray.count>0?YES:NO;
        }
        isSugarHistoryReload=YES;
        [weakSelf.recordsTableView reloadData];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];

    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    }];


}
#pragma mark -- 加载糖化血红蛋白记录
- (void)loadGlycosylateData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"%@?page_num=%ld&page_size=20",kGlycosylatedLists,(long)glycosyPage];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:body success:^(id json) {
        
            NSArray *bloodRecord=[json valueForKey:@"result"];
            if (kIsArray(bloodRecord)) {
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in bloodRecord) {
                    TCGlycosylateModel *sport=[[TCGlycosylateModel alloc] init];
                    [sport setValues:dict];
                    [tempArr addObject:sport];
                    
                    NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:sport.measure_time format:@"yyyy-MM-dd"];
                    [tempTimeArr addObject:timeStr];
                }
                weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
                if (sportPage==1) {
                    glycosylateRecordsArray=tempArr;
                    glycosylateTimeArray=tempTimeArr;
                    weakSelf.recordBlankView.hidden=glycosylateTimeArray.count>0?YES:NO;
                }else{
                    [glycosylateRecordsArray addObjectsFromArray:tempArr];
                    [glycosylateTimeArray addObjectsFromArray:tempTimeArr];
                }
                
                NSSet *set = [NSSet setWithArray:glycosylateTimeArray];
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                glycosylateTimeArray=[NSMutableArray arrayWithArray:timeArr];
            }
            
            isGlycosylateHistoryReload=YES;
            [weakSelf.recordsTableView reloadData];
            [weakSelf.recordsTableView.mj_header endRefreshing];
            [weakSelf.recordsTableView.mj_footer endRefreshing];
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    }];


}
#pragma mark -- 加载检查表
- (void)loadExaminationData{
    
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"%@?page_num=%ld&page_size=20",kExaminationSheetLists,(long)examinaPage];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:body success:^(id json) {
        
        NSArray *examinaRecord=[json valueForKey:@"result"];
        if (kIsArray(examinaRecord)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in examinaRecord) {
                TCExaminationModel *sport=[[TCExaminationModel alloc] init];
                [sport setValues:dict];
                [tempArr addObject:sport];
                
                NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:sport.add_time format:@"yyyy-MM-dd"];
                [tempTimeArr addObject:timeStr];
            }
            weakSelf.recordsTableView.mj_footer.hidden=tempArr.count<20;
            if (examinaPage==1) {
                examinationRecordsArray=tempArr;
                examinationTimeArray=tempTimeArr;
                weakSelf.recordBlankView.hidden=examinationTimeArray.count>0?YES:NO;
            }else{
                [examinationRecordsArray addObjectsFromArray:tempArr];
                [examinationTimeArray addObjectsFromArray:tempTimeArr];
            }
            
            NSSet *set = [NSSet setWithArray:examinationTimeArray];
            NSArray *timeArr=[set allObjects];
            timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1]; //降序
            }];
            examinationTimeArray=[NSMutableArray arrayWithArray:timeArr];
        }
        
        isExaminationHistoryReload=YES;
        [weakSelf.recordsTableView reloadData];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.recordsTableView.mj_header endRefreshing];
        [weakSelf.recordsTableView.mj_footer endRefreshing];
    }];

    
}
#pragma mark -- Setters and Getters
#pragma mark  标签栏
-(TCHistoryMenuView *)itemGroupView{
    if (_itemGroupView==nil) {
        _itemGroupView=[[TCHistoryMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 40)];
        _itemGroupView.delegate =self;
        _itemGroupView.foodMenusArray =[cateArray mutableCopy];
        _itemGroupView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth, 1)];
        lab.backgroundColor=kLineColor;
        [_itemGroupView addSubview:lab];
    }
    return _itemGroupView;
}

#pragma mark  记录列表
-(UITableView *)recordsTableView{
    if (_recordsTableView==nil) {
        _recordsTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.itemGroupView.bottom, kScreenWidth, kScreenHeight-self.itemGroupView.bottom) style:UITableViewStyleGrouped];
        _recordsTableView.dataSource=self;
        _recordsTableView.delegate=self;
        _recordsTableView.showsVerticalScrollIndicator=NO;
        _recordsTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _recordsTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _recordsTableView.mj_footer = footer;
        
        _recordsTableView.mj_footer.hidden=YES;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_recordsTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_recordsTableView addGestureRecognizer:swipGestureRight];

    }
    return _recordsTableView;
}

#pragma mark 无数据空白页
-(TCBlankView *)recordBlankView{
    if (_recordBlankView==nil) {
        _recordBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, self.itemGroupView.bottom, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无历史记录"];
    }
    return _recordBlankView;
}


@end
