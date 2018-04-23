//
//  TCRemindWhoSeeCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRemindWhoSeeCell.h"

@interface TCRemindWhoSeeCell ()
{
    NSString     *_useNameStr;
    UIButton     *_roleTypeBtn;
    UIImageView  *_headimg;
    UILabel      *_nickNameLab;
}
@end

@implementation TCRemindWhoSeeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        //头像
        _headimg = [[UIImageView alloc]initWithFrame:CGRectMake(20, (50 - 30)/2 , 30, 30)];
        _headimg.layer.cornerRadius = 15;
        _headimg.layer.masksToBounds = YES;
        [self addSubview:_headimg];
        
        //列表中姓名
        _nickNameLab = [[UILabel alloc]initWithFrame:CGRectMake(_headimg.right + 8, (50 - 20)/2 , 150, 20)];
        _nickNameLab.textColor = UIColorFromRGB(0x313131);
       _nickNameLab.font = [UIFont systemFontOfSize:15];
        [self addSubview:_nickNameLab];
        
        _roleTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _roleTypeBtn.titleLabel.font = kFontWithSize(12);
        [_roleTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _roleTypeBtn.hidden = YES;
        _roleTypeBtn.layer.cornerRadius = 3;
        [self addSubview:_roleTypeBtn];
    }
    return self;
}
- (void)cellWithFollowListModel:(TCFollowListModel *)model{
    
    // 用户头像
    [_headimg sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    // 用户名
    CGSize nameStrSize = [model.nick_name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontWithSize(15)];
    _nickNameLab.frame = CGRectMake(_headimg.right + 8, 15 , nameStrSize.width , nameStrSize.height);
    _nickNameLab.text = model.nick_name;
    
    //用户类型
    CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(12)];
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        _roleTypeBtn.hidden = NO;
        _roleTypeBtn.frame = CGRectMake(_nickNameLab.right + 8, 15 , labelSize.width + 10 , 15);
        [_roleTypeBtn setTitle:model.label forState:UIControlStateNormal];
        _roleTypeBtn.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        _roleTypeBtn.hidden = NO;
        _roleTypeBtn.frame = CGRectMake(_nickNameLab.right + 8, 15 , labelSize.width + 10, 15);
        [_roleTypeBtn setTitle:model.label forState:UIControlStateNormal];
        _roleTypeBtn.backgroundColor = kSystemColor;
    }else{
        _roleTypeBtn.hidden = YES;
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
