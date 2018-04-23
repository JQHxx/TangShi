//
//  EaseMessageSystemCell.m
//  TonzeCloud
//
//  Created by vision on 17/11/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "EaseMessageSystemCell.h"

@interface EaseMessageSystemCell (){
    UIView       *bgView;
    UILabel      *titleLabel;
}

@end

@implementation EaseMessageSystemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor colorWithHexString:@"#f8f8f8"];
        
        bgView=[[UIView alloc] init];
        bgView.backgroundColor=[UIColor bgColor_Gray];
        bgView.layer.cornerRadius=3;
        bgView.clipsToBounds=YES;
        [self.contentView addSubview:bgView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.numberOfLines=0;
        [bgView addSubview:titleLabel];
    }
    return self;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle=cellTitle;
    
    titleLabel.text = _cellTitle;
    
    CGFloat titleHeight=[cellTitle boundingRectWithSize:CGSizeMake(230, CGFLOAT_MAX) withTextFont:titleLabel.font].height;
    bgView.frame=CGRectMake((kScreenWidth-250)/2, 10, 250, titleHeight+20);

    titleLabel.frame=CGRectMake(10,10, 230, titleHeight);
}

+(CGFloat)getMessageSystemCellHeightWithText:(NSString *)text{
    return [text boundingRectWithSize:CGSizeMake(230, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:16]].height+40;
}

@end
