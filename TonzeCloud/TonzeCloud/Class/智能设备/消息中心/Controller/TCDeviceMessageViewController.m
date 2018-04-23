//
//  TCDeviceMessageViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDeviceMessageViewController.h"
#import "TCMessageDetailViewController.h"

@interface TCDeviceMessageViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *messageClassArr;
}

@property (strong, nonatomic) UITableView *messageTableView;

@end

@implementation TCDeviceMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设备消息";
    
    messageClassArr=@[@"设备工作",@"设备分享",@"故障消息"];
    
    [self.view addSubview:self.messageTableView];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-06" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-06" type:2];
#endif
}
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return messageClassArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MessageClassCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text=messageClassArr[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:messageClassArr[indexPath.row]];
    cell.separatorInset=UIEdgeInsetsMake(0, 10, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *eventId=nil;
    if (indexPath.row==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-01-06-01"];
#endif
        eventId=@"101_003024";
    }else if (indexPath.row==1){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-01-06-02"];
#endif
        eventId=@"101_003025";
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-01-06-03"];
#endif
        eventId=@"101_003026";
    }
    [MobClick event:eventId];
    
    TCMessageDetailViewController *messageDetailVC = [[TCMessageDetailViewController alloc] init];
    messageDetailVC.type = indexPath.row;
    [self.navigationController pushViewController:messageDetailVC animated:YES];
    
}

#pragma mark -- Setters
-(UITableView *)messageTableView{
    if (_messageTableView==nil) {
        _messageTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _messageTableView.backgroundColor=[UIColor bgColor_Gray];
        _messageTableView.dataSource=self;
        _messageTableView.delegate=self;
        _messageTableView.showsVerticalScrollIndicator=NO;
        _messageTableView.tableFooterView=[[UIView alloc] init];
    }
    return _messageTableView;
}



@end
