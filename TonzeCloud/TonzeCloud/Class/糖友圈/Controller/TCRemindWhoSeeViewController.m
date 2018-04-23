//
//  TCRemindWhoSeeViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#define kIndexKey @"title"
#define kArrayKey @"array"

#import "TCRemindWhoSeeViewController.h"
#import "TCRemindWhoSeeCell.h"
#import "TCFollowListModel.h"
#import "TCGroupedData.h"

@interface TCRemindWhoSeeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *remindWhoSeeTab;
/// 索引数据
@property (nonatomic ,strong)  NSArray *indexArr;
///
@property (nonatomic ,strong) NSMutableArray *FollowListArray;
/// 关注人数据
@property (nonatomic ,strong) NSMutableArray *nickNameArray;
///
@property (nonatomic ,strong) TCBlankView *blanKView;

@end

@implementation TCRemindWhoSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"提醒谁看";
    self.leftTitleName = @"取消";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self setRemindWhoSeeVC];
    [self loadRemindWhoSeeData];
}
#pragma mark ====== 布局UI =======

- (void)setRemindWhoSeeVC{
    [self.view addSubview:self.remindWhoSeeTab];
}
#pragma mark ====== 加载数据 =======

- (void)loadRemindWhoSeeData{
    
    NSString *body = [NSString stringWithFormat:@"page_num=0&page_size=0&role_type=0"];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KLoadFoucsOnList body:body success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blanKView.hidden = YES;
            for (NSDictionary *dict in resultArray) {
                TCFollowListModel *followListModel = [TCFollowListModel new];
                [followListModel setValues:dict];
                [weakSelf.nickNameArray addObject:followListModel.nick_name];
                [weakSelf.FollowListArray addObject:followListModel];
            }
            weakSelf.indexArr = [TCGroupedData getGroupedDictionaryArray:_nickNameArray indexKey:kIndexKey arrayKey:kArrayKey];
        }else{
            weakSelf.blanKView.hidden = NO;
        }
        [weakSelf.remindWhoSeeTab reloadData];
    } failure:^(NSString *errorStr) {
        weakSelf.blanKView.hidden = NO;
       [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }]; 
}
#pragma mark ====== 返回按钮 =======

-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ====== UITableViewDelegate  =======
#pragma mark ====== UITableViewDataSource =======
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _indexArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = [self.indexArr objectAtIndex:section];
    NSArray *array = [dic objectForKey:kArrayKey];
    return array.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
//右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0 ; i < self.indexArr.count; i++) {
        NSDictionary  *dic = [self.indexArr objectAtIndex:i];
        [array addObject:[dic objectForKey:kIndexKey]];
    }
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
//    NSInteger count = 0;
//    for(NSDictionary *header in self.indexArr){
//        NSDictionary *dic = header;
//        NSArray *array = [dic objectForKey:kArrayKey];
//        
//        if([header isEqualToString:title]){
//            return count;
//        }
//        count ++;
//    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    titleView.backgroundColor = [UIColor bgColor_Gray];
    UILabel  *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 20)];
    NSDictionary *dic = [_indexArr objectAtIndex:section];
    NSString *title = [dic objectForKey:kIndexKey];
    titleLab.font = kFontWithSize(13);
    titleLab.text = title;
    titleLab.textColor = kSystemColor;
    
    [titleView addSubview:titleLab];
    
    return titleView;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    TCRemindWhoSeeCell *remindWhoSeeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!remindWhoSeeCell) {
        remindWhoSeeCell = [[TCRemindWhoSeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dic = [self.indexArr objectAtIndex:indexPath.section];
    NSArray *nameArray = [dic objectForKey:kArrayKey];
    for (NSInteger i = 0; i < _FollowListArray.count; i++) {
        TCFollowListModel *followListModel  = _FollowListArray[i];
        if ([followListModel.nick_name isEqualToString:nameArray[indexPath.row]]) {
            [remindWhoSeeCell cellWithFollowListModel:followListModel];
        }
    }
    return remindWhoSeeCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger useId = 0 ;
    NSInteger role_type_ed = 0;
    NSDictionary *dic = [self.indexArr objectAtIndex:indexPath.section];
    NSArray *nameArray = [dic objectForKey:kArrayKey];
    NSString *niceNameStr = nameArray[indexPath.row];
    for (NSInteger i = 0; i < _FollowListArray.count; i++) {
        TCFollowListModel *followListModel  = _FollowListArray[i];
        if ([followListModel.nick_name isEqualToString:niceNameStr]) {
            useId = followListModel.user_id;
            role_type_ed = followListModel.role_type_ed;
        }
    }
    MyLog(@"选择的用户为%@ 用户id为%ld",niceNameStr,useId);
    NSString *niceName = [NSString stringWithFormat:@"@%@",niceNameStr];
    if (self.remindUsersBlock) {
        self.remindUsersBlock(niceName,useId,role_type_ed);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ====== Getter =======

- (UITableView *)remindWhoSeeTab{
    if (!_remindWhoSeeTab) {
        _remindWhoSeeTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _remindWhoSeeTab.delegate = self;
        _remindWhoSeeTab.dataSource = self;
        _remindWhoSeeTab.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _remindWhoSeeTab.showsHorizontalScrollIndicator = NO;
        _remindWhoSeeTab.showsVerticalScrollIndicator = NO;
        _remindWhoSeeTab.backgroundColor = [UIColor bgColor_Gray];
        _remindWhoSeeTab.sectionIndexBackgroundColor = [UIColor whiteColor]; // 更改索引
        _remindWhoSeeTab.sectionIndexColor = kSystemColor;
        [_remindWhoSeeTab addSubview:self.blanKView];
        self.blanKView.hidden = YES;
    }
    return _remindWhoSeeTab;
}
- (TCBlankView *)blanKView{
    if (!_blanKView) {
        _blanKView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无关注好友"];
    }
    return _blanKView;
}
- (NSArray *)indexArr{
    if (!_indexArr) {
        _indexArr = [NSArray array];
    }
    return _indexArr;
}
- (NSMutableArray *)FollowListArray{
    if (!_FollowListArray) {
        _FollowListArray = [NSMutableArray array];
    }
    return _FollowListArray;
}
- (NSMutableArray *)nickNameArray{
    if (!_nickNameArray) {
        _nickNameArray = [NSMutableArray array];
    }
    return _nickNameArray;
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
