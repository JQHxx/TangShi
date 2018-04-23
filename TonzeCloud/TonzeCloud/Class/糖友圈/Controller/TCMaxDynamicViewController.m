//
//  TCMaxDynamicViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMaxDynamicViewController.h"
#import "TCMaxDynamicModel.h"
#import "TCMaxDynamicTableViewCell.h"
#import "TCReplyContentTableViewCell.h"
#import "TCMyDynamicViewController.h"
#import "TCCommentToolBar.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "TCDynamicDetailViewController.h"

@interface TCMaxDynamicViewController ()<UITableViewDelegate,TCCommentToolBarDelegate,UITableViewDataSource,linkReplyContentDelegate,linkCommentReplyDelegate>{

    NSMutableArray        *maxDynamicArr;
    TCBlankView           *blankView;
    NSDictionary          *head_comment;
    NSInteger             maxReplyPage;
    NSInteger             prant_id;
    NSInteger             newsid;
    NSInteger             comment_user_id;
    NSInteger             roletype;
    NSInteger             news_comment_id;
    NSInteger              isFace;
}

@property (nonatomic ,strong)UITableView         *maxDynamicTab;
@property (nonatomic ,strong)UIView              *bgView;
@property (nonatomic ,strong) TCCommentToolBar   *replyCommentToolBar;

@end

@implementation TCMaxDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle =[NSString stringWithFormat:@"%ld条回复",self.relpy_num];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    maxDynamicArr = [[NSMutableArray alloc] init];
    head_comment = [[NSDictionary alloc] init];
    maxReplyPage = 1;
    isFace = 0;
    
    [self.view addSubview:self.maxDynamicTab];
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.replyCommentToolBar];
    [self loadMaxDynamicData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"更多回复"];
    if ([TCHelper sharedTCHelper].isDeleteDynamic==YES) {
        [self loadMaxDynamicData];
        [TCHelper sharedTCHelper].isDeleteDynamic=NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"更多回复"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];

}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self willKeyboardHidden];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [head_comment count]>0?2:0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else{
        return maxDynamicArr.count>0?maxDynamicArr.count:0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentifier=@"TCMaxDynamicTableViewCell";
        TCMaxDynamicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCMaxDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell cellMaxDynamicDict:head_comment];
        return cell;
    }else{
        static NSString *cellIdentifier=@"TCReplyContentTableViewCell";
        TCReplyContentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCReplyContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCMaxDynamicModel *maxDynamicModel =maxDynamicArr[indexPath.row];
        if (maxDynamicModel.news_comment_id == self.newscomment_id) {
            cell.backgroundColor = [UIColor colorWithHexString:@"0xddfef1"];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        [cell cellReplyContentModel:maxDynamicModel];
        return cell;
        }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==0) {
        CGFloat height = 0.0;
        height = [TCMaxDynamicTableViewCell tableView:tableView rowMaxDynamicForObject:[head_comment objectForKey:@"content"]];

        return height+52+34;
    }else{
        TCMaxDynamicModel *maxDynamicModel =maxDynamicArr[indexPath.row];
        float height =[TCReplyContentTableViewCell tableView:tableView rowReplyContentForObject:maxDynamicModel.content];
        return height+50;
        }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==1) {
        if (indexPath.row<maxDynamicArr.count) {
            TCMaxDynamicModel *maxDynamicModel =maxDynamicArr[indexPath.row];
            prant_id = [[head_comment objectForKey:@"news_comment_id"] integerValue];
            newsid = maxDynamicModel.news_id;
            comment_user_id = maxDynamicModel.comment_user_id;
            roletype = maxDynamicModel.role_type;
            news_comment_id = maxDynamicModel.news_comment_id;
            if (maxDynamicModel.is_self==1) {
                [self deleteComment];
            } else {
                self.replyCommentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",maxDynamicModel.comment_nick];
                [self.replyCommentToolBar.inputTextView becomeFirstResponder];
            }
        }
    }else{
        prant_id = [[head_comment objectForKey:@"news_comment_id"] integerValue];
        newsid = [[head_comment objectForKey:@"news_id"] integerValue];
        comment_user_id =[[head_comment objectForKey:@"comment_user_id"] integerValue];
        roletype = [[head_comment objectForKey:@"role_type"] integerValue];
        self.replyCommentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",[head_comment objectForKey:@"nick_name"]];
        [self.replyCommentToolBar.inputTextView becomeFirstResponder];

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 10;
     }
    return 0.01;
}

