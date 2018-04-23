//
//  TCRemindTimeViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRemindTimeViewController.h"
#import "TCRemindTimeCell.h"

@interface TCRemindTimeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_timeTitleArray;
}
@property (nonatomic, strong) UITableView *remindTimeTab;

@end

@implementation TCRemindTimeViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.checkImgBlock) {
        self.checkImgBlock(_checkImgArr);
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"重复方式";
    _timeTitleArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    [self setRemindTimeVC];
}
#pragma mark ====== Bulid UI =======
- (void)setRemindTimeVC{
    [self.view addSubview:self.remindTimeTab];
}
#pragma mark ====== UITableViewDelegate,UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *remindTimeIdentifier  = @"remindTimeIdentifier";
    TCRemindTimeCell *remindTimeCell =[tableView dequeueReusableCellWithIdentifier:remindTimeIdentifier];
    if (!remindTimeCell) {
        remindTimeCell = [[TCRemindTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remindTimeIdentifier];
    }
    remindTimeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = nil;
    dict = @{@"title":_timeTitleArray[indexPath.row],
             @"checkImg":_checkImgArr[indexPath.row]};
    [remindTimeCell cellDisplayWithDict:dict];
    return remindTimeCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_checkImgArr[indexPath.row] isEqualToString:@"1"]) {
        [_checkImgArr replaceObjectAtIndex:indexPath.row withObject:@"0"];
    } else {
        [_checkImgArr replaceObjectAtIndex:indexPath.row withObject:@"1"];
    }
    [_remindTimeTab reloadData];
}
#pragma mark ====== Getter && Setter =======
- (UITableView *)remindTimeTab{
    if (!_remindTimeTab) {
        _remindTimeTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _remindTimeTab.backgroundColor = [UIColor bgColor_Gray];
        _remindTimeTab.delegate = self;
        _remindTimeTab.dataSource = self;
        _remindTimeTab.rowHeight = 44;
        _remindTimeTab.tableFooterView = [UIView new];
    }
    return _remindTimeTab;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
