//
//  TCFriendSearchTableView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFriendSearchTableView.h"
#import "TCFriendSearchTableViewCell.h"
#import "TCHotWordView.h"

@interface TCFriendSearchTableView ()<TCDeleteHistoryDelegate>{
    
    CGFloat hotWordViewHeight;
}
@end
@implementation TCFriendSearchTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        self.dataSource=self;
        self.delegate=self;
        self.showsVerticalScrollIndicator=NO;
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return self;
}

#pragma mark -- Event Response
#pragma mark 清空历史记录
-(void)clearHistoryRecords{
    
    if ([_friendSearchDelegate respondsToSelector:@selector(friendSearchTableViewDidDeleteAllHistory:)]) {
        [_friendSearchDelegate friendSearchTableViewDidDeleteAllHistory:self];
    }
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    return _historyRecordsArray.count>0?_historyRecordsArray.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentifier=@"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = [UIColor whiteColor];
        TCHotWordView *hotWordView=[[TCHotWordView alloc] init];
        hotWordView.hotWordsArray=self.hotSearchWordsArray;
        __weak typeof(hotWordView) weakWordView=hotWordView;
        hotWordView.viewHeightRecalc=^(CGFloat height){
            hotWordViewHeight=height;
            weakWordView.frame=CGRectMake(0, 7, kScreenWidth, height);
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        hotWordView.hotSearchClick=^(NSString *title){
            if ([_friendSearchDelegate respondsToSelector:@selector(seleteHotSearch:didSelectTitle:)]) {
                [_friendSearchDelegate seleteHotSearch:self didSelectTitle:title];
            }
        };
        [cell.contentView addSubview:hotWordView];

        return cell;
    } else {
        static NSString *cellIdentifier=@"TCFriendSearchTableViewCell";
        TCFriendSearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCFriendSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor=[UIColor whiteColor];
        if (_historyRecordsArray.count>0) {
            cell.nameLabel.text = _historyRecordsArray[indexPath.row];
            cell.deleteSearchDelegate = self;
        }
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        if (_historyRecordsArray.count>0) {
            if ([_friendSearchDelegate respondsToSelector:@selector(friendSearchtableView:didSelectKeyword:)]) {
                [_friendSearchDelegate friendSearchtableView:self didSelectKeyword:_historyRecordsArray[indexPath.row]];
            }
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (self.hotSearchWordsArray.count>0) {
            return hotWordViewHeight+10;
        } else {
            return 40;
        }
    }
    if (_historyRecordsArray.count>0) {
        return 48;
    } else {
        return kScreenHeight-kNewNavHeight;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
       return self.hotSearchWordsArray.count>0?42:0.01;
    } else {
       return self.historyRecordsArray.count>0?42:0.01;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 0.01;
    }
    return _historyRecordsArray.count>0?60:0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    footView.backgroundColor=[UIColor bgColor_Gray];
    if (_historyRecordsArray.count>0&&section!=0) {
        UIButton *deleteAllBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, 20, 120, 30)];
        deleteAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteAllBtn setTitle:@"清空历史记录" forState:UIControlStateNormal];
        [deleteAllBtn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
        [deleteAllBtn addTarget:self action:@selector(clearHistoryRecords) forControlEvents:UIControlEventTouchUpInside];
        [deleteAllBtn.layer setBorderWidth:1];
        deleteAllBtn.layer.cornerRadius = 4;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){98.0/256, 98.0/256, 98.0/256,1 });
        [deleteAllBtn.layer setBorderColor:colorref];//边框颜色
        CGColorSpaceRelease(colorSpace);
        CGColorRelease(colorref);
        
        [footView addSubview:deleteAllBtn];
    }
    return footView;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 42)];
    headView.backgroundColor=[UIColor whiteColor];
    if (section==0&&self.hotSearchWordsArray.count>0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, kScreenWidth-50, 25)];
        lab.textColor=[UIColor darkGrayColor];
        lab.text=@"热门搜索";
        lab.font=[UIFont systemFontOfSize:14.0f];
        [headView addSubview:lab];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 41, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headView addSubview:lineLabel];
    }
    if (section==1&&self.historyRecordsArray.count>0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, kScreenWidth-50, 25)];
        lab.textColor=[UIColor darkGrayColor];
        lab.text=@"历史记录";
        lab.font=[UIFont systemFontOfSize:14.0f];
        [headView addSubview:lab];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 41, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headView addSubview:lineLabel];
    }
    return headView;
}
#pragma mark 删除单条记录
- (void)deleteSerachHistory:(NSString *)historyStr{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *title in _historyRecordsArray) {
        if (![title isEqualToString:historyStr]) {
            [array addObject:title];
        }
    }
    _historyRecordsArray = array;
    [NSUserDefaultsInfos putKey:@"sugarFriendHistory" andValue:_historyRecordsArray];
    if ([_friendSearchDelegate respondsToSelector:@selector(deleteHistoryRecord:)]) {
        [_friendSearchDelegate deleteHistoryRecord:_historyRecordsArray];
    }

}
#pragma mark -- Setters and Getters
#pragma mark 历史记录
-(void)setHistoryRecordsArray:(NSMutableArray *)historyRecordsArray{
    if (historyRecordsArray==nil) {
        historyRecordsArray=[[NSMutableArray alloc] init];
    }
    _historyRecordsArray=historyRecordsArray;
}
#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_friendSearchDelegate respondsToSelector:@selector(friendSearchTableViewWillBeginDragging:)]) {
        [_friendSearchDelegate friendSearchTableViewWillBeginDragging:self];
    }
}

@end
