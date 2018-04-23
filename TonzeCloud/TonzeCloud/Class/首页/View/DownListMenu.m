//
//  DownListMenu.m
//  TangShiService
//
//  Created by vision on 17/7/18.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "DownListMenu.h"
#import "TCMenuModel.h"

@interface DownListMenu ()<UITableViewDelegate,UITableViewDataSource>{
    UIView        *coverView;
    UITableView   *menuTableView;
    
    CGFloat       viewHeight;
}


@end

@implementation DownListMenu

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        coverView=[[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        coverView.backgroundColor=[UIColor blackColor];
        coverView.userInteractionEnabled=YES;
        
        UIGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backUpCoverAction)];
        [coverView addGestureRecognizer:tapGesture];
        
        viewHeight=frame.size.height;
        
        menuTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, frame.size.height) style:UITableViewStylePlain];
        menuTableView.delegate=self;
        menuTableView.dataSource=self;
        
    }
    return self;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    TCMenuModel *model=self.menuArray[indexPath.row];
    
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2-10, 7, 80, 30)];
    titleLab.textColor=[UIColor colorWithHexString:@"#313131"];
    titleLab.font=[UIFont systemFontOfSize:16];
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.text=model.menu_name;
    [cell.contentView addSubview:titleLab];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right, 12, 20, 20)];
    imgView.image=[UIImage imageNamed:@"ic_pub_choose_sel"];
    [cell.contentView addSubview:imgView];
    imgView.hidden=!model.isSelected;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [self backUpCoverAction];
    if ([_viewDelegate respondsToSelector:@selector(downListMenuDidSelectedMenu:)]) {
        [_viewDelegate downListMenuDidSelectedMenu:indexPath.row];
    }
}

#pragma mark -- setters
-(void)downListMenuShow{
    [KEY_WINDOW addSubview:coverView];
    [KEY_WINDOW addSubview:menuTableView];
    menuTableView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, 0);
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha=0.5;
        menuTableView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, viewHeight);
    }];
}

#pragma mark 退出遮罩层
-(void)backUpCoverAction{
    [UIView animateWithDuration:0.3 animations:^{
         menuTableView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, 0);
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
        [self removeFromSuperview];
        self.backUpCoverBlock();
    }];
}


#pragma mark -- Setters
-(void)setMenuArray:(NSMutableArray *)menuArray{
    _menuArray=menuArray;
    [menuTableView reloadData];
}



@end
