//
//  TCHealthQusetionViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthQusetionViewController.h"
#import "TCHealthQuestionModel.h"
#import "TCHealthQuestionTableViewCell.h"
#import "TCScoreModel.h"
#import "TCHealthTestViewController.h"
#import "TCHealthQuestionResultViewController.h"

@interface TCHealthQusetionViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSInteger seletedPage;
    NSMutableArray *seletedArray;
    NSMutableArray *healthContentArray;
    NSMutableArray *scoreArray;
    NSMutableArray *answerArray;
    NSMutableArray *questionArray;
    
    NSMutableDictionary *scoreDict;
    
    BOOL             isAnswer;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bgView;
/// 题目内容
@property (nonatomic, copy) UILabel *contentLable;

@end


@implementation TCHealthQusetionViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.baseTitle = @"健康自测";
    
    seletedPage=0;
    isAnswer = NO;
    seletedArray = [[NSMutableArray alloc] init];
    healthContentArray = [[NSMutableArray alloc] init];
    scoreArray = [[NSMutableArray alloc] init];
    scoreDict = [[NSMutableDictionary alloc] init];
    questionArray = [[NSMutableArray alloc] init];
    answerArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.bgView];
    [self requestHealthDetailData];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isHealthScore == YES) {
        [TCHelper sharedTCHelper].isHealthScore =  NO;
        isAnswer= NO;
        seletedPage=0;
        seletedArray = [[NSMutableArray alloc] init];
        [self loadHealthListData];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-11-01" type:1];
#endif
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-11-01" type:2];
#endif
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (healthContentArray.count>0) {
        TCHealthQuestionModel *contentModel = healthContentArray[seletedPage==healthContentArray.count?seletedPage-1:seletedPage];
        NSArray *dict = contentModel.answer;
        return dict.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TCHealthQuestionTableViewCell";
    TCHealthQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TCHealthQuestionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TCHealthQuestionModel *contentModel = healthContentArray[seletedPage==healthContentArray.count?seletedPage-1:seletedPage];
    NSArray *dict = contentModel.answer;
    cell.optionLable.text = [dict[indexPath.row] objectForKey:@"name"];
    
    if (seletedArray.count>seletedPage) {
        if (indexPath.row+1 == [seletedArray[seletedPage] integerValue]) {
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_pick"];
        }else{
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
        }
    }else if(seletedPage== healthContentArray.count){
        if (indexPath.row+1 == [seletedArray[seletedPage-1] integerValue]) {
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_pick"];
        }else{
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
        }
    }
    else {
        cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _bgView.hidden = NO;
    [self performSelector:@selector(initContentView) withObject:nil afterDelay:0.3];
    TCHealthQuestionModel *contentModel = healthContentArray[seletedPage==healthContentArray.count?seletedPage-1:seletedPage];
    NSArray *dict = contentModel.answer;
    if (seletedArray.count>0) {
        if (seletedArray.count==seletedPage) {
            isAnswer = YES;
            [seletedArray replaceObjectAtIndex:seletedPage-1 withObject:[NSString stringWithFormat:@"%ld",indexPath.row+1]];
            [questionArray replaceObjectAtIndex:seletedPage-1 withObject:[NSString stringWithFormat:@"%ld",contentModel.assess_id]];
            [answerArray replaceObjectAtIndex:seletedPage-1 withObject:[NSString stringWithFormat:@"%@",[dict[indexPath.row] objectForKey:@"assess_id"]]];

        } else {
            if (seletedPage==seletedArray.count-1) {
                isAnswer = YES;
            }
            [seletedArray replaceObjectAtIndex:seletedPage withObject:[NSString stringWithFormat:@"%ld",indexPath.row+1]];
            [questionArray replaceObjectAtIndex:seletedPage withObject:[NSString stringWithFormat:@"%ld",contentModel.assess_id]];
            [answerArray replaceObjectAtIndex:seletedPage withObject:[NSString stringWithFormat:@"%@",[dict[indexPath.row] objectForKey:@"assess_id"]]];

        }
    }
    [self.tableView reloadData];
}
#pragma mark -- 延迟0.3秒执行
- (void)initContentView{
    _bgView.hidden = YES;
    if (seletedPage<healthContentArray.count) {
        seletedPage++;
    }
    if (seletedPage<healthContentArray.count) {
        //创建CATransition对象
        CATransition *animation = [CATransition animation];
        //设置时间
        animation.duration = 0.2f;
        //设置类型
        animation.type = kCATransitionMoveIn;
        //设置方向
        animation.subtype = kCATransitionFromRight;
        //设置运动速度变化
        animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
        
        [self.tableView.layer addAnimation:animation forKey:@"animation"];
        
    }
    [self.tableView reloadData];
    
}
#pragma mark -- TabeleHeaderView
- (UIView *)tableViewHeaderView{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, 300)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:24];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.text = self.titleStr;
    titleLabel.numberOfLines = 2;
    CGSize size = [titleLabel.text sizeWithLabelWidth:kScreenWidth-20 font:[UIFont systemFontOfSize:24]];
    titleLabel.frame = CGRectMake(15, 20, kScreenWidth-30, size.height>59?59:size.height);
    [headerView addSubview:titleLabel];
    
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
    centerLabel.font = [UIFont systemFontOfSize:17];
    centerLabel.text =[NSString stringWithFormat:@"%ld/%ld题",seletedPage+1>healthContentArray.count?seletedPage:seletedPage+1,healthContentArray.count];
    CGSize centerSize = [centerLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:17]];
    centerLabel.frame = CGRectMake((kScreenWidth-centerSize.width)/2, titleLabel.bottom+10, centerSize.width, 20);
    [headerView addSubview:centerLabel];
    
    for (int i=0; i<2; i++) {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+(kScreenWidth/2+centerSize.width/2)*i, centerLabel.top+9.5,(kScreenWidth-centerSize.width)/2-30, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0x959595"];
        [headerView addSubview:lineLabel];
    }
    
    NSString *contentText = nil;
    if (healthContentArray.count>0) {
        if (seletedPage == healthContentArray.count) {
            TCHealthQuestionModel *contentModel = healthContentArray[seletedPage-1];
            contentText  = contentModel.name;
        }
        else{
            TCHealthQuestionModel *contentModel = healthContentArray[seletedPage];
            contentText  = contentModel.name;
        }
    }
    CGSize contentTextSize = [contentText boundingRectWithSize:CGSizeMake(kScreenWidth - 30, 300) withTextFont:[UIFont systemFontOfSize:20]];
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(15, centerLabel.bottom+15, contentTextSize.width, contentTextSize.height>48?48:contentTextSize.height)];
    _contentLable.textAlignment = NSTextAlignmentLeft;
    _contentLable.text = contentText;
    _contentLable.font = [UIFont systemFontOfSize:20];
    _contentLable.numberOfLines = 2;
    _contentLable.textColor = [UIColor colorWithHexString:@"0x666666"];
    [headerView addSubview:_contentLable];
    headerView.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, _contentLable.bottom + 30);
    
    return headerView;
}
#pragma mark -- 重新加载健康内容
- (void)loadHealthListData{
    for (int i=0; i<healthContentArray.count; i++) {
        [seletedArray addObject:@"0"];
    }
    healthContentArray = [NSMutableArray arrayWithArray:[TCHelper sharedTCHelper].healthList];
    scoreArray = [NSMutableArray arrayWithArray:[TCHelper sharedTCHelper].healthResult];
    [self.tableView reloadData];
    
}
#pragma mark -- 获取健康评估内容
- (void)requestHealthDetailData{
    NSString *body = [NSString stringWithFormat:@"assess_id=%ld",self.assess_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAssessindexRead body:body success:^(id json) {
        NSDictionary *dict =[json objectForKey:@"result"];
        NSArray *array = [dict objectForKey:@"question"];
        NSArray *scoreStand = [dict objectForKey:@"rules"];
        NSMutableArray *healthArray = [[NSMutableArray alloc] init];
        NSMutableArray *healthhArray = [[NSMutableArray alloc] init];
        
        for (int i=0; i<array.count; i++) {
            TCHealthQuestionModel *contentModel = [[TCHealthQuestionModel alloc] init];
            [contentModel setValues:array[i]];
            [healthhArray addObject:contentModel];
        }
        healthContentArray = healthhArray;
        [TCHelper sharedTCHelper].healthList = healthContentArray;
        
        for (int i=0; i<scoreStand.count; i++) {
            TCScoreModel *scoreModel = [[TCScoreModel alloc] init];
            [scoreModel setValues:scoreStand[i]];
            [healthArray addObject:scoreModel];
        }
        scoreArray = healthArray;
        [TCHelper sharedTCHelper].healthResult = scoreArray;
        for (int i=0; i<healthContentArray.count; i++) {
            [seletedArray addObject:@"0"];
            [questionArray addObject:@"0"];
            [answerArray addObject:@"0"];
        }
        [self.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- TableFooterView
- (UIView *)tableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0,  0, kScreenWidth, 200)];
    
    UIButton *determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    determineBtn.frame =CGRectMake((kScreenWidth-160)/2, 20,160, 44);
    determineBtn.tag = 1000;
    [determineBtn setTitle:@"上一题" forState:UIControlStateNormal];
    determineBtn.layer.cornerRadius = 4;
    [determineBtn.layer setBorderWidth:1]; //设置边界宽度
    determineBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [determineBtn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){98.0/256, 98.0/256, 98.0/256,1 });
    [determineBtn.layer setBorderColor:colorref];//边框颜色
    [determineBtn addTarget:self action:@selector(determineClick:) forControlEvents:UIControlEventTouchUpInside];
    determineBtn.hidden = YES;
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(colorref);
    [footerView addSubview:determineBtn];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame =CGRectMake((kScreenWidth-160)/2, determineBtn.bottom+20,160, 44);
    nextButton.tag = 1001;
    nextButton.layer.cornerRadius = 4;
    [nextButton addTarget:self action:@selector(determineClick:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.backgroundColor = kbgBtnColor;
    [nextButton setTitle:@"提交" forState:UIControlStateNormal];
    nextButton.hidden = YES;
    [footerView addSubview:nextButton];
    
    if (healthContentArray.count>0) {
        determineBtn.titleLabel.textColor = [UIColor whiteColor];
        determineBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        determineBtn.layer.cornerRadius = 5;
        if (seletedPage==healthContentArray.count||seletedPage==healthContentArray.count-1) {
            determineBtn.hidden = NO;
            nextButton.hidden =NO;
        }else if (seletedPage==0){
            determineBtn.hidden = YES;
            nextButton.hidden =YES;
        }else{
            determineBtn.hidden = NO;
            nextButton.hidden =YES;
        }
    }
    
    return footerView;
}
#pragma mark -- Action
/* 上一题点击 */
- (void)determineClick:(UIButton *)button{
    if (button.tag==1001) {
        if (isAnswer==NO) {
            [self.view makeToast:@"请选择答案" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        NSInteger num = 0;
        for (int i=0; i<healthContentArray.count; i++) {
            TCHealthQuestionModel *contentModel = healthContentArray[i];
            NSArray *dataArray = contentModel.answer;
            NSInteger page = [seletedArray[i] integerValue]-1;
            NSInteger value = [[dataArray[page>0?page:0] objectForKey:@"score"] integerValue];
            num = num+value;
            
        }
        NSString *contentString = nil;
        NSInteger answer_id = 0;
        for (int i=0; i<scoreArray.count; i++) {
            TCScoreModel *scoreModel = scoreArray[i];
            if (num>=scoreModel.begin_score&&num<=scoreModel.end_score) {
                contentString = scoreModel.brief;
                answer_id = scoreModel.assess_rules_id;
            }
        }
        NSMutableArray *dictArray = [[NSMutableArray alloc] init];
        for (int i=0; i<questionArray.count; i++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:questionArray[i] forKey:@"question_id"];
            [dict setValue:answerArray[i] forKey:@"anwser_id"];
            [dictArray addObject:dict];
        }
        NSString *paramsStr=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:dictArray];
        NSString *body = [NSString stringWithFormat:@"assess_id=%ld&answer_id=%ld&score=%ld&question_answer=%@",self.assess_id,answer_id,num,paramsStr];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAssessindexAdd_record body:body success:^(id json) {
            NSString *shareUrl =  [NSString stringWithFormat:@"%@/healthytest/index.html?answer_id=%ld",kShareUrl,answer_id];
            NSDictionary *dict = @{@"num":[NSString stringWithFormat:@"%ld",num],@"accs_id":[NSString stringWithFormat:@"%ld",self.assess_id],@"brief":contentString,@"share":shareUrl};
            [NSUserDefaultsInfos putKey:[NSString stringWithFormat:@"%ld",self.assess_id] anddict:dict];
            
            TCHealthQuestionResultViewController *resultVC = [[TCHealthQuestionResultViewController alloc] init];
            resultVC.index = self.assess_id;
            resultVC.titleStr = self.titleStr;
            resultVC.num = num;
            resultVC.brief = contentString;
            resultVC.imgUrl = self.imgUrl;
            resultVC.shareUrl = [NSString stringWithFormat:@"%@/healthytest/index.html?answer_id=%ld",kShareUrl,answer_id];
            [self.navigationController pushViewController:resultVC animated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

    }else{
        if (seletedPage==healthContentArray.count) {
            seletedPage = seletedPage-2;
        } else {
            seletedPage--;
        }
        //创建CATransition对象
        CATransition *animation = [CATransition animation];
        //设置时间
        animation.duration = 0.3f;
        //设置类型
        animation.type = kCATransitionMoveIn;
        //设置方向
        animation.subtype = kCATransitionFromLeft;
        //设置运动速度变化
        animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
        
        [self.tableView.layer addAnimation:animation forKey:@"animation"];
        
    }
    [self.tableView reloadData];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次测试？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[TCHealthTestViewController class]]) {
                TCHealthTestViewController *revise =(TCHealthTestViewController *)controller;
                [self.navigationController popToViewController:revise animated:YES];
            }
        }    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma  mark -- Getter-
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth,kRootViewHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = kBackgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    _tableView.tableHeaderView = [self tableViewHeaderView];
    _tableView.tableFooterView = [self tableFooterView];
    return _tableView;
}
- (UIView *)bgView{
    if (_bgView==nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.hidden = YES ;
    }
    return _bgView;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
