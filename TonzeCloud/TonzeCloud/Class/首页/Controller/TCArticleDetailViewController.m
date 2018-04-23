//
//  TCArticleDetailViewController.m
//  TonzeCloud
//
//  Created by vision on 17/10/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCArticleDetailViewController.h"
#import "TCArticleTableViewCell.h"
#import "TCCommentArticleCell.h"
#import <WebKit/WebKit.h>
#import "TCArticleModel.h"
#import "TCCommentArticleModel.h"
#import "MYCoreTextLabel.h"
#import "TCReplyButton.h"
#import "TCCommentToolBar.h"
#import "TCMineSugarFriendViewController.h"
#import "TCMyDynamicViewController.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCArticleDetailViewController ()<WKUIDelegate,WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource,TCCommentArticleCellDelegate,TCCommentToolBarDelegate>{
    NSMutableArray        *recommandArticleArr;   //推荐文章
    NSMutableArray        *commentArray;   //评论
    BOOL                   isLogin;
    NSInteger              isFace;
    NSInteger              parent_id;           //0为评论动态 其他的评论谁，即 parent_id=评论动态的评论id
    NSInteger              parent_comment_id;   //回复或者评论的那条内容的 news_comment_id. 评论动态的时候为0
    NSInteger              commentedUserID;   //被评论者用户id
    NSInteger              role_type;        // //评论者角色类型
    NSInteger              roletypeed;
    NSInteger              _pageNum;
}
@property (nonatomic ,strong)UIView           *bgView;
@property (nonatomic,strong) UITableView    *articelTableView;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) WKWebView      *rootWebView;
@property (nonatomic,strong)TCCommentToolBar *commentToolBar;

@end

@implementation TCArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"糖士－糖百科";
    
    recommandArticleArr=[[NSMutableArray alloc] init];
    commentArray=[[NSMutableArray alloc] init];
    parent_id = parent_comment_id=isFace = 0;
    _pageNum  = 1;
    
    [self.view addSubview:self.articelTableView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.commentToolBar];
    [self.view addSubview:self.bgView];
    [self requestWebView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?recommandArticleArr.count:commentArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentifier=@"TCArticleTableViewCell";
        TCArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCArticleModel *article=recommandArticleArr[indexPath.row];
        [cell cellDisplayWithModel:article searchText:@""];
        
        return cell;
    }else{
        static NSString *cellIdentifier=@"TCCommentArticleCell";
        TCCommentArticleCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCCommentArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.cellDelegate=self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCCommentArticleModel *model=commentArray[indexPath.row];
        [cell commentArticleCellDisplayWithModel:model];
        return cell;
    }
}
#pragma mark --  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        TCArticleModel *article=recommandArticleArr[indexPath.row];
        TCArticleDetailViewController *articleDetailVC=[[TCArticleDetailViewController alloc] init];
        articleDetailVC.articleID=article.id;
        articleDetailVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:articleDetailVC animated:YES];
    }else{
        TCCommentArticleModel *model=commentArray[indexPath.row];
        if ([model.is_self boolValue]) {  //删除评论
             [self deleteCommentWithrole_type:model.role_type article_comment_id:model.article_comment_id];
        }else{ //发表评论
            MyLog(@"发表评论");
            parent_id = model.article_comment_id;
            parent_comment_id = model.article_comment_id;
            commentedUserID =model.comment_user_id;
            roletypeed = model.role_type;
            [self.commentToolBar.inputTextView becomeFirstResponder];
            self.commentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",model.nick_name];
        }
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    rootView.backgroundColor=[UIColor bgColor_Gray];
    
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 40)];
    headView.backgroundColor=[UIColor whiteColor];
    [rootView addSubview:headView];
    
    UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    lineLab.backgroundColor=kSystemColor;
    [headView addSubview:lineLab];
    
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(lineLab.right+5, 10, 100, 20)];
    titleLab.text=section==0?@"推荐":@"精彩评论";
    titleLab.font=[UIFont systemFontOfSize:15];
    [headView addSubview:titleLab];
    
    if(section==1&&commentArray.count==0){
        return nil;
    }else{
       return rootView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==1&&commentArray.count==0?0.0:50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 100;
    }else{
        TCCommentArticleModel *model=commentArray[indexPath.row];
        return  [TCCommentArticleCell getCommentArticleCellHeightWithModel:model];
    }
}

