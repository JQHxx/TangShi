//
//  TCGlucoseMeterHelpViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGlucoseMeterHelpViewController.h"
#import "TCMenuView.h"
#import "TCGlucoseMeterHelpCell.h"

@interface TCGlucoseMeterHelpViewController ()<TCMenuViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSInteger       _selectIndex;
    NSMutableArray  *_titleArray;
    NSArray         *_bindingInstructionsArray;
    NSArray         *_measuringInstructionsArray;
}
/// 菜单切换按钮
@property (nonatomic ,strong) TCMenuView *menuView;
///
@property (nonatomic ,strong) UITableView *glucoseMeterHelpTab;
@end

@implementation TCGlucoseMeterHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"测量帮助说明";
    
    _titleArray =[[NSMutableArray alloc]initWithObjects:@"血糖仪简介",@"绑定说明",@"测量操作说明", nil];
    _bindingInstructionsArray = @[@"bindingInstructions_001",@"bindingInstructions_002",@"bindingInstructions_003",@"bindingInstructions_004",@"bindingInstructions_005",@"bindingInstructions_006"];
    _measuringInstructionsArray =@[@"measuringInstructions_001.jpg",@"measuringInstructions_002.jpg",@"measuringInstructions_003.jpg",@"measuringInstructions_004.jpg"];
    [self setGlucoseMeterHelpUI];
}
#pragma mark ====== 血糖仪简介 =======
- (UIView *)tableFooterView{
 
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 750.5)];
    
    UIImageView *cloudImgView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, kScreenWidth - 36, 750/2)];
    cloudImgView.image = [UIImage imageNamed:@"xty02_img_introductionToThe001"];
    [headerView addSubview:cloudImgView];
    
    UILabel *lenLab= [[UILabel alloc]initWithFrame:CGRectMake(18, cloudImgView.bottom , kScreenWidth - 36, 0.5)];
    lenLab.backgroundColor = UIColorFromRGB(0xe5e5e5);
    [headerView addSubview:lenLab];
    
    UIImageView *equipmentImgView = [[UIImageView alloc]initWithFrame:CGRectMake(18,lenLab.bottom, kScreenWidth - 36, 750/2)];
    equipmentImgView.image = [UIImage imageNamed:@"xty02_img_introductionToThe002"];
    [headerView addSubview:equipmentImgView];
    
    return headerView;
}
#pragma mark ====== 布局UI =======
- (void)setGlucoseMeterHelpUI{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.glucoseMeterHelpTab];
}
#pragma mark ====== TCSlideViewDelegate =======
- (void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index{
    _selectIndex = index;
    if (_selectIndex == 0) {
        self.glucoseMeterHelpTab.tableFooterView = [self tableFooterView];
    }else{
        self.glucoseMeterHelpTab.tableFooterView = [UIView new];
    }
    [self.glucoseMeterHelpTab reloadData];
    [self.glucoseMeterHelpTab setContentOffset:CGPointMake(0,0) animated:NO];
}
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (_selectIndex) {
        case 1:
        {
            return 6;
        }
            break;
        case 2:
        {
            return 4;
        }
            break;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (_selectIndex) {
        case 1:
        {
            return 1063/2;
        }
            break;
        case 2:
        {
            return 1745/2;
        }
            break;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCGlucoseMeterHelpCell *cell = [[TCGlucoseMeterHelpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    switch (_selectIndex) {
        case 1:
        {
            cell.imgHight = 1063/2;
            cell.img.image =[UIImage imageNamed:_bindingInstructionsArray[indexPath.row]];
        }
            break;
        case 2:
        {
            cell.imgHight = 1745/2;
            cell.img.image = [UIImage imageNamed:_measuringInstructionsArray[indexPath.row]];
        }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark -- Event Response
-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        _selectIndex++;
        if (_selectIndex>_titleArray.count-1) {
            _selectIndex=_titleArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        _selectIndex--;
        if (_selectIndex<0) {
            _selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}
#pragma mark ====== Setter =======
-(TCMenuView *)menuView{
    if (!_menuView) {
        _menuView=[[TCMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 92/2 - 0.5)];
        _menuView.delegate=self;
        _menuView.menusArray = _titleArray;
    }
    return _menuView;
}
-(UITableView *)glucoseMeterHelpTab{
    if (!_glucoseMeterHelpTab) {
        _glucoseMeterHelpTab = [[UITableView alloc]initWithFrame:CGRectMake(0, _menuView.bottom, kScreenWidth, kScreenHeight - kNewNavHeight - _menuView.height) style:UITableViewStylePlain];
        _glucoseMeterHelpTab.dataSource = self;
        _glucoseMeterHelpTab.delegate = self;
        _glucoseMeterHelpTab.tableFooterView = [self tableFooterView];
        _glucoseMeterHelpTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _glucoseMeterHelpTab.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_glucoseMeterHelpTab addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_glucoseMeterHelpTab addGestureRecognizer:swipGestureRight];
    }
    return _glucoseMeterHelpTab;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
