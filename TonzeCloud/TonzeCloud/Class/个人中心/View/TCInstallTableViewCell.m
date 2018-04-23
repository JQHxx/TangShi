//
//  TCInstallTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInstallTableViewCell.h"
@interface TCInstallTableViewCell (){
    UILabel    *titleLabel;
    UILabel    *contentLabel;
    UILabel    *title1;
}

@end
@implementation TCInstallTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        title1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, kScreenWidth/2, 30)];
        title1.textAlignment = NSTextAlignmentLeft;
        title1.textColor = [UIColor grayColor];
        [self addSubview:title1];
        
        _textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-40, 9, kScreenWidth/2, 30)];
        _textLabel1.textAlignment = NSTextAlignmentRight;
        _textLabel1.textColor = [UIColor grayColor];
        _textLabel1.font = [UIFont systemFontOfSize:15];
        [self addSubview:_textLabel1];
        
        _textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-40, 9, kScreenWidth/2, 30)];
        _textLabel2.textAlignment = NSTextAlignmentRight;
        _textLabel2.textColor = [UIColor grayColor];
        _textLabel2.font = [UIFont systemFontOfSize:13];
        [self addSubview:_textLabel2];
    }
    return self;
}
-(void)cellDisplayWithDict:(NSDictionary *)dict{
    
    title1.text =[dict valueForKey:@"title"];
    _textLabel1.text = [dict valueForKey:@"internal"];
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
