//
//  TCTreatTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTreatTableViewCell.h"
@interface TCTreatTableViewCell (){
    UILabel    *title1;
    UIImageView *_highlightImage;
}

@end

@implementation TCTreatTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _highlightImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 25, 25)];
        [self addSubview:_highlightImage];
        
        title1 = [[UILabel alloc] initWithFrame:CGRectMake(_highlightImage.right+10, 13, kScreenWidth/3*2, 20)];
        title1.textAlignment = NSTextAlignmentLeft;
        title1.textColor = [UIColor grayColor];
        title1.font = [UIFont systemFontOfSize:15];
        [self addSubview:title1];
    }
    return self;
}
-(void)cellDisplayWithDict:(NSDictionary *)dict{
    
    title1.text =[dict valueForKey:@"title"];
    if ([[dict valueForKey:@"image"] isEqualToString:@"1"]) {
        _highlightImage.image = [UIImage imageNamed:@"ic_eqment_pick_on"];
    } else {
        _highlightImage.image = [UIImage imageNamed:@"ic_eqment_pick_un"];
    }
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
