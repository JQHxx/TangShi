//
//  TCRiceTypeViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRiceTypeViewController.h"
#import "TCMainDeviceHelper.h"
#import "TCRiceTableViewCell.h"
#import "HWPopTool.h"


@interface TCRiceTypeViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray   *riceTypeArray;
}

@property (nonatomic,strong)UITableView *riceTableView;

@end

@implementation TCRiceTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"米种";

    self.rightImageName = @"jtfb_ic_mi_tips";
   
    [self.view addSubview:self.riceTableView];
    
    [self reloadRiceData];
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return riceTypeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"RiceTableViewCell";
    TCRiceTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCRiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCRiceModel *rice=riceTypeArray[indexPath.row];
    cell.riceModel=rice;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TCRiceModel *rice=riceTypeArray[indexPath.row];
    self.selRiceCallBack(rice);
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
#pragma mark -- Event response
- (void)rightButtonAction{
    
    UIView *contentView =[[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius=5;
    contentView.clipsToBounds=YES;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"    降糖煲釆用独创的双胆专利技术，加上精准的电控烹饪程序，在烹饪过程中，通过有效水米分离，将米饭中的糖分进行物理分离，从而降低米饭中的含糖量。降糖米饭通过独有的烹饪程序，对米饭糖分进行程序分离，既实现烹饪的米饭糖分减少，又锁住米饭中的基本营养不流失。降糖煲特别注重米饭的口感，满足糖友对米饭的需求。\n\n    经过国际权威检测机构SGS标准技术测试，报告显示：同一米种，IH电饭煲米饭每100g总糖2.6g，而降糖煲米饭每100g总糖小于0.1g。";
    CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-100 font:[UIFont systemFontOfSize:15]];
    contentLabel.frame = CGRectMake(10, 30, kScreenWidth-100, size.height);
    [contentView addSubview:contentLabel];
    

    UIButton *consultBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, contentLabel.bottom+20, kScreenWidth-160, 40)];
    consultBtn.layer.cornerRadius = 15;
    consultBtn.backgroundColor = kSystemColor;
    consultBtn.tag =100;
    [consultBtn setTitle:@"知道了" forState:UIControlStateNormal];
    [consultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [consultBtn addTarget:self action:@selector(closeButton) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:consultBtn];
    
    contentView.frame = CGRectMake(0, 0, kScreenWidth-80, consultBtn.bottom+20);
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];

}

- (void)closeButton{
    [[HWPopTool sharedInstance] closeAnimation:0 WithBlcok:^{
        
    }];
}

#pragma mark  -- Private Methods
-(void)reloadRiceData{
    riceTypeArray=[TCMainDeviceHelper sharedTCMainDeviceHelper].riceArray;
    for (TCRiceModel *model in riceTypeArray) {
        if (model.riceId==self.selRiceModel.riceId) {
            model.isSelected=YES;
        }else{
            model.isSelected=NO;
        }
    }
    [self.riceTableView reloadData];
}

#pragma mark -- Setters and getters
#pragma mark 米种列表
-(UITableView *)riceTableView{
    if (!_riceTableView) {
        _riceTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _riceTableView.backgroundColor=[UIColor bgColor_Gray];
        _riceTableView.delegate=self;
        _riceTableView.dataSource=self;
        _riceTableView.tableFooterView=[[UIView alloc] init];
        [_riceTableView setSeparatorColor:[UIColor bgColor_Gray]];
    }
    return _riceTableView;
}

@end
