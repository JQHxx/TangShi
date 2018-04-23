//
//  TCAddRelativeFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddRelativeFriendViewController.h"
#import "TCAddFriendModel.h"
#import "TCAddFriendResultTableViewCell.h"
#import "TCMyFriendViewController.h"
#import "TCTodayMissionViewController.h"

@interface TCAddRelativeFriendViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray  *friendArr;
}
@property (nonatomic ,strong)UITableView *friendTab;
@property (nonatomic ,strong)UIButton    *addButton;
@end

@implementation TCAddRelativeFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"添加亲友";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self.view addSubview:self.friendTab];
    [self.view addSubview:self.addButton];
    
}
#pragma mark -- UITableViewDelegate or UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCAddFriendResultTableViewCell";
    TCAddFriendResultTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[TCAddFriendResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell cellAddFriendModel:self.FriendModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

#pragma mark -- Event Response
-(void)leftButtonAction{
    if (_isTaskListLogin) {
        NSArray *temArray = self.navigationController.viewControllers;
        for(UIViewController *temVC in temArray)
        {
            if ([temVC isKindOfClass:[TCTodayMissionViewController class]])
            {
                [self.navigationController popToViewController:temVC animated:YES];
            }
        }
    }else{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[TCMyFriendViewController class]]) {
                TCMyFriendViewController *myFriend =(TCMyFriendViewController *)controller;
                [self.navigationController popToViewController:myFriend animated:YES];
            }
        }
    }
}

#pragma mark -- 添加亲友
- (void)addReliveFriend{
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&doSubmit=1",self.FriendModel.mobile];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFriendRequest body:body success:^(id json) {
        [weakSelf.view makeToast:@"已添加对方为亲友，需等待对方同意" duration:1.0 position:CSToastPositionBottom];
        [TCHelper sharedTCHelper].isFriendResquest  = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [weakSelf getTaskPointsWithActionType:14 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
            if (clickIndex ==1001 || isBack) {
                if (weakSelf.isTaskListLogin) {
                    NSArray *temArray = self.navigationController.viewControllers;
                    for(UIViewController *temVC in temArray)
                    {
                        if ([temVC isKindOfClass:[TCTodayMissionViewController class]])
                        {
                            [self.navigationController popToViewController:temVC animated:YES];
                        }
                    }
                }else{
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[TCMyFriendViewController class]]) {
                            TCMyFriendViewController *myFriend =(TCMyFriendViewController *)controller;
                            [weakSelf.navigationController popToViewController:myFriend animated:YES];
                        }
                    }
                }
            }
        }];// 获取积分

    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}



#pragma mark -- setter or getter
- (UITableView *)friendTab{
    if (_friendTab==nil) {
        _friendTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight/2) style:UITableViewStylePlain];
        _friendTab.backgroundColor = [UIColor bgColor_Gray];
        _friendTab.delegate = self;
        _friendTab.dataSource = self;
        _friendTab.tableFooterView = [[UIView alloc] init];
    }
    return _friendTab;
}

#pragma mark -- 添加亲友
- (UIButton *)addButton{
    if (_addButton==nil) {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(60, kScreenHeight-90, kScreenWidth-120, 40)];
        [_addButton setTitle:@"添加亲友" forState:UIControlStateNormal];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_addButton setBackgroundColor:kbgBtnColor];
        [_addButton addTarget:self action:@selector(addReliveFriend) forControlEvents:UIControlEventTouchUpInside];
        _addButton.layer.cornerRadius =5;
    }
    return _addButton;

}
@end