#pragma mark TCCommentToolBarDelegate
-(void)didSendText:(NSString *)text{
    self.replyCommentToolBar.textLabel.hidden = YES;
    NSString *sendMessageStr=[EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    NSString *sendMessage = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)sendMessageStr, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));

    // App版本信息
    NSString *version = [NSString getAppVersion];
    // 设备型号
    NSString *systemName = [UIDevice getSystemName];
    // 系统版本
    NSString *systemVersion = [UIDevice getSystemVersion];
    
    NSString *body = [NSString stringWithFormat:@"news_id=%ld&commented_user_id=%ld&role_type=0&role_type_ed=%ld&content=%@&parent_id=%ld&parent_comment_id=%ld&app_version=%@&unit_type=%@&unit_system=%@",newsid,comment_user_id,roletype,sendMessage,prant_id>0?prant_id:0,prant_id,version,systemName,systemVersion];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDoComment body:body success:^(id json) {
        self.replyCommentToolBar.inputTextView.text = @"";
        self.replyCommentToolBar.inputTextView.placeHolder = @"发表评论";
        [TCHelper sharedTCHelper].isMaxDynamicReload = YES;
        prant_id = 0;
        [self loadMaxDynamicData];
    } failure:^(NSString *errorStr) {
        if (errorStr.length>=5) {
            NSString *error = [errorStr substringToIndex:5];
            if ([error isEqualToString:@"您已被禁言"]) {
                NSArray *newArray = [errorStr componentsSeparatedByString:@","];
                NSInteger time = [newArray[1] integerValue];
                NSString *gag_desc = newArray[2];
                [self IsgagAlert:time gag_desc:gag_desc];
            } else {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }
        }else{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }
    }];
}
- (void)didface{
    isFace = 1;
}
- (void)SendErrorText{
    UIWindow *window =[[UIApplication sharedApplication].windows lastObject];
    [window makeToast:@"不能提交空白信息" duration:1.0 position:CSToastPositionCenter];
}
#pragma mark -- linkReplyContentDelegate
#pragma mark -- 点击被标记区域
- (void)linkReplyContent:(NSInteger)news_id role_type:(NSInteger)role_type{

    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = news_id;
    myDynamicVC.role_type_ed = role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
#pragma mark -- linkCommentReplyDelegate
#pragma mark -- 点击用户头像／名称
- (void)LinkUserInfoReplyContent:(NSInteger)expert_id role_type:(NSInteger)role_type role_type_ed:(NSInteger)role_type_ed{
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = expert_id;
    myDynamicVC.role_type_ed =role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
#pragma mark -- 查看原动态
- (void)lookAtTheOriginalDynamic{
    TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
    dynamicDetailVC.news_id =[[head_comment objectForKey:@"news_id"] integerValue];
    dynamicDetailVC.commented_user_id =[[head_comment objectForKey:@"commented_user_id"] integerValue];
    dynamicDetailVC.role_type_ed =[[head_comment objectForKey:@"role_type_ed"] integerValue];

    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- 获取动态详情数据
- (void)loadMaxDynamicData{
    NSString *body = [NSString stringWithFormat:@"%@?parent_id=%ld&page_size=20&page_num=%ld",KDynamicMoreComment,self.news_id,maxReplyPage];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:body success:^(id json) {
        head_comment = [json objectForKey:@"head_comment"];
        prant_id = [[head_comment objectForKey:@"news_comment_id"] integerValue];
        newsid = [[head_comment objectForKey:@"news_id"] integerValue];
        comment_user_id =[[head_comment objectForKey:@"comment_user_id"] integerValue];
        roletype = [[head_comment objectForKey:@"role_type"] integerValue];
        _replyCommentToolBar.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@",[head_comment objectForKey:@"nick_name"]];
        NSArray *result = [json objectForKey:@"result"];
         NSInteger total  =[[json objectForKey:@"total"] integerValue];

        if (total>0) {
            self.baseTitle = [NSString stringWithFormat:@"%@条回复",[json objectForKey:@"total"]];
        } else {
            [TCHelper sharedTCHelper].isMaxDynamicReload=YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *replyArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMaxDynamicModel *maxDynamicModel = [[TCMaxDynamicModel alloc] init];
                [maxDynamicModel setValues:dict];
                if (maxDynamicModel.news_comment_id == self.newscomment_id) {
                    [replyArray insertObject:maxDynamicModel atIndex:0];
                } else {
                    [replyArray addObject:maxDynamicModel];
                }
            }
            self.maxDynamicTab.mj_footer.hidden=replyArray.count<20;
            if (maxReplyPage==1) {
                maxDynamicArr = replyArray;
            } else {
                [maxDynamicArr addObjectsFromArray:replyArray];
            }
            blankView.hidden=maxDynamicArr.count>0;
            self.maxDynamicTab.mj_footer.hidden=(total -maxReplyPage*20)<=0;
            self.maxDynamicTab.tableFooterView = (total -maxReplyPage*20)<=0 ? [self tableViewMaxFooterView] : [UIView new];
        }else{
            [maxDynamicArr removeAllObjects];
            self.maxDynamicTab.tableFooterView = [UIView new];
            self.maxDynamicTab.mj_footer.hidden = YES;
            blankView.hidden = NO;
        }
        [self.maxDynamicTab.mj_header endRefreshing];
        [self.maxDynamicTab.mj_footer endRefreshing];
        [_maxDynamicTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.maxDynamicTab.mj_header endRefreshing];
        [self.maxDynamicTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  获取最新回复数据
-(void)loadMaxReplyNewData{
    maxReplyPage=1;
    [self loadMaxDynamicData];
}

#pragma mark  获取更多回复数据
-(void)loadMaxReplyMoreData{
    maxReplyPage++;
    [self loadMaxDynamicData];
}
#pragma mark -- 禁言
- (void)IsgagAlert:(NSInteger)time gag_desc:(NSString *)gag_desc{
    
    NSString *timeStr = [[TCHelper sharedTCHelper] dateGagtimeToRequiredString:time];
    NSString *title = [NSString stringWithFormat:@"因%@，已被禁言，离解禁还剩%@",gag_desc,timeStr];
    
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1, gag_desc.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, title.length)];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"禁言" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController setValue:alertControllerStr forKey:@"attributedMessage"];
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ======  没有更多 =======

- (UIView *)tableViewMaxFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多评论了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    
    return footerView;
}
#pragma mark -- NSNotification
#pragma mark 键盘开启
- (void) keyboardWillShow:(NSNotification*)notification {
    _bgView.hidden = NO;
    
}
#pragma mark 键盘关闭
-(void)keyboardWillHideAction:(NSNotification *)notifi{
    MyLog(@"keyboardWillHideAction");
    if (isFace==0) {
        _bgView.hidden = YES;
    }else if (isFace==1){
        isFace=0;
    }
}
#pragma mark  删除评论
-(void)deleteComment{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *body = [NSString stringWithFormat:@"news_comment_id=%ld&role_type=0",news_comment_id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KCommentsDelete body:body success:^(id json) {
            [weakSelf loadMaxDynamicData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    
    //管理员才能显示
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Event Menthon
#pragma mark -- getter
- (UITableView *)maxDynamicTab{
    if (_maxDynamicTab==nil) {
        _maxDynamicTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight + 44) style:UITableViewStylePlain];
        _maxDynamicTab.backgroundColor = [UIColor bgColor_Gray];
        _maxDynamicTab.delegate = self;
        _maxDynamicTab.dataSource = self;
        _maxDynamicTab.showsVerticalScrollIndicator = NO;
        _maxDynamicTab.tableFooterView  =[[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMaxReplyNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _maxDynamicTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMaxReplyMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _maxDynamicTab.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49+40, kScreenWidth, 200) img:@"img_tips_no" text:@"没有更多回复"];
        [_maxDynamicTab addSubview:blankView];
        blankView.hidden=YES;
    }
    return _maxDynamicTab;
}
-(UIView *)bgView{
    if (_bgView==nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _bgView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(willKeyboardHidden)];
        [_bgView addGestureRecognizer:tap];
        _bgView.hidden = YES;
    }
    return _bgView;
}

-(TCCommentToolBar *)replyCommentToolBar{
    if (_replyCommentToolBar==nil) {
        _replyCommentToolBar=[[TCCommentToolBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-46, kScreenWidth, 46)];
        _replyCommentToolBar.delegate=self;
        _replyCommentToolBar.inputTextView.placeHolder = @"回复评论";
    }
    return _replyCommentToolBar;
}

#pragma mark -- 点击空白收回键盘
- (void)willKeyboardHidden{
    _bgView.hidden = YES;
    [self.replyCommentToolBar willHiddenKeyboard];
    
}

@end
