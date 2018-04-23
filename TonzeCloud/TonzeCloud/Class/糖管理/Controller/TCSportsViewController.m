//
//  TCSportsViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSportsViewController.h"
#import "TCSportTableViewCell.h"

@interface TCSportsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray    *sportArray;
}
@property (nonatomic,strong)UITableView *sportTypeTableView;

@end

@implementation TCSportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"运动类型";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"sports" ofType:@"plist"];
    sportArray=[[NSArray alloc] initWithContentsOfFile:path];
    
    [self.view addSubview:self.sportTypeTableView];
}
#pragma mark -- UITableViewDelegate and UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sportArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCSportTableViewCell";
    TCSportTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TCSportTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    NSDictionary *dict=sportArray[indexPath.row];
    
    cell.imgView.image = [UIImage imageNamed:dict[@"image"]];
    cell.sportType.text =dict[@"name"];
    cell.consumeLab.text= [NSString stringWithFormat:@"%@千卡／60分钟",dict[@"calory"]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict=sportArray[indexPath.row];
    if ([_controllerDelegate respondsToSelector:@selector(sportsViewControllerDidSelectDict:)]) {
        [_controllerDelegate sportsViewControllerDidSelectDict:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- Getters and Setters
#pragma mark 个人数据
-(UITableView *)sportTypeTableView{
    if (_sportTypeTableView==nil) {
        _sportTypeTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 1, kScreenWidth, kRootViewHeight - 1) style:UITableViewStylePlain];
        _sportTypeTableView.delegate=self;
        _sportTypeTableView.dataSource=self;
        _sportTypeTableView.showsVerticalScrollIndicator=NO;
        _sportTypeTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        _sportTypeTableView.tableFooterView=[[UIView alloc] init];
    }
    return _sportTypeTableView;
}
@end
