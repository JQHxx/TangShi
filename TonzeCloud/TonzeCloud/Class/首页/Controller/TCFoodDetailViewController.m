//
//  TCFoodDetailViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodDetailViewController.h"
#import "TCFoodDetailTableViewCell.h"
#import "TCFoodModel.h"
#import "TCRecordDietViewController.h"

@interface TCFoodDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{

    UITableView    *foodDetailTab;
    NSMutableArray *toolArray;
    NSArray        *_titleArray;
    NSMutableArray *_parameterArray;
    
    TCFoodModel    *foodModel;
    UIImageView    *bgImage;
    UILabel        *bglabel;
}
@end
@implementation TCFoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"食物详情";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    toolArray = [[NSMutableArray alloc] init];
    _titleArray=@[@"热量",@"碳水化合物",@"脂肪",@"蛋白质",@"膳食纤维",@"维生素A",@"维生素B1",@"维生素B2",@"维生素B3",@"维生素C",@"维生素E",@"胡萝卜素",@"胆固醇",@"钠",@"钙",@"铁",@"钾",@"锌",@"镁",@"铜",@"锰",@"磷",@"碘",@"硒"];
    _parameterArray=[[NSMutableArray alloc] init];
    foodModel=[[TCFoodModel alloc] init];
    
    [self inittFoodDetailView];
     [self requestFoodDetailData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:[NSString stringWithFormat:@"004-06-03:%ld",self.food_id] type:1];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:[NSString stringWithFormat:@"004-06-03:%ld",self.food_id] type:2];
}
#pragma mark ====== 返回 =======
- (void)leftButtonAction{
    if (self.leftActionBlock) {
        self.leftActionBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 请求食物详情信息
- (void)requestFoodDetailData{

    NSString *urlString = [NSString stringWithFormat:@"id=%ld",(long)_food_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodDetail body:urlString success:^(id json) {
        NSDictionary *dataDic = [json objectForKey:@"result"];
        [foodModel setValues:dataDic];
        if (foodModel.images.count!=0) {
            [_parameterArray addObject:[foodModel.images[0] objectForKey:@"image_url"]];
        }else{
            [_parameterArray addObject:@""];
        }
        [_parameterArray addObject:foodModel.name];
        [_parameterArray addObject:[NSString stringWithFormat:@"%ld千卡/100克",(long)foodModel.energykcal]];
        [_parameterArray addObject:[NSString stringWithFormat:@"%@",kIsEmptyString(foodModel.gi)?@"":foodModel.gi]];
        [_parameterArray addObject:[self string:foodModel.energykcal unit:@"千卡"]];
        [_parameterArray addObject:[self string:foodModel.carbohydrate unit:@"克"]];
        [_parameterArray addObject:[self string:foodModel.fat unit:@"克"]];
        [_parameterArray addObject:[self string:foodModel.protein unit:@"克"]];
        [_parameterArray addObject:[self string:foodModel.insolublefiber unit:@"克"]];
        [_parameterArray addObject:[self string:foodModel.totalvitamin unit:@"微克"]];
        [_parameterArray addObject:[self string:foodModel.thiamine unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.riboflavin unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.niacin unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.vitaminC unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.vitaminE unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.carotene unit:@"微克"]];
        [_parameterArray addObject:[self string:foodModel.cholesterol unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.sodium unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.calcium unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.iron unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.potassium unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.zinc unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.magnesium unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.copper unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.manganese unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.phosphorus unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.iodine unit:@"毫克"]];
        [_parameterArray addObject:[self string:foodModel.selenium unit:@"微克"]];

        [foodDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 拼接字符串
- (NSString *)string:(NSInteger)intvalue unit:(NSString *)unit{
    NSString *string = intvalue==0?[NSString stringWithFormat:@"--%@",unit]:[NSString stringWithFormat:@"%ld%@",(long)intvalue,unit];
    return string;

}
#pragma mark --UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section!=2&&_parameterArray.count!=0) {
        return 1;
    }
    return _parameterArray.count-4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFoodDetailTableViewCell";
    TCFoodDetailTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex:0];
    }
    if (indexPath.section == 0) {
        cell.parameterLabel.hidden = YES;
        NSString *url = [NSString stringWithFormat:@"%@",_parameterArray[0]];
        [cell.foodImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        cell.foodName.text = _parameterArray[1];
        cell.foodName.textColor = [UIColor blackColor];
        cell.foodEnergy.text = [NSString stringWithFormat:@"%@",_parameterArray[2]];
        cell.foodEnergy.textColor = [UIColor grayColor];
        NSInteger titleLength = [NSString stringWithFormat:@"%@", cell.foodEnergy.text].length;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:   cell.foodEnergy.text];
        NSRange r1 = NSMakeRange(0, titleLength-7);
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r1];
        [cell.foodEnergy setAttributedText:attributedString];
    }else if(indexPath.section ==1){
        cell.GILabel.text = @"GI（血糖生成指数）";
        NSLog(@"%@",_parameterArray[indexPath.row+3]);
        NSString *parameter = [_parameterArray[indexPath.row+3]isEqualToString:@""]?@"--":[NSString stringWithFormat:@"%@",_parameterArray[indexPath.row+3]];
        cell.parameterLabel.text =parameter;
    }
    else {
        cell.GILabel.text = _titleArray[indexPath.row];
        NSString *parameter = [NSString stringWithFormat:@"%@",_parameterArray[indexPath.row+4]];
        cell.parameterLabel.text =parameter;
        
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@",_parameterArray[indexPath.row+4]]];
        if (indexPath.row<5&&indexPath.row>0) {
            [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f39800"] range:NSMakeRange(0, attributeStr.length-1)];
        } else {
            [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f39800"] range:NSMakeRange(0, attributeStr.length-2)];
        }
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0, attributeStr.length-2)];
         cell.parameterLabel.attributedText=attributeStr;

    }
    cell.selectionStyle=UIViewAutoresizingNone;
    cell.autoresizesSubviews = YES;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 58;
    }
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==1) {
        return 36;
    }else if (section == 0){
        return 10;
    }
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *recordsView = [[UIView alloc] initWithFrame:CGRectZero];
    if (section == 1) {
        recordsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 36)];
        recordsView.backgroundColor = [UIColor bgColor_Gray];
        UILabel *titlelab = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, kScreenWidth, 16)];
        titlelab.text = @"营养成分(每100克)";
        titlelab.font = [UIFont systemFontOfSize:13];
        titlelab.textColor = [UIColor grayColor];
        [recordsView addSubview:titlelab];
    }else if(section == 0){
        recordsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        recordsView.backgroundColor = [UIColor bgColor_Gray];
    }
    return recordsView;
}
#pragma mark -- 初始化界面
- (void)inittFoodDetailView{
    
    foodDetailTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth,kRootViewHeight)];
    foodDetailTab.delegate = self;
    foodDetailTab.dataSource = self;
    foodDetailTab.showsVerticalScrollIndicator=NO;
    [foodDetailTab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:foodDetailTab];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
