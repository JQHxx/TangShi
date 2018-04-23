//
//  TCFoodSelectView.m
//  TonzeCloud
//
//  Created by vision on 17/3/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodSelectView.h"
#import "TCFoodAddTool.h"
#import "TCFoodTableViewCell.h"

@interface TCFoodSelectView ()<UITableViewDelegate,UITableViewDataSource,TCFoodTableViewCellDelegate>

@end

@implementation TCFoodSelectView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        
        
        UIButton *clearBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-60, 5, 50, 30)];
        [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
        [clearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearSelectedFoodAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearBtn];
        
        self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, clearBtn.bottom+5, kScreenWidth, 180) style:UITableViewStylePlain];
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        [self addSubview:self.tableView];
        
        self.tableView.tableFooterView=[[UIView alloc] init];
        
    }
    return self;
}

#pragma mark UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.foodSelectArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdntifier=@"TCFoodTableViewCell";
    TCFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TCFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.cellType=1;
    cell.cellDelegate=self;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCFoodAddModel *food=self.foodSelectArray[indexPath.row];
    [cell cellDisplayWithFood:food searchText:@""];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCFoodAddModel *food=self.foodSelectArray[indexPath.row];
    if ([_delegate respondsToSelector:@selector(foodSelectViewDidSelectFood:)]) {
        [_delegate foodSelectViewDidSelectFood:food];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -- TCFoodTableViewCellDelegate
-(void)foodTableViewCellDeleteFood:(TCFoodAddModel *)food{
    [[TCFoodAddTool sharedTCFoodAddTool] deleteFood:food];
    [self.foodSelectArray removeObject:food];
    [self.tableView reloadData];
    
    if ([_delegate respondsToSelector:@selector(foodSelectViewDeleteFood:)]) {
        [_delegate foodSelectViewDeleteFood:food];
    }
    
    if (self.foodSelectArray.count==0) {
        if ([_delegate respondsToSelector:@selector(foodSelectViewDismissAction)]) {
            [_delegate foodSelectViewDismissAction];
        }
    }
}

#pragma mark Events Response
#pragma mark 清空
-(void)clearSelectedFoodAction{
    [[TCFoodAddTool sharedTCFoodAddTool] removeAllFood];
    [self.foodSelectArray removeAllObjects];
    [self.tableView reloadData];
    if ([_delegate respondsToSelector:@selector(foodSelectViewDismissAction)]) {
        [_delegate foodSelectViewDismissAction];
    }
}

#pragma mark -- Setters and Getters
-(void)setFoodSelectArray:(NSMutableArray *)foodSelectArray{
    if (foodSelectArray==nil) {
        foodSelectArray=[[NSMutableArray alloc] init];
    }
    _foodSelectArray=foodSelectArray;
}


@end
