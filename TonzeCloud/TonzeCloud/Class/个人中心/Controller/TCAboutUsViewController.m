//
//  TCAboutUsViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAboutUsViewController.h"
#import "TCCompanyViewController.h"
#import "TCSexViewController.h"
#import "TCBasewebViewController.h"

#define PHONE_NUMBER @"400-900-4288"
#define COOPERATEPHONE_NUMBER @"13823391609"

@interface TCAboutUsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView    *table;
}
@end

@implementation TCAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"关于我们";
    [self initRootView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10-03" type:1];
#endif
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10-03" type:2];
#endif
}
#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.textColor = UIColorFromRGB(0x343434);
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"公司简介";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
            break;
        case 1:
            cell.textLabel.text = @"平台介绍";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
            break;
        case 2:
            cell.textLabel.text = @"用户协议";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.textColor = UIColorFromRGB(0xBDBDBD);
            break;
        case 3:
            cell.textLabel.text = @"客服电话";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = PHONE_NUMBER;
            cell.detailTextLabel.textColor = kbgBtnColor;
            break;
        case 4:
            cell.textLabel.text = @"商务合作";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = COOPERATEPHONE_NUMBER;
            cell.detailTextLabel.textColor = kbgBtnColor;
            break;

        default:
            break;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor grayColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 170;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170)];
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, 20, 80, 80)];
    imgView.image=[UIImage imageNamed:@"ic_tangshi_logo"];
    [header addSubview:imgView];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, imgView.bottom+10, 150, 20)];
    titleLabel.textColor=kSystemColor;
    titleLabel.font=[UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=APP_DISPLAY_NAME;
    [header addSubview:titleLabel];
    
    UILabel *versionLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, titleLabel.bottom, 150, 20)];
    versionLabel.textColor=[UIColor lightGrayColor];
    versionLabel.font=[UIFont systemFontOfSize:12];
    versionLabel.textAlignment=NSTextAlignmentCenter;
    versionLabel.text=[NSString stringWithFormat:@"V%@", APP_VERSION];
    [header addSubview:versionLabel];
    
    return header;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            [MobClick event:@"104_003010"];

            TCCompanyViewController *CompanyVC = [[TCCompanyViewController alloc] init];
            CompanyVC.isCompany=YES;
            [self.navigationController pushViewController   :CompanyVC animated:YES];
        }
            break;
        case 1:
        {
            [MobClick event:@"104_003011"];

            TCCompanyViewController *CompanyVC = [[TCCompanyViewController alloc] init];
            CompanyVC.isCompany=NO;
            [self.navigationController pushViewController:CompanyVC animated:YES];
        }

            break;
        case 2:
        {
            [MobClick event:@"104_003012"];

            NSString *urlString = [NSString stringWithFormat:@"http://api.360tj.com/article/agreement.html"];
            TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
            webVC.type=BaseWebViewTypeUserAgreement;
            webVC.titleText=@"糖士用户协议";
            webVC.urlStr=urlString;
            [self.navigationController pushViewController:webVC animated:YES];
            }
            break;
        case 3:
        {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"003-10-07"];
#endif
            NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",PHONE_NUMBER];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        case 4:
        {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"003-10-08"];
#endif
            NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",COOPERATEPHONE_NUMBER];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        default:
            break;
    }
}
#pragma mark --Custom Methods
#pragma mark --初始化界面
-(void)initRootView{
    table=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
    table.dataSource=self;
    table.delegate=self;
    table.backgroundColor = [UIColor bgColor_Gray];
    table.showsVerticalScrollIndicator=NO;
    table.tableFooterView=[[UIView alloc] init];
    table.bounces=NO;
    [self.view addSubview:table];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0,kScreenHeight-70, kScreenWidth, 50)];
    lab.numberOfLines = 0;
    lab.text = @"深圳市天际云科技有限公司\nAll Rights Reserved";
    lab.textColor = [UIColor lightGrayColor];
    lab.font = [UIFont systemFontOfSize:14.0f];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];

}

@end
