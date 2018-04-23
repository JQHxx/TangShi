//
//  TCTaskTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTaskTableViewCell.h"

@interface TCTaskTableViewCell (){
    UIImageView   *imgView;
    UILabel       *titlelbl;
}

@end

@implementation TCTaskTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        
        UIView *rootView=[[UIView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 60)];
        rootView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:rootView];
        
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [rootView addSubview:imgView];
        
        titlelbl=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, 20, rootView.width-imgView.right-40, 20)];
        titlelbl.font=[UIFont boldSystemFontOfSize:16];
        titlelbl.textColor=[UIColor blackColor];
        [rootView addSubview:titlelbl];
        
        UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30-30, 22, 16, 16)];
        arrowImageView.image=[UIImage imageNamed:@"ic_pub_arrow_nor"];
        [rootView addSubview:arrowImageView];
    }
    return self;
}

-(void)taskCellDisplayWithDict:(NSDictionary *)dict{
    if ([dict[@"key"] isEqualToString:@"task1"]) {
        imgView.image=[UIImage imageNamed:@"ic_record_yinshi"];
    }else if ([dict[@"key"] isEqualToString:@"task2"]){
        imgView.image=[UIImage imageNamed:@"ic_record_sport"];
    }else if ([dict[@"key"] isEqualToString:@"task3"]){
        imgView.image=[UIImage imageNamed:@"ic_record_time"];
    }
    titlelbl.text=dict[@"name"];
}


@end
