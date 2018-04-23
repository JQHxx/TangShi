//
//  TCArticleTableView.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCArticleTableView.h"
#import "TCArticleTableViewCell.h"
#import "TCArticleModel.h"
#import "TCBasewebViewController.h"
#import "TCArticleLibraryViewController.h"
@implementation TCArticleTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.delegate=self;
        self.dataSource=self;
        self.showsVerticalScrollIndicator=NO;
        self.tableFooterView=[[UIView alloc] init];
    }
    return self;
}

-(void)setArticlesArray:(NSMutableArray *)articlesArray{
    if (_articlesArray==nil) {
        _articlesArray=[[NSMutableArray alloc] init];
    }
    _articlesArray=articlesArray;
}

-(void)setType:(NSInteger)type{
    _type=type;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.articlesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCArticleTableViewCell";
    TCArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCArticleModel *article=self.articlesArray[indexPath.row];
    [cell cellDisplayWithModel:article searchText:@""];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.type==0?40:0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.type==0) {
        UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        headView.backgroundColor=[UIColor whiteColor];
        
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
        lineLab.backgroundColor=kSystemColor;
        [headView addSubview:lineLab];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(lineLab.right+5, 10, 100, 20)];
        titleLab.text=@"推荐";
        titleLab.font=[UIFont systemFontOfSize:15];
        [headView addSubview:titleLab];
        
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(10, 39, kScreenWidth-10, 0.5);
        line.backgroundColor = kLineColor.CGColor;
        [headView.layer addSublayer:line];
        
        return headView;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCArticleModel *article=self.articlesArray[indexPath.row];
    if ([_articleDetagate respondsToSelector:@selector(articleTableViewDidSelectedCellWithArticle:)]) {
        [_articleDetagate articleTableViewDidSelectedCellWithArticle:article];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}
@end