#pragma mark -- TCCommentArticleCellDelegate
#pragma mark 跳转到个人主页
-(void)commentArticleCellPushIntoPersanlInfoVCWithUserId:(NSInteger)user_id isSelf:(BOOL)is_self{
    if (is_self) {
        TCMineSugarFriendViewController *myPersonalMainVC=[[TCMineSugarFriendViewController alloc] init];
        [self.navigationController pushViewController:myPersonalMainVC animated:YES];
    }else{
        TCMyDynamicViewController *myDynamicVC=[[TCMyDynamicViewController alloc] init];
        myDynamicVC.news_id=user_id;
        [self.navigationController pushViewController:myDynamicVC animated:YES];
    }
}

#pragma mark 选择回复区域
-(void)commentArticleCellReplyCommentActionWithReply:(TCArticleReplyModel*)replyModel isSelf:(BOOL)is_self parentCommentId:(NSInteger)parentCommentId{
    MyLog(@"选择回复区域");
    if (is_self) {
        [self deleteCommentWithrole_type:replyModel.role_type article_comment_id:replyModel.article_comment_id];
    }else{
        parent_id = parentCommentId;
        parent_comment_id = replyModel.article_comment_id;
        commentedUserID =replyModel.comment_user_id;
        roletypeed = replyModel.role_type;
        [self.commentToolBar.inputTextView becomeFirstResponder];
        self.commentToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"回复%@:",replyModel.comment_nick];
    }
}
- (void)didClickcLookAllCommentCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.articelTableView indexPathForCell:cell];
    TCCommentArticleModel *model=commentArray[indexPath.row];
    model.islookAllComment = YES;
    NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [_articelTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - 监听web加载进度
/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.rootWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - WKWKNavigationDelegate Methods
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.offsetHeight;"completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        //获取页面高度，并重置webview的frame
        CGFloat documentHeight = [result doubleValue];
        CGRect frame = webView.frame;
        frame.size.height = documentHeight+20;
        webView.frame = frame;
        MyLog(@"webView-----w:%.f,h:%.f",webView.width,webView.height);
    }];
    [self requestRecommandAticleList];
    [self requestArticleCommentsList];
}
#pragma mark -- Private methods
#pragma mark 加载文章页面
-(void)requestWebView{
    NSString *urlString = [NSString stringWithFormat:@"%@%ld",kArticleWebUrl,(long)self.articleID];
    MyLog(@"url:%@",urlString);
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.rootWebView loadRequest:req];
}
#pragma mark  加载推荐文章
-(void)requestRecommandAticleList{
    kSelfWeak;
    NSString *body=[NSString stringWithFormat:@"id=%ld&num=3",(long)self.articleID];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDetailArticleList body:body success:^(id json) {
        NSArray  *articleList=[json valueForKey:@"result"];
        NSMutableArray *tempArticleArr=[[NSMutableArray alloc] init];
        if (kIsArray(articleList)) {
            for (NSDictionary *dict in articleList) {
                TCArticleModel *article=[[TCArticleModel alloc] init];
                [article setValues:dict];
                [tempArticleArr addObject:article];
            }
        }
        recommandArticleArr=tempArticleArr;
        [weakSelf.articelTableView reloadData];
    } failure:^(NSString *errorStr) {
    }];
}
#pragma mark  加载评论
-(void)requestArticleCommentsList{
    kSelfWeak;
    NSString *body=[NSString stringWithFormat:@"article_id=%ld&role_type=0&page_size=20&page_num=%ld",(long)self.articleID,_pageNum];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCommentList body:body success:^(id json) {
        NSInteger total= [[json objectForKey:@"total"] integerValue];
        weakSelf.articelTableView.mj_footer.hidden= total < 20 *_pageNum;
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCCommentArticleModel *model=[[TCCommentArticleModel alloc] init];
                [model setValues:dict];
                model.islookAllComment = NO;
                [tempArr addObject:model];
            }
            [commentArray addObjectsFromArray:tempArr];
        }
        [weakSelf.articelTableView reloadData];
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark  获取更多评论数据
-(void)loadDynamicDetailMoreData{
    _pageNum++;
    [self requestArticleCommentsList];
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
- (void)didface{
    isFace = 1;
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
    
    NSString *body = [NSString stringWithFormat:@"article_id=%ld&commented_user_id=%ld&role_type=0&role_type_ed=%ld&content=%@&parent_id=%ld&parent_comment_id=%ld&app_version=%@&unit_type=%@&unit_system=%@",(long)self.articleID,(long)(parent_id>0?commentedUserID: 0),(long)(parent_id>0?roletypeed:0),_page,(long)(parent_id>0?parent_id:0),(long)(parent_id>0?parent_comment_id:0),version,systemName,systemVersion];
    
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KCommentOfArticle body:body success:^(id json) {
        [weakSelf.view makeToast:@"已发送" duration:1.0 position:CSToastPositionCenter];
        [commentArray removeAllObjects];
        _pageNum = 1;
        [weakSelf requestArticleCommentsList];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark 删除评论
-(void)deleteCommentWithrole_type:(NSInteger )role_type article_comment_id:(NSInteger)article_comment_id{
    MyLog(@"删除评论");
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 确认删除评论
            NSString *body = [NSString stringWithFormat:@"article_comment_id=%ld&role_type=%ld",(long)article_comment_id,(long)role_type];
            kSelfWeak;
            [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KDeleteCommentOfArticle body:body success:^(id json) {
                [weakSelf.view makeToast:@"删除成功" duration:1.0 position:CSToastPositionCenter];
                [commentArray removeAllObjects];
                _pageNum = 1;
                [weakSelf requestArticleCommentsList];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
            
        }
    }];
    [alert show];
}
#pragma mark notification
- (void) keyboardWillShow:(NSNotification*)notification {
    _bgView.hidden = NO;
}
- (void) keyboardWillHide:(NSNotification*)notification {
    if (isFace==1) {
        isFace=0;
    }else{
        _bgView.hidden = YES;
        if (self.commentToolBar.inputTextView.text.length==0) {
            self.commentToolBar.textLabel.hidden = YES;
        }
    }
}
#pragma mark -- 点击空白收回键盘
- (void)willKeyboardHidden{
    _bgView.hidden = YES;
    parent_id = 0;
    self.commentToolBar.inputTextView.placeHolder = @"发表评论";
    [self.commentToolBar willHiddenKeyboard];
}
#pragma mark -- gettters
#pragma mark
-(UITableView *)articelTableView{
    if (!_articelTableView) {
        _articelTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-46) style:UITableViewStyleGrouped];
        _articelTableView.dataSource=self;
        _articelTableView.delegate=self;
        _articelTableView.backgroundColor=[UIColor bgColor_Gray];
        _articelTableView.tableHeaderView=self.rootWebView;
        _articelTableView.separatorInset=UIEdgeInsetsMake(0,10, 0, 0);
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDynamicDetailMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _articelTableView.mj_footer = footer;
        footer.hidden=YES;
        
    }
    return _articelTableView;
}
#pragma mark 进度条
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 2)];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progressTintColor = UIColorFromRGB(0xfff100);
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    }
    return _progressView;
}
#pragma mark 网页浏览器
-(WKWebView *)rootWebView{
    if (!_rootWebView) {
        _rootWebView=[[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight)];
        _rootWebView.UIDelegate=self;
        _rootWebView.navigationDelegate = self;
        _rootWebView.scrollView.scrollEnabled=NO;
        /*
         *3.添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
         */
        [_rootWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _rootWebView;
}
#pragma mark 评论输入框
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
#pragma mark ====== dealloc =======
- (void)dealloc {
    [self.rootWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}
@end
