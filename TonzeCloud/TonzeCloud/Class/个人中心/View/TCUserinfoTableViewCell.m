//
//  TCUserinfoTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCUserinfoTableViewCell.h"
@interface TCUserinfoTableViewCell (){
    UILabel     *headLabel;
    UILabel     *title1;
    UILabel     *title2;
    UIImageView *headImgView;
}

@end
@implementation TCUserinfoTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,15, kScreenWidth/2, 30)];
        [self addSubview:headLabel];
        
        title1 = [[UILabel alloc] initWithFrame:CGRectMake(15,10, kScreenWidth/2, 30)];
        [self addSubview:title1];
        
        title2 = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 10, kScreenWidth/2-40, 30)];
        title2.textAlignment = NSTextAlignmentRight;
        title2.textColor = [UIColor grayColor];
        [self addSubview:title2];
        
        headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 40, 40)];
        headImgView.image = [UIImage imageNamed:@"headimg"];
        [self addSubview:headImgView];    }
    return self;
}
-(void)cellDisplayWithDict:(NSDictionary *)dict{
    
    headLabel.text =[dict valueForKey:@"headLabel"];
    title1.text =[dict valueForKey:@"title"];
    title2.text = [dict valueForKey:@"internal"];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
