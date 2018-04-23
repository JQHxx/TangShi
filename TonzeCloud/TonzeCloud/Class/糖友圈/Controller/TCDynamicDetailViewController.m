//
//  TCDynamicDetailViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDynamicDetailViewController.h"
#import "TCDynamicTableViewCell.h"
#import "TCMyDynamicModel.h"
#import "TCCommentsDetailTableViewCell.h"
#import "TCMenuView.h"
#import "TCMaxDynamicViewController.h"
#import "TCDynamicPraiseModel.h"
#import "TCMyDynamicViewController.h"
#import "TCDynamicCommentsModel.h"
#import "TCDetailPraiseTableViewCell.h"
#import "IQKeyboardManager.h"
#import "TCCommentToolBar.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "TCTopicDetailsViewController.h"

@interface TCDynamicDetailViewController ()<UITableViewDelegate,UITableViewDataSource,TCDynamicDetailDelegate,TCCommentsReplyDelegate,TCCommentToolBarDelegate>{
    TCMyDynamicModel      *dynamicDetailModel;    //动态详情
    NSMutableArray        *commentsArr;           //评论列表
    NSMutableArray        *praiseArr;             //点赞列表
    NSInteger             isReply;               //0.评论 1.点赞
    
    NSInteger              praisePage;
    NSInteger              commentsPage;
    
    NSInteger              parent_id;           //0为评论动态 其他的评论谁，即 parent_id=评论动态的评论id
    NSInteger              parent_comment_id;   //回复或者评论的那条内容的 news_comment_id. 评论动态的时候为0
    NSInteger              commentedUserID;   //被评论者用户id
    NSInteger              total;             //评论个数
    NSInteger              newsid;
    NSInteger              roletype;
    NSInteger              isFace;
    NSInteger              roletypeed;
    
    BOOL                   isCmmentReload;
    BOOL                   isPraiseReload;
}

@property (nonatomic ,strong)UITableView      *dynamicDetailTab;
@property (nonatomic ,strong)UILabel          *lineLabel;
@property (nonatomic ,strong)UIButton         *commentsButton;
@property (nonatomic ,strong)UIButton         *praiseButton;
@property (nonatomic ,strong)TCCommentToolBar *commentToolBar;
@property (nonatomic ,strong)UIView           *bgView;
@property (nonatomic ,strong)TCBlankView      *commentBlankView;    //无评论
@property (nonatomic ,strong)TCBlankView      *praiseBlankView;     //无点赞

@end

