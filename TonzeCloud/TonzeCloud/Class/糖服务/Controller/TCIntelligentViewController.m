//
//  TCIntelligentViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/27.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCIntelligentViewController.h"
#import "TRRTuringRequestManager.h"
#import "TCWeChatTableViewCell.h"
#import "TCMessageModel.h"
#import "SVProgressHUD.h"
#import "BackScrollView.h"
#import "IQKeyboardManager.h"

#define LEFT_WITH   (kScreenWidth>750?55:52.5)
#define RIGHT_WITH  (kScreenWidth>750?89:73)

@interface TCIntelligentViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>{
    UITextView                 *inputTextView;   //输入框
    TRRTuringAPIConfig         *apiConfig;
    TRRTuringRequestManager    *apiRequest;
    NSMutableArray             *chatListArray;
    NSMutableArray             *questionArray;
}

@property (nonatomic,strong)UITableView      *chatTableView;   //聊天
@property (nonatomic,strong)UIView           *headChatView;    
@property (nonatomic,strong)UIView           *bottomView;      //底部输入视图

@end

@implementation TCIntelligentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"智能咨询";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    apiConfig=[[TRRTuringAPIConfig alloc] initWithAPIKey:kTuringAPIKey];
    apiRequest=[[TRRTuringRequestManager alloc] initWithConfig:apiConfig];
