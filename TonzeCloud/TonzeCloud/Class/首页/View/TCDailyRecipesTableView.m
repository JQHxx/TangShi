//
//  TCDailyRecipesTableView.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDailyRecipesTableView.h"
#import "TCRecipesTableViewCell.h"
#import "TCRecipeModel.h"

@interface TCDailyRecipesTableView (){
    NSArray    *keysArr;
}

@end

@implementation TCDailyRecipesTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.delegate=self;
        self.dataSource=self;
        self.showsVerticalScrollIndicator=NO;
    }
    return self;
}

- (void)setHeadTitles:(NSArray *)headTitles{
    if (_headTitles==nil) {
        _headTitles=[[NSArray alloc] init];
    }
    _headTitles=headTitles;
}
- (void)setDataMenuArray:(NSDictionary *)dataMenuDic{
    if (_dataMenuDic==nil) {
        _dataMenuDic=[[NSDictionary alloc] init];
    }
    _dataMenuDic=dataMenuDic;

}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _headTitles.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *recepeList=[_dataMenuDic objectForKey:_headTitles[section]];
    return recepeList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCRecipesTableViewCell";
    TCRecipesTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCRecipesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSArray *recepeList=[_dataMenuDic objectForKey:_headTitles[indexPath.section]];
    TCRecipeModel *recipe=recepeList[indexPath.row];
    [cell cellRealodActionWithRecipe:recipe];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _headTitles[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,10,0,0)];
    }
}
@end
