//
//  TCServiceEvaluateViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceEvaluateViewController.h"
#import "TggStarEvaluationView.h"
#import "BackScrollView.h"

@interface TCServiceEvaluateViewController ()<UITextViewDelegate>{
    NSInteger        score_1;
    NSInteger        score_2;
    NSInteger        score_3;
    UILabel          *promptLabel;
    UILabel          *countLabel;
}

@property (nonatomic,strong)BackScrollView  *backScrollView;
@property (nonatomic,strong)UIView          *rankView;
@property (nonatomic,strong)UITextView      *evaluateTextView;

@end

@implementation TCServiceEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"评价服务";
    self.rigthTitleName=@"提交";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    score_1=score_2=score_3=0;
    
    [self.view insertSubview:self.backScrollView atIndex:0];
    [self.backScrollView addSubview:self.rankView];
    [self.backScrollView addSubview:self.evaluateTextView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(evaluateKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(evaluateKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -- NSNotification
#pragma mark 键盘弹出
-(void)evaluateKeyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void(^animation)() = ^{
        if (self.evaluateTextView.top+40>keyBoardBounds.origin.y) {
            self.backScrollView.frame=CGRectMake(0, -(self.evaluateTextView.top+40-keyBoardBounds.origin.y), kScreenWidth, kRootViewHeight);
        }
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
    
}

#pragma mark  键盘退出
-(void)evaluateKeyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.backScrollView.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
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
    if (self.evaluateTextView.text.length==0) {
        if ([text isEqualToString:@""]) {//判断是否为删除键
            promptLabel.hidden=NO;//隐藏文字
        }else{
            promptLabel.hidden=YES;
        }
    }else{
        if (self.evaluateTextView.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {//判断是否为删除键
                promptLabel.hidden=NO;
            }else{//不是删除
                promptLabel.hidden=YES;
            }
        }else{//长度不为1时候
            promptLabel.hidden=YES;
        }
    }
    
    if ([@"\n" isEqualToString:text]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (textView==self.evaluateTextView) {
        if ([textView.text length]+text.length>100) {
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}

#pragma mark -- Event Response
#pragma mark 提交评价
-(void)rightButtonAction{
    if (kIsEmptyString(self.evaluateTextView.text)||score_1==0||score_2==0||score_3==0) {
        [self.view makeToast:@"评价信息不完整" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"order_id=%ld&attitude_score=%ld&speed_score=%ld&satisfied_score=%ld&msg=%@",(long)self.order_id,(long)score_1,(long)score_2,(long)score_3,_evaluateTextView.text];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddServiceEvaluate body:body success:^(id json) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [TCHelper sharedTCHelper].isReloadMyService=YES;
        [TCHelper sharedTCHelper].isReloadMyServiceDetail=YES;
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Getters
#pragma mark 根视图
-(BackScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView=[[BackScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    }
    return _backScrollView;
}

#pragma mark 评价等级
-(UIView *)rankView{
    if (!_rankView) {
        _rankView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        _rankView.backgroundColor=[UIColor whiteColor];
        
        NSArray *labs=[[NSArray alloc] initWithObjects:@"服务态度",@"回复速度",@"解决态度", nil];
        for (NSInteger i=0; i<labs.count; i++) {
            UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, 10+35*i, 80.0, 30.0)];
            lab.text=labs[i];
            lab.textColor=[UIColor colorWithHexString:@"#333333"];
            lab.font=[UIFont systemFontOfSize:15];
            [_rankView addSubview:lab];
        }
        
        // 服务态度
        TggStarEvaluationView *attitudeStarEvaView = [TggStarEvaluationView evaluationViewWithChooseStarBlock:^(NSUInteger count) {
            MyLog(@"服务态度 count:%ld",count);
            score_1=count;
        }];
        attitudeStarEvaView.frame = CGRectMake(100, 10, 150, 30);
        attitudeStarEvaView.starCount=0;
        attitudeStarEvaView.spacing=0.1;
        [_rankView addSubview:attitudeStarEvaView];
        
        // 回复速度
        TggStarEvaluationView *speedStarEvaView = [TggStarEvaluationView evaluationViewWithChooseStarBlock:^(NSUInteger count) {
            MyLog(@"回复速度 count:%ld",count);
            score_2=count;
        }];
        speedStarEvaView.frame = CGRectMake(100, 10+35, 150, 30);
        speedStarEvaView.starCount=0;
        speedStarEvaView.spacing=0.1;
        [_rankView addSubview:speedStarEvaView];
        
        // 解决态度
        TggStarEvaluationView *solveStarEvaView = [TggStarEvaluationView evaluationViewWithChooseStarBlock:^(NSUInteger count) {
            MyLog(@"解决态度 count:%ld",count);
            score_3=count;
        }];
        solveStarEvaView.frame = CGRectMake(100, 10+70, 150, 30);
        solveStarEvaView.starCount=0;
        solveStarEvaView.spacing=0.1;
        [_rankView addSubview:solveStarEvaView];
        
    }
    return _rankView;
}

#pragma mark 文字评价
-(UITextView *)evaluateTextView{
    if (!_evaluateTextView) {
        _evaluateTextView=[[UITextView alloc] initWithFrame:CGRectMake(0, self.rankView.bottom+10, kScreenWidth, 200)];
        _evaluateTextView.delegate=self;
        _evaluateTextView.backgroundColor=[UIColor whiteColor];
        _evaluateTextView.returnKeyType=UIReturnKeyDone;
        _evaluateTextView.font=[UIFont systemFontOfSize:16];
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, kScreenWidth-10, 20)];
        promptLabel.text = @"请评价几句。";
        promptLabel.font = [UIFont systemFontOfSize:16];
        promptLabel.textColor = [UIColor lightGrayColor];
        [_evaluateTextView addSubview:promptLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, _evaluateTextView.height-30, 80, 20)];
        countLabel.text = @"0/100";
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.font = [UIFont systemFontOfSize:14];
        [_evaluateTextView addSubview:countLabel];
        
    }
    return _evaluateTextView;
}

@end