//    questionArray=@[@"什么是糖尿病？",@"糖尿病如何预防？",@"糖尿病饮食应该如何注意？"];
    questionArray = [[NSMutableArray alloc] init];
    
    chatListArray=[[NSMutableArray alloc] init];
    
    [self initIntelligentView];
    [self requestIntelligetnData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-02" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [IQKeyboardManager sharedManager].enable = NO;

    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-02" type:2];
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return chatListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCWeChatTableViewCell *cell=[[TCWeChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    TCMessageModel *message=chatListArray[indexPath.row];
    [cell wechatCellDisplayWithMessage:message];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCMessageModel *message=chatListArray[indexPath.row];
    return [TCWeChatTableViewCell wechatCellRowHeightWithMessage:message];
}

#pragma mark -- Event Response
#pragma mark 发送消息
-(void)sendMessageAction:(UIButton *)sender{
    if (!kIsEmptyString(inputTextView.text)) {
        NSDictionary *dict = @{@"question" : inputTextView.text};
        [MobClick event:@"103_002006" attributes:dict];

        [self sendActionWithMessage:inputTextView.text];
    }
}

#pragma mark 选择推荐问题
-(void)didSelectedValueForGesture:(UITapGestureRecognizer *)gesture{
    NSInteger index=gesture.view.tag;
    MyLog(@"选择问题：%@",questionArray[index]);
    
    [MobClick event:@"103_002005" ];
    
    [self sendActionWithMessage:questionArray[index]];
}

#pragma mark 键盘弹出
-(void)chatKeyboardWillShow:(NSNotification *)notifi{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 定义好动作
    
    CGFloat chatContentH=self.chatTableView.contentSize.height;
    CGFloat chatH=self.chatTableView.frame.size.height;
    if (chatContentH<chatH) {
        if (chatContentH+keyBoardHeight+50>kRootViewHeight) {
            self.chatTableView.frame=CGRectMake(0, self.chatTableView.top, kScreenWidth, chatContentH-20);
        }else{
            self.chatTableView.frame=CGRectMake(0, self.chatTableView.top, kScreenWidth, kRootViewHeight-keyBoardHeight-50);
        }
    }else{
        self.chatTableView.frame=CGRectMake(0, self.chatTableView.top, kScreenWidth, kRootViewHeight-keyBoardHeight-50);
    }
    if (chatListArray.count>0) {
         [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chatListArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    void (^animation)(void) = ^void(void) {
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -keyBoardHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark  隐藏键盘
-(void)chatKeyboardWillHide:(NSNotification *)notifi{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    self.chatTableView.frame=CGRectMake(0, self.chatTableView.top, kScreenWidth, kRootViewHeight-50);
    void (^animation)(void) = ^void(void) {
        self.bottomView.transform = CGAffineTransformIdentity;
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark  点击空白事件
-(void)tapGestureHideKeyboardAction{
    [inputTextView resignFirstResponder];
    CGRect inputViewFrame=self.bottomView.frame;
    inputViewFrame.origin.y = kScreenHeight-50;
    self.bottomView.frame = inputViewFrame;
}

#pragma mark touch事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [inputTextView resignFirstResponder];
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -- 获取智能咨询问题
- (void)requestIntelligetnData{

    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kIntelligentList body:@"" success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        if (kIsArray(result)) {
            for (int i=0; i<result.count; i++) {
                
                NSString *title = [result[i] objectForKey:@"title"];
                [questionArray addObject:title];
            }
        }
        self.chatTableView.tableHeaderView=self.headChatView;
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- Private Methods
#pragma mark 发送消息
-(void)sendActionWithMessage:(NSString *)messageStr{
    //添加用户消息
    TCMessageModel *userMessage=[[TCMessageModel alloc] init];
    userMessage.messageText=messageStr;
    userMessage.messageSenderType=MessageSenderTypeUser;
    userMessage.messageType=MessageTypeText;
    userMessage.showMessageTime=NO;
    [chatListArray addObject:userMessage];
    
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chatListArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    NSString *tempStr=messageStr;
    inputTextView.text=@"";
    
    __weak typeof(self) weakSelf=self;
    [SVProgressHUD show];
    [apiConfig request_UserIDwithSuccessBlock:^(NSString *result) {
        MyLog(@"result=%@",result);
        [apiRequest request_OpenAPIWithInfo:tempStr successBlock:^(NSDictionary *dict) {
            MyLog(@"dict:%@",dict);
            [SVProgressHUD dismiss];
            
            NSString *textStr=[dict valueForKey:@"text"];
            
            TCMessageModel *turingMessage=[[TCMessageModel alloc] init];
            turingMessage.messageText=textStr;
            turingMessage.messageSenderType=MessageSenderTypeTuring;
            turingMessage.messageType=MessageTypeText;
            turingMessage.showMessageTime=NO;
            [chatListArray addObject:turingMessage];
            
            [weakSelf.chatTableView reloadData];
            [weakSelf.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chatListArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
            [SVProgressHUD dismiss];
            MyLog(@"error -info:%@",infoStr);
        }];
        
    } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
        [SVProgressHUD dismiss];
        MyLog(@"error -info:%@",infoStr);
    }];
}

#pragma mark 初始化视图
-(void)initIntelligentView{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHideKeyboardAction)];
    [self.view addGestureRecognizer:tap];
    
    
    [self.view addSubview:self.chatTableView];
    [self.view addSubview:self.bottomView];
}

#pragma mark -- Setters and Getters
#pragma mark 聊天界面
-(UITableView *)chatTableView{
    if (!_chatTableView) {
        _chatTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-50) style:UITableViewStylePlain];
        _chatTableView.delegate=self;
        _chatTableView.dataSource=self;
        _chatTableView.showsVerticalScrollIndicator=NO;
        _chatTableView.tableFooterView=[[UIView alloc] init];
        _chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _chatTableView.backgroundColor=[UIColor clearColor];
    }
    return _chatTableView;
}

#pragma mark 头部视图
-(UIView *)headChatView{
    if (!_headChatView) {
        _headChatView=[[UIView alloc] initWithFrame:CGRectZero];
        
        //开始语
        UIImageView *headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        headImageView.image=[UIImage imageNamed:@"ic_IM_head_kefu"];
        [_headChatView addSubview:headImageView];
        
        NSString *contentText=@"您好，我是糖糖，可以帮你解答一些简单的糖尿病问题哦~";
        UIImageView *bgImageView =[[UIImageView alloc] initWithFrame:CGRectZero];
        CGFloat maxWith=kScreenWidth-LEFT_WITH-RIGHT_WITH;
        CGSize contentSize=[contentText boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:16]];
        bgImageView.frame=CGRectMake(LEFT_WITH, 10, contentSize.width+20, contentSize.height+20);
        bgImageView.image=[[UIImage imageNamed:@"wechatback1"] stretchableImageWithLeftCapWidth:8 topCapHeight:24];
        [_headChatView addSubview:bgImageView];
        
        UILabel *contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(LEFT_WITH+12, 15, contentSize.width, contentSize.height)];
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        contentLabel.font=[UIFont systemFontOfSize:16];
        contentLabel.textColor=[UIColor blackColor];
        contentLabel.text=contentText;
        [_headChatView addSubview:contentLabel];
        
        //常见问题
        UIImageView *headImageView2=[[UIImageView alloc] initWithFrame:CGRectMake(10,bgImageView.bottom+10, 40, 40)];
        headImageView2.image=[UIImage imageNamed:@"ic_IM_head_kefu"];
        [_headChatView addSubview:headImageView2];
        
        UIImageView *bgImageView2 =[[UIImageView alloc] initWithFrame:CGRectZero];
        bgImageView2.image=[[UIImage imageNamed:@"wechatback1"] stretchableImageWithLeftCapWidth:8 topCapHeight:24];
        [_headChatView addSubview:bgImageView2];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(LEFT_WITH+12, bgImageView.bottom+15, maxWith, 30)];
        titleLab.text=@"糖友们都问过这些问题：";
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textColor=[UIColor blackColor];
        [_headChatView addSubview:titleLab];
        
        CGFloat  totalLabH=0.0;
        for (NSInteger i=0;i<questionArray.count; i++) {
            UILabel *vaueLab=[[UILabel alloc] initWithFrame:CGRectZero];
            vaueLab.font=[UIFont systemFontOfSize:16];
            vaueLab.textColor=[UIColor blueColor];
            vaueLab.text=questionArray[i];
            vaueLab.numberOfLines=0;
            vaueLab.userInteractionEnabled=YES;
            vaueLab.tag=i;
            CGFloat laH=[vaueLab.text boundingRectWithSize:CGSizeMake(maxWith-10, CGFLOAT_MAX) withTextFont:vaueLab.font].height;
            vaueLab.frame=CGRectMake(titleLab.left, titleLab.bottom+totalLabH, maxWith-10, laH+10);
            [_headChatView addSubview:vaueLab];
            
            totalLabH+=laH+10;
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectedValueForGesture:)];
            [vaueLab addGestureRecognizer:tap];
        }
        
        bgImageView2.frame=CGRectMake(LEFT_WITH, bgImageView.bottom+10, maxWith, totalLabH+40);
    
        _headChatView.frame=CGRectMake(0, 0, kScreenWidth, titleLab.bottom+totalLabH+10);
        
    }
    return _headChatView;
}

#pragma mark 输入视图
-(UIView *)bottomView{
    if (_bottomView==nil) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-KTabbarSafeBottomMargin-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        inputTextView=[[UITextView alloc] initWithFrame:CGRectMake(5, 5, kScreenWidth-100, 40)];
        inputTextView.layer.borderWidth=1.0;
        inputTextView.layer.borderColor=kLineColor.CGColor;
        inputTextView.layer.cornerRadius=5.0;
        inputTextView.clipsToBounds=YES;
        inputTextView.delegate=self;
        inputTextView.inputAccessoryView = [[UIView alloc] init];
        inputTextView.font=[UIFont systemFontOfSize:16];
        [_bottomView addSubview:inputTextView];
        
        UIButton *sendBtn=[[UIButton alloc] initWithFrame:CGRectMake(inputTextView.right+5, 5, 85, 40)];
        sendBtn.backgroundColor=kSystemColor;
        sendBtn.layer.cornerRadius=5.0;
        sendBtn.clipsToBounds=YES;
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(sendMessageAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:sendBtn];
    }
    return _bottomView;
}
@end
