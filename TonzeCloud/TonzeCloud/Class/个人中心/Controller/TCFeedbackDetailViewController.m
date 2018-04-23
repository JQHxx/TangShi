//
//  TCFeedbackDetailViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFeedbackDetailViewController.h"
#import "TCFeedbackDetailTableViewCell.h"

@interface TCFeedbackDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSDictionary *feedback;
    NSDictionary *feedback_reply;
}
@property (nonatomic ,strong)UITableView *feedbackDetailTab;
@end

@implementation TCFeedbackDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"反馈详情";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self.view addSubview:self.feedbackDetailTab];
    [self loadFeedbackDetailData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return section==0?feedback.count>0?1:0:feedback_reply.count>0?1:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TCFeedbackDetailTableViewCell";
    TCFeedbackDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[TCFeedbackDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell cellFeedbackDetailDict:indexPath.section==0?feedback:feedback_reply isBack:indexPath.section==0?YES:NO];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        NSString *feedBack = nil;
        if (feedback.count>0) {
            feedBack = [feedback objectForKey:@"feedback_content"];
            
        }
        CGSize size = [feedBack sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
        return 45+size.height;
    } else {
        NSString *feedBackContent = nil;
        if (feedback_reply.count>0) {
            feedBackContent =[feedback_reply objectForKey:@"content"];
        }
        CGSize size = [feedBackContent sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
        return 70+size.height;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}
#pragma mark -- 获取意见反馈详情
- (void)loadFeedbackDetailData{
    NSString *body = [NSString stringWithFormat:@"id=%ld&role_type=0",(long)self.id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KFeedbackDetail body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            feedback = [result objectForKey:@"feedback"];
            feedback_reply = [result objectForKey:@"feedback_reply"];
        }
        [_feedbackDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}
#pragma mark -- setter or getter
- (UITableView *)feedbackDetailTab{
    if (_feedbackDetailTab==nil) {
        _feedbackDetailTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _feedbackDetailTab.backgroundColor = [UIColor bgColor_Gray];
        _feedbackDetailTab.delegate = self;
        _feedbackDetailTab.dataSource = self;
        _feedbackDetailTab.tableFooterView = [[UIView alloc] init];
    }
    return _feedbackDetailTab;
}

@end
