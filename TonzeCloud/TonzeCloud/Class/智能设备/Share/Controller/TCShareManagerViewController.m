//
//  TCShareManagerViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCShareManagerViewController.h"
#import "TCShareDeviceViewController.h"
#import "TCShareTableViewCell.h"
#import "HttpRequest.h"
#import "AppDelegate.h"
#import "TCShareModel.h"
#import "TCDeviceShareHelper.h"
#import "SVProgressHUD.h"

@interface TCShareManagerViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  *shareList;
    AppDelegate     *appDelegate;
}

@property (nonatomic,strong)UITableView *shareTableView;
@property (nonatomic,strong)UIButton    *shareDeviceBtn;
@property (nonatomic,strong)UIView      *blankShareView;

@end

@implementation TCShareManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"分享管理";
    
    shareList=[[NSMutableArray alloc] init];
    appDelegate=kAppDelegate;
    
    [self.view addSubview:self.shareTableView];
    [self.shareTableView addSubview:self.blankShareView];
    self.blankShareView.hidden=YES;
    [self.view addSubview:self.shareDeviceBtn];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadShareUserList];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shareList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"ShareTableViewCell";
    TCShareTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCShareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCShareModel *model=shareList[indexPath.row];
    cell.shareModel=model;
    
    
    UIButton *delBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 20, 40, 40)];
    [delBtn setImage:[UIImage imageNamed:@"pub_ic_del"] forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(deleteShareAction:) forControlEvents:UIControlEventTouchUpInside];
    delBtn.tag=indexPath.row;
    [cell.contentView addSubview:delBtn];
    
    return cell;
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


#pragma mark -- Event Response
-(void)shareDeviceAction:(UIButton *)sender{
    TCShareDeviceViewController *shareDeviceVC=[[TCShareDeviceViewController alloc] init];
    shareDeviceVC.model=self.deviceModel;
    [self.navigationController pushViewController:shareDeviceVC animated:YES];
}

#pragma mark 取消分享设备
-(void)deleteShareAction:(UIButton *)sender{
    __weak TCShareModel *model=shareList[sender.tag];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除提示" message:@"确定取消该用户的设备控制权吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [HttpRequest cancelShareDeviceWithAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withInviteCode:model.invite_code didLoadData:^(id result, NSError *err) {
            if (err) {
                if (err.code==4031003) {
                    [appDelegate updateAccessToken];
                }
                [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
            } else {
                [shareList removeObject:model];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.blankShareView.hidden=shareList.count>0;
                    [weakSelf.shareTableView reloadData];
                });
            }
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 获取分享用户列表
-(void)loadShareUserList{
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    //获取用户的分享列表
    kSelfWeak;
    [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                }else{
                    MyLog(@"获取分享列表，result:%@",result);
                    
                    NSMutableArray *shareArr=[[NSMutableArray alloc]init];
                    for (NSDictionary *tem in result) {
                        if ([[tem objectForKey:@"device_id"] integerValue]==self.deviceModel.device_id&&[[userDic objectForKey:@"user_id"] integerValue]==[[tem objectForKey:@"from_id"] integerValue]) {
                            TCShareModel *model = [[TCShareModel alloc] init];
                            [model setValues:tem];
                            model.to_id = tem[@"user_id"];
                            model.create_date=[tem objectForKey:@"gen_date"];
                            model.user_nickname=tem[@"to_name"];
                            if ([model.state isEqualToString:@"accept"]) {
                                [shareArr addObject:model];
                            }
                        }
                    }
                    
                    NSArray *tempArr=[shareArr sortedArrayUsingComparator:^NSComparisonResult(TCShareModel *obj1, TCShareModel *obj2) {
                        return [obj2.create_date compare:obj1.create_date];//降序
                    }];
                    shareList=[NSMutableArray arrayWithArray:tempArr];
                    self.blankShareView.hidden=shareList.count>0;
                    [self.shareTableView reloadData];
                }
            });
        });
    }];
}



#pragma mark -- Getters and Setters
#pragma mark 分享管理
-(UITableView *)shareTableView{
    if (!_shareTableView) {
        _shareTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-50) style:UITableViewStylePlain];
        _shareTableView.dataSource=self;
        _shareTableView.delegate=self;
        _shareTableView.backgroundColor=[UIColor bgColor_Gray];
        _shareTableView.tableFooterView=[[UIView alloc] init];
    }
    return _shareTableView;
}

#pragma mark 分享设备
-(UIButton *)shareDeviceBtn{
    if (!_shareDeviceBtn) {
        _shareDeviceBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        [_shareDeviceBtn setTitle:@"分享设备" forState:UIControlStateNormal];
        [_shareDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _shareDeviceBtn.backgroundColor=kSystemColor;
        [_shareDeviceBtn addTarget:self action:@selector(shareDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareDeviceBtn;
}

#pragma mark 空白页
-(UIView *)blankShareView{
    if (!_blankShareView) {
        _blankShareView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight-50)];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-140)/2, 80, 140, 140)];
        imgView.image=[UIImage imageNamed:@"分享icon"];
        [_blankShareView addSubview:imgView];
        
        UILabel *shareTitleLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+10, kScreenWidth-60, 30)];
        shareTitleLab.text=@"您还没有分享给其他用户";
        shareTitleLab.font=[UIFont systemFontOfSize:15];
        shareTitleLab.textColor=[UIColor colorWithHexString:@"#696969"];
        shareTitleLab.textAlignment=NSTextAlignmentCenter;
        [_blankShareView addSubview:shareTitleLab];
        
        UILabel *shareTipsLab=[[UILabel alloc] initWithFrame:CGRectMake(20, shareTitleLab.bottom, kScreenWidth-40, 30)];
        shareTipsLab.text=@"添加您的亲人、朋友一起分享智能生活";
        shareTipsLab.font=[UIFont systemFontOfSize:13];
        shareTipsLab.textColor=[UIColor colorWithHexString:@"#BBBBBB"];
        shareTipsLab.textAlignment=NSTextAlignmentCenter;
        [_blankShareView addSubview:shareTipsLab];
        
    }
    return _blankShareView;
}

@end
