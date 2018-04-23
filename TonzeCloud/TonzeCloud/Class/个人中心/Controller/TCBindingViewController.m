//
//  TCBindingViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBindingViewController.h"
#import "TCAddFriendViewController.h"
#import "TCBindingModel.h"
#import "TCBlankView.h"

@interface TCBindingViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray *dataArray;
}
@property (nonatomic ,strong)UITableView *tabView;
@property (nonatomic ,strong)UILabel *blanLabel;
@end

@implementation TCBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"绑定亲友";
    self.rightImageName = @"ic_top_add";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    dataArray = [[NSMutableArray alloc] init];
    [self.view addSubview:self.tabView];
    
    [self requestBindingData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TCHelper sharedTCHelper].isBindingFriend == YES) {
        
        [self requestBindingData];
        [TCHelper sharedTCHelper].isBindingFriend= NO;
    }

}
#pragma mark --UITableViewDelegate or UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"UITableViewCell";
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCBindingModel *bindingModel = dataArray[indexPath.row];
    cell.textLabel.text = bindingModel.call;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCBindingModel *bindingModel = dataArray[indexPath.row];
    TCAddFriendViewController *addFriendVC = [[TCAddFriendViewController alloc] init];
    addFriendVC.bindingModel = bindingModel;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}
#pragma mark -- Event response
- (void)rightButtonAction{
    TCAddFriendViewController *addFriendVC = [[TCAddFriendViewController alloc] init];
    [self.navigationController pushViewController:addFriendVC animated:YES];
}
- (void)requestBindingData{
    
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:kloadFriendlists success:^(id json) {
        
        NSArray *result = [json objectForKey:@"result"];
        NSMutableArray *bindingArr = [[NSMutableArray alloc] init];
        if (result.count>0) {
            for (int i=0; i<result.count; i++) {
                TCBindingModel *bindingModel = [[TCBindingModel alloc] init];
                [bindingModel setValues:result[i]];
                [bindingArr addObject:bindingModel];
            }
            dataArray = bindingArr;
        }else{
            dataArray = [[NSMutableArray alloc] init];
        }
            self.blanLabel.hidden=dataArray.count>0;
            [self.tabView reloadData];
    } failure:^(NSString *errorStr) {
        
    }];

}
#pragma mark -- setter or getter
- (UITableView *)tabView{
    if (_tabView==nil) {
        _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tabView.delegate = self;
        _tabView.dataSource = self;
        _tabView.tableFooterView = [[UIView alloc] init];
        
        [_tabView addSubview:self.blanLabel];
        self.blanLabel.hidden = YES;
    }
    return _tabView;
}
- (UILabel *)blanLabel{
    if (!_blanLabel) {
        _blanLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 100, kScreenWidth-120,0)];
        _blanLabel.text =@"您还未绑定亲友，绑定后血糖值异常时可短信通知家人。";
        _blanLabel.font = [UIFont systemFontOfSize:15];
        _blanLabel.numberOfLines = 0;
        _blanLabel.textAlignment = NSTextAlignmentCenter;
        _blanLabel.textColor = [UIColor grayColor];
        CGSize sizeHW = [_blanLabel.text sizeWithLabelWidth:kScreenWidth-120 font:[UIFont systemFontOfSize:15]];
        _blanLabel.frame = CGRectMake(60, 100, kScreenWidth-120,sizeHW.height);
    }
    return _blanLabel;
}
@end
