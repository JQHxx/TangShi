//
//  TCSportsRecordsTableView.m
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSportsRecordsTableView.h"
#import "TCSportsRecordTableViewCell.h"

@implementation TCSportsRecordsTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        
        self.delegate=self;
        self.dataSource=self;
        self.scrollEnabled=NO;
        self.showsVerticalScrollIndicator=NO;
        self.tableFooterView=[[UIView alloc] init];
    }
    return self;
    
}

#pragma mark -- Setters and Getters
#pragma mark 运动记录
-(void)setSportsRecordsArray:(NSMutableArray *)sportsRecordsArray{
    _sportsRecordsArray=sportsRecordsArray;
}


#pragma mark -- UITablbeViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sportsRecordsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCSportsRecordTableViewCell";
    TCSportsRecordTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TCSportsRecordTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    TCSportRecordModel *sportModel=self.sportsRecordsArray[indexPath.row];
    [cell cellDisplayWithModel:sportModel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

@end