@implementation TCDynamicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"动态详情";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    dynamicDetailModel= [[TCMyDynamicModel alloc] init];
    commentsArr = [[NSMutableArray alloc] init];
    praiseArr = [[NSMutableArray alloc] init];
    praisePage = 1;
    commentsPage = 1;
    parent_id=parent_comment_id=0;
    isFace = 0;
    
    [self.view addSubview:self.dynamicDetailTab];
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.commentToolBar];
    [self loadDynamicDetailData];
    [self loadDynamicCommentsData];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-06" type:1];
    [IQKeyboardManager sharedManager].enable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"---------");
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self willKeyboardHidden];
    [[TCHelper sharedTCHelper] loginAction:@"008-06" type:2];
    isCmmentReload = isPraiseReload = NO;
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return dynamicDetailModel.news_id>0?1:0;
    } else {
        if (isReply==0) {
            if (commentsArr.count>0) {
                return commentsArr.count;
            }else{
                return 1;
            }
        } else {
            if (praiseArr.count>0) {
                return praiseArr.count;
            }else{
                return 1;
            }
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentifier=@"TCDynamicTableViewCell";
        TCDynamicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell cellDynamicDetailModel:dynamicDetailModel];
        return cell;
    }else{
        if (isReply==0) {
            static NSString *cellIdentifier=@"TCCommentsDetailTableViewCell";
            TCCommentsDetailTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell==nil) {
                cell=[[TCCommentsDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.delegate = self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            if (commentsArr.count>0) {
                
                if (self.commentBlankView) {
                    [self.commentBlankView removeFromSuperview];
                    self.commentBlankView=nil;
                }
                
                TCDynamicCommentsModel *commentsModel =commentsArr[indexPath.row];
                if (self.news_comment_id==commentsModel.news_comment_id) {
                    cell.backgroundColor = [UIColor colorWithHexString:@"0xf1fbf7"];
                }else{
                    cell.backgroundColor = [UIColor whiteColor];
                }
                [cell cellCommentsReplyModel:commentsModel];
            }else{
                TCDynamicCommentsModel *commentsModel =[[TCDynamicCommentsModel alloc] init];
                [cell cellCommentsReplyModel:commentsModel];
                [cell addSubview:self.commentBlankView];
            }
            return cell;
        } else {
            static NSString *cellIdentifier=@"TCDetailPraiseTableViewCell";
            TCDetailPraiseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell==nil) {
                cell=[[TCDetailPraiseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (praiseArr.count>0) {
                if (self.praiseBlankView) {
                    [self.praiseBlankView removeFromSuperview];
                    self.praiseBlankView=nil;
                }
                TCDynamicPraiseModel *dynamicPraiseModel =praiseArr[indexPath.row];
                [cell cellDetailPraiseModel:dynamicPraiseModel];
            }else{
                [cell addSubview:self.praiseBlankView];
            }
            
            return cell;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1&&isReply==0) {
        [MobClick event:@"105_002032"];
        TCDynamicCommentsModel *keyCommentsModel =commentsArr[indexPath.row];
        if (keyCommentsModel.is_self == 1) {
            [self commentsDeleteComment:keyCommentsModel];
        } else {
            parent_id = keyCommentsModel.news_comment_id;
            parent_comment_id=keyCommentsModel.news_comment_id;
            commentedUserID =keyCommentsModel.user_id;
            roletypeed = keyCommentsModel.role_type;
            self.commentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",keyCommentsModel.nick_name];
            [self.commentToolBar.inputTextView becomeFirstResponder];
        }
    }else if(indexPath.section==1&&isReply==1){
        TCDynamicPraiseModel *dynamicPraiseModel =praiseArr[indexPath.row];
        TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
        myDynamicVC.role_type_ed =dynamicPraiseModel.role_type;
        myDynamicVC.news_id = dynamicPraiseModel.user_id;
        [self.navigationController pushViewController:myDynamicVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return [TCDynamicTableViewCell getCellContentHeightWithModel:dynamicDetailModel];
    } else {
        if (isReply==0) {
            if (commentsArr.count>0) {
                TCDynamicCommentsModel *commentsModel = commentsArr[indexPath.row];
                return [TCCommentsDetailTableViewCell getCommentReplyHeightForModel:commentsModel];
            }else{
                return 200;
            }
            
        } else {
            if (praiseArr.count>0) {
                return 50;
            }else{
               return 200;
            }
            
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section=0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return 40;
    } else {
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    headView.backgroundColor = [UIColor whiteColor];
    if (section==1) {
        UILabel *grayLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 1)];
        grayLine.backgroundColor =[UIColor colorWithHexString:@"0xdcdcdc"];
        [headView addSubview:grayLine];
        
        [headView addSubview:self.commentsButton];
        [headView addSubview:self.praiseButton];
        [headView addSubview:self.lineLabel];
    }
    return headView;
}
#pragma mark -- UIAlertViewDelegate
#pragma mark 删除动态
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        kSelfWeak;
        NSString *body = [NSString stringWithFormat:@"news_id=%ld&role_type=%ld",(long)newsid,(long)roletype];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDelete body:body success:^(id json) {
            [TCHelper sharedTCHelper].isDeleteDynamic = YES;
            [TCHelper sharedTCHelper].isNewDynamicRecord = YES;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark --TCFoodMenuViewDelegate
-(void)commentsButton:(UIButton *)button{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-06"];
    [MobClick event:@"105_002031"];
    isReply = button.tag-100;
    if (button.tag==100) {
        if (!isCmmentReload) {
            [self loadDynamicCommentsData];
        } else {
            [self.dynamicDetailTab reloadData];
        }
        [UIView animateWithDuration:0.2 animations:^{
            _lineLabel.frame=CGRectMake(_commentsButton.left, 38,_commentsButton.width, 2);
            [_commentsButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
            [_praiseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }];
    } else {
        if (!isPraiseReload) {
            [self loadDynamicPraiseData];
        } else {
            [self.dynamicDetailTab reloadData];
        }
        [UIView animateWithDuration:0.2 animations:^{
            _lineLabel.frame=CGRectMake(_praiseButton.left, 38,_praiseButton.width, 2);
            [_commentsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_praiseButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        }];
    }
    [_dynamicDetailTab reloadData];
}

#pragma mark --TCCommentToolBarDelegate
#pragma mark 发送消息
- (void)didSendText:(NSString *)text{
    NSString *willSendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    MyLog(@"发送消息,text:%@,emojiStr:%@",text,willSendText);
    if (text && text.length > 0) {
        [self sendMessageText:willSendText];
    }
}
- (void)didMoreSendText{
    UIWindow *window =[[UIApplication sharedApplication].windows lastObject];
    [window makeToast:@"评论内容不能超过200个字" duration:1.0 position:CSToastPositionCenter];
}
- (void)SendErrorText{
    UIWindow *window =[[UIApplication sharedApplication].windows lastObject];
    [window makeToast:@"不能提交空白信息" duration:1.0 position:CSToastPositionCenter];
}
#pragma mark notification
- (void) keyboardWillShow:(NSNotification*)notification {
    _bgView.hidden = NO;
    
}
- (void) keyboardWillHide:(NSNotification*)notification {
    if (isFace==1) {
        isFace=0;
    } else {
        _bgView.hidden = YES;
    }
}
#pragma mark -- 点击表情触发表情键盘
- (void)didface{
    isFace = 1;
}
#pragma mark -- TCMyDynamicDelegate
#pragma mark 删除动态
- (void)myDynamicDelete:(TCMyDynamicModel *)model{
    roletype = model.role_type;
    newsid = model.news_id;
    
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}
#pragma mark 发表评论
-(void)myDynamicDetailComment:(TCMyDynamicModel *)model{
    [MobClick event:@"105_002029"];
    [[TCHelper sharedTCHelper] loginClick:@"008-06-04"];
    parent_id=0;
    self.commentToolBar.inputTextView.placeHolder=@"发表评论";
    [self.commentToolBar.inputTextView becomeFirstResponder];
}
#pragma mark 用户信息
- (void)myDynamicDetailContent:(TCMyDynamicModel *)userModel{
    [MobClick event:@"105_002026"];
    [[TCHelper sharedTCHelper] loginClick:@"008-06-01"];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = userModel.user_id;
    myDynamicVC.role_type_ed = userModel.role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
#pragma mark  点击标记区域
- (void)myLinkDetailSeleted:(NSInteger)expert_id role_type:(NSInteger)role_type{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-02"];
    [MobClick event:@"105_002027"];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = expert_id;
    myDynamicVC.role_type_ed = role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}

#pragma mark 点赞
- (void)myDynamicDetailPraise:(TCMyDynamicModel *)model type:(NSInteger)type{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-05"];
    [MobClick event:@"105_002030"];
    dynamicDetailModel.like_status = !dynamicDetailModel.like_status;
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=0&is_like=%ld",model.news_id,model.user_id,model.role_type,(long)type];
    [[TCHttpRequest  sharedTCHttpRequest] postMethodWithURL:KDynamicDoLike body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 1) {
            if (type==0) {
                dynamicDetailModel.like_count = model.like_count-1;
            }else{
                dynamicDetailModel.like_count = model.like_count+1;
            }
            [weakSelf loadDynamicPraiseData];
            if (self.likeSuccessBlock) {
                self.likeSuccessBlock(dynamicDetailModel.like_count , dynamicDetailModel.like_status);
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 动态详情
- (void)myDynamicTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
    TCTopicDetailsViewController *topicDetailVC = [[TCTopicDetailsViewController alloc] init];
    topicDetailVC.topicId = topic_id;
    topicDetailVC.topic = topic;
    topicDetailVC.topic_delete_status = topic_delete_status;
    [self.navigationController pushViewController:topicDetailVC animated:YES];
}
#pragma mark --TCCommentsReplyDelegate
#pragma mark 点击回复标记区域
- (void)linkCommentsReplyContent:(NSInteger)linkContent role_type:(NSInteger)role_type{
    [MobClick event:@"105_002027"];
    [[TCHelper sharedTCHelper] loginClick:@"008-06-02"];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = linkContent;
    myDynamicVC.role_type_ed = role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}

#pragma mark  更多回复
-(void)commentsDetailCellGetMoreReplyWithCommentsModel:(TCDynamicCommentsModel *)model{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-10"];
    [MobClick event:@"105_002035"];
    TCMaxDynamicViewController *maxDynamicVC = [[TCMaxDynamicViewController alloc] init];
    maxDynamicVC.news_id = model.news_comment_id;
    maxDynamicVC.relpy_num = model.reply_num;
    [self.navigationController pushViewController:maxDynamicVC animated:YES];
}

#pragma mark 点击用户头像
-(void)commentsDetailCellDidClickUserPhotoWithUserId:(TCDynamicCommentsModel *)userModel{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-01"];
    [MobClick event:@"105_002026"];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = userModel.user_id;
    myDynamicVC.role_type_ed = userModel.role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}

#pragma mark  评论点赞
- (void)commentsDetailCellDidClickPraisedWithModel:(TCDynamicCommentsModel *)commentsModel{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-08"];
    [MobClick event:@"105_002033"];
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=1&is_like=%d",(long)commentsModel.news_comment_id,(long)commentsModel.comment_user_id,(long)commentsModel.role_type,commentsModel.like_status==0?1:0];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDoLike body:body success:^(id json) {
        [weakSelf loadDynamicCommentsData];
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 删除评论
-(void)commentsDeleteComment:(TCDynamicCommentsModel *)commentsModel{
    [MobClick event:@"105_002034"];
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *body = [NSString stringWithFormat:@"news_comment_id=%ld&role_type=0",(long)commentsModel.news_comment_id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KCommentsDelete body:body success:^(id json) {
            if (self.commentsSuccessBlock) {
                self.commentsSuccessBlock(YES);
            }
            dynamicDetailModel.comment_count = dynamicDetailModel.comment_count-1;
            [weakSelf loadDynamicCommentsData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    
    //管理员才能显示
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 删除回复
-(void)commentsDeleteReply:(TCCommentReplyModel *)replyModel{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-09"];
    [MobClick event:@"105_002034"];
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *body = [NSString stringWithFormat:@"news_comment_id=%ld&role_type=0",(long)replyModel.news_comment_id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KCommentsDelete body:body success:^(id json) {
            [weakSelf loadDynamicCommentsData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    
    //管理员才能显示
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark  回复评论
-(void)commentsDetailCellReplyCommentWithReplyModel:(TCCommentReplyModel *)replyModel parentCommentId:(NSInteger)parentCommentId{
    [[TCHelper sharedTCHelper] loginClick:@"008-06-07"];
    [MobClick event:@"105_002032"];
    parent_id = parentCommentId;
    roletypeed = replyModel.role_type;
    parent_comment_id = replyModel.news_comment_id;
    commentedUserID = replyModel.comment_user_id;
    self.commentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",replyModel.comment_nick];
    [self.commentToolBar.inputTextView becomeFirstResponder];
}

#pragma mark -- Event response
#pragma mark -- 获取动态详情数据
- (void)loadDynamicDetailData{
    kSelfWeak;
    NSString *url = [NSString stringWithFormat:@"%@?news_id=%ld&role_type=0&role_type_ed=%ld",KLoadDynamicDetail,(long)self.news_id,(long)self.role_type_ed];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithoutLoadingForURL:url success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            [dynamicDetailModel setValues:result];
        }
        NSString *praiseStr=[NSString stringWithFormat:@"赞 %ld",(long)dynamicDetailModel.like_count];
        [weakSelf.praiseButton setTitle:praiseStr forState:UIControlStateNormal];
        CGSize size = [praiseStr sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        weakSelf.praiseButton.frame =CGRectMake(weakSelf.commentsButton.right+10, 10, size.width+10, 20);

        [weakSelf.dynamicDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
 
}
#pragma mark -- 获取动态评论列表
- (void)loadDynamicCommentsData{
    kSelfWeak;
    NSString *url = [NSString stringWithFormat:@"%@?news_id=%ld&commented_user_id=%ld&page_size=20&page_num=%ld&role_type=0",KLoadCommentsList,(long)self.news_id,(long)self.commented_user_id,(long)commentsPage];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:url success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        total = [[json objectForKey:@"total"] integerValue];
        if (kIsArray(result)) {
            NSMutableArray *comments = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCDynamicCommentsModel *commentsModel = [[TCDynamicCommentsModel alloc] init];
                [commentsModel setValues:dict];
                if (commentsModel.news_comment_id == self.news_comment_id) {
                    [comments insertObject:commentsModel atIndex:0];
                }else{
                    [comments addObject:commentsModel];
                }
            }
            weakSelf.dynamicDetailTab.mj_footer.hidden=comments.count<20;
            if (commentsPage==1) {
                commentsArr = comments;
            } else {
                [commentsArr addObjectsFromArray:comments];
            }
            isCmmentReload = YES;
            [weakSelf.commentsButton setTitle:[NSString stringWithFormat:@"评论 %ld",(long)total] forState:UIControlStateNormal];
            CGSize size = [weakSelf.commentsButton.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
            weakSelf.commentsButton.frame =CGRectMake(10, 10, size.width+10, 20);
        }
        [weakSelf.dynamicDetailTab.mj_header endRefreshing];
        [weakSelf.dynamicDetailTab.mj_footer endRefreshing];
        [weakSelf.dynamicDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.dynamicDetailTab.mj_header endRefreshing];
        [weakSelf.dynamicDetailTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 获取动态点赞列表
- (void)loadDynamicPraiseData{
    kSelfWeak;
    NSString *url = [NSString stringWithFormat:@"%@?news_id=%ld&liked_user_id=%ld&page_size=20&page_num=%ld",KLoadPraiseList,self.news_id,self.commented_user_id,(long)praisePage];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:url success:^(id json) {
        NSArray *praiseArray = [json objectForKey:@"result"];
        total = [[json objectForKey:@"total"] integerValue];
        if (kIsArray(praiseArray)) {
            NSMutableArray *praise = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in praiseArray) {
                TCDynamicPraiseModel *dynamicPraiseModel = [[TCDynamicPraiseModel alloc] init];
                [dynamicPraiseModel setValues:dict];
                [praise addObject:dynamicPraiseModel];
            }
            weakSelf.dynamicDetailTab.mj_footer.hidden=praise.count<20;
            if (praisePage==1) {
                praiseArr = praise;
            } else {
                [praiseArr addObjectsFromArray:praise];
            }
            dynamicDetailModel.like_count=total;
            isPraiseReload = YES;
            NSString *praiseStr=[NSString stringWithFormat:@"赞 %ld",total];
            [weakSelf.praiseButton setTitle:praiseStr forState:UIControlStateNormal];
            CGSize size = [praiseStr sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
            weakSelf.praiseButton.frame =CGRectMake(weakSelf.commentsButton.right+10, 10, size.width+10, 20);
        }
        [weakSelf.dynamicDetailTab.mj_header endRefreshing];
        [weakSelf.dynamicDetailTab.mj_footer endRefreshing];
        [weakSelf.dynamicDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.dynamicDetailTab.mj_header endRefreshing];
        [weakSelf.dynamicDetailTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 发表评论(parent_id=0为评论动态，不为0为评论回复)
- (void)sendMessageText:(NSString *)text{
    self.commentToolBar.textLabel.hidden = YES;
    
    kSelfWeak;
    // 特殊字符进行转码
    NSString *_page = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)text, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
    
    // App版本信息
    NSString *version = [NSString getAppVersion];
    // 设备型号
    NSString *systemName = [UIDevice getSystemName];
    // 系统版本
    NSString *systemVersion = [UIDevice getSystemVersion];
    
    NSString *body = [NSString stringWithFormat:@"news_id=%ld&commented_user_id=%ld&role_type=0&role_type_ed=%ld&content=%@&parent_id=%ld&parent_comment_id=%ld&app_version=%@&unit_type=%@&unit_system=%@",(long)self.news_id,(long)(parent_id>0?commentedUserID:dynamicDetailModel.user_id),(long)(parent_id>0?roletypeed:dynamicDetailModel.role_type),_page,(long)(parent_id>0?parent_id:0),(long)(parent_id>0?parent_comment_id:0),version,systemName,systemVersion];

    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDoComment body:body success:^(id json) {
        [weakSelf.view makeToast:@"已发送" duration:1.0 position:CSToastPositionCenter];
        self.commentToolBar.inputTextView.text = @"";
        _commentToolBar.inputTextView.placeHolder = @"发表评论";
        if (parent_id==0) {
            if (weakSelf.commentsSuccessBlock) {
                weakSelf.commentsSuccessBlock(NO);
            }
            
            dynamicDetailModel.comment_count = dynamicDetailModel.comment_count+1;
        }
        _bgView.hidden = YES;
        parent_id = 0;
        [weakSelf loadDynamicCommentsData];
        [weakSelf getTaskPointsWithActionType:18 isTaskList:NO taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
            
        }];// 获取积分
    } failure:^(NSString *errorStr) {
        if (errorStr.length>=5) {
            NSString *error = [errorStr substringToIndex:5];
            if ([error isEqualToString:@"您已被禁言"]) {
                NSArray *newArray = [errorStr componentsSeparatedByString:@","];
                NSInteger time = [newArray[1] integerValue];
                NSString *gag_desc = newArray[2];
                [self IsgagAlert:time gag_desc:gag_desc];
            } else {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }
        }else{
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

        }
    }];
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
#pragma mark  获取最新动态数据
-(void)loadDynamicDetailNewData{
    praisePage=1;
    commentsPage = 1;
    if (isReply==0) {
        [self loadDynamicCommentsData];
    } else {
        [self loadDynamicPraiseData];
    }
}

#pragma mark  获取更多动态数据
-(void)loadDynamicDetailMoreData{
    praisePage++;
    commentsPage++;
    if (isReply==0) {
        [self loadDynamicCommentsData];
    } else {
        [self loadDynamicPraiseData];
    }
}
#pragma mark -- 点击空白收回键盘
- (void)willKeyboardHidden{
    _bgView.hidden = YES;
    [self.commentToolBar willHiddenKeyboard];
}
#pragma mark -- getter
- (UITableView *)dynamicDetailTab{
    if (_dynamicDetailTab==nil) {
        _dynamicDetailTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-46) style:UITableViewStylePlain];
        _dynamicDetailTab.delegate = self;
        _dynamicDetailTab.dataSource = self;
        _dynamicDetailTab.backgroundColor = [UIColor bgColor_Gray];
        _dynamicDetailTab.showsVerticalScrollIndicator = NO;
        _dynamicDetailTab.tableFooterView = [[UIView alloc] init];

        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadDynamicDetailNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _dynamicDetailTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDynamicDetailMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _dynamicDetailTab.mj_footer = footer;
        footer.hidden=YES;
    }
    return _dynamicDetailTab;
}
#pragma mark -- 评论
- (UIButton *)commentsButton{
    if(_commentsButton==nil){
        NSString *title = @"评论 0";
        _commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth/2, 20)];
        [_commentsButton setTitle:@"评论" forState:UIControlStateNormal];
        _commentsButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_commentsButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        [_commentsButton addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        _commentsButton.tag = 100;
        CGSize size = [title sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        _commentsButton.frame =CGRectMake(10, 10, size.width+10, 20);
    }
    return _commentsButton;
}
#pragma mark -- 赞
- (UIButton *)praiseButton{
    if (_praiseButton==nil) {
        NSString *title = @"赞 0";
        _praiseButton = [[UIButton alloc] initWithFrame:CGRectMake(_commentsButton.right, 10, kScreenWidth/2+1, 20)];
        [_praiseButton setTitle:@"赞" forState:UIControlStateNormal];
        _praiseButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_praiseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_praiseButton addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        _praiseButton.tag = 101;
        CGSize size = [title sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        _praiseButton.frame =CGRectMake(_commentsButton.right+10, 10, size.width+10, 20);
    }
    return _praiseButton;
}
- (UILabel *)lineLabel{
    if (_lineLabel==nil) {
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(_commentsButton.left, 38,_commentsButton.width, 2)];
        _lineLabel.backgroundColor = kbgBtnColor;
    }
    return _lineLabel;
}

-(TCCommentToolBar *)commentToolBar{
    if (_commentToolBar==nil) {
        _commentToolBar=[[TCCommentToolBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-46, kScreenWidth, 46)];
        _commentToolBar.delegate=self;
        _commentToolBar.inputTextView.placeHolder = @"发表评论";
        _commentToolBar.inputTextView.inputAccessoryView = [[UIView alloc] init];

    }
    return _commentToolBar;
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
#pragma mark 没有评论
-(TCBlankView *)commentBlankView{
    if (_commentBlankView==nil) {
        _commentBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"un_comment" text:@"来发表你的评论～"];
        _commentBlankView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _commentBlankView;
}

#pragma mark 没有赞
-(TCBlankView *)praiseBlankView{
    if (_praiseBlankView==nil) {
        _praiseBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"un_thumbup" text:@"来点个赞～"];
        _praiseBlankView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _praiseBlankView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
