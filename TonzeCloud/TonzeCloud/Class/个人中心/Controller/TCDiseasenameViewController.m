//
//  TCDiseasenameViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDiseasenameViewController.h"
#import "TCDiseaseTableViewCell.h"

@interface TCDiseasenameViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>{

    NSArray        *_titleArray;
    UITableView    *_diseaseTabView;
        
    BOOL            isBack;
}
@end

@implementation TCDiseasenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"并发症及其他疾病";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.rigthTitleName = @"保存";
    _titleArray =@[@"高血压",@"肥胖",@"视网膜病变",@"肾病",@"神经病变",@"冠心病",@"脑血管病变",@"颈动脉、双下肢动脉病变",@"脂肪肝",@"胆石症",@"胆囊炎",@"高尿酸血症",@"糖尿病足",@"周围血管病变",@"甲状腺",@"酮症酸中毒",@"尿酮"];

    isBack = NO;
    
    [self initdiseaseView];
}

#pragma mark --UITableViewDelegate and UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"TCDiseaseTableViewCell";
    TCDiseaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[TCDiseaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *dict=nil;
    dict=@{@"title":_titleArray[indexPath.row],
           @"image":_indexArray[indexPath.row]};

    [cell cellDiseasenameWithLabor:dict];
      return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    isBack = YES;
    if (indexPath.section==0) {
        if ([_indexArray[indexPath.row] isEqualToString:@"1"]) {
            [_indexArray replaceObjectAtIndex:indexPath.row withObject:@"0"];
        } else {
            [_indexArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
        }
        [_diseaseTabView reloadData];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark -- Event response
#pragma mark 导航栏右侧按钮事件
-(void)rightButtonAction{
    [self.delegate returnDiseasename:_indexArray];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)leftButtonAction{
    if (isBack==YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次编辑？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- Custom Methods
#pragma mark--初始化界面
- (void)initdiseaseView{
    _diseaseTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth,kScreenHeight-kNewNavHeight) style:UITableViewStylePlain];
    _diseaseTabView.backgroundColor = [UIColor bgColor_Gray];
    _diseaseTabView.delegate=self;
    _diseaseTabView.dataSource=self;
    _diseaseTabView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_diseaseTabView];
    
}

@end
