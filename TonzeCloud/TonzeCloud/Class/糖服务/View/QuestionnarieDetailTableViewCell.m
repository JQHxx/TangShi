//
//  QuestionnarieDetailTableViewCell.m
//  TangShiService
//
//  Created by 肖栋 on 17/12/15.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "QuestionnarieDetailTableViewCell.h"

@interface QuestionnarieDetailTableViewCell (){

    UILabel *titleLabel;
    UIImageView *seleteImg;
    UIImageView *seleteMoreImg;
    UIView      *bgView;
}
@end

@implementation QuestionnarieDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 47)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"0xe6fbf2"];
        [self.contentView addSubview:bgView];
        
        seleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 24, 24)];
        [self.contentView addSubview:seleteImg];
        
        seleteMoreImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 24, 24)];
        [self.contentView addSubview:seleteMoreImg];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self.contentView addSubview:titleLabel];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth-40, 38)];
        _textField.textColor = [UIColor colorWithHexString:@"0x626262"];
        _textField.layer.borderWidth=1;
        _textField.layer.borderColor = [UIColor bgColor_Gray].CGColor;
        _textField.layer.masksToBounds = YES;
        _textField.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_textField];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth-40, 120)];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textColor = [UIColor colorWithHexString:@"0x626262"];
        _textView.layer.borderWidth=1;
        _textView.layer.borderColor = [UIColor bgColor_Gray].CGColor;
        _textView.layer.masksToBounds = YES;
        [self.contentView addSubview:_textView];
        
    }
    return self;
}
- (void)questionnarieDetailData:(NSDictionary *)dict indexPath:(NSInteger)row section:(NSInteger)section{
    NSInteger type =[[dict objectForKey:@"type"] integerValue];
    if (type==1||type==2) {
        titleLabel.hidden = NO;
        _textField.hidden = YES;
        _textView.hidden = YES;
        seleteImg.hidden = type==1?NO:YES;
        seleteMoreImg.hidden = type==2?NO:YES;

        NSArray *dataArr = [dict objectForKey:@"option"];
        NSDictionary *dataDict =dataArr[row];
        titleLabel.text = [dataDict objectForKey:@"key"];
        CGSize size = [titleLabel.text sizeWithLabelWidth:kScreenWidth-68 font:[UIFont systemFontOfSize:15]];
        titleLabel.frame =CGRectMake(48, 14, size.width, size.height);
        
        NSInteger seleteInt = [[dataDict objectForKey:@"val"] integerValue];
        bgView.hidden = seleteInt==0?YES:NO;
        seleteImg.image = [UIImage imageNamed:seleteInt==0?@"ic_pub_choose_nor":@"ic_pub_choose_sel"];
        seleteMoreImg.image = [UIImage imageNamed:seleteInt==0?@"chat_ic_nune":@"chat_ic_multiple"];

    } else if(type==3){
        bgView.hidden = YES;
        titleLabel.hidden = YES;
        _textField.hidden = NO;
        _textView.hidden = YES;
        seleteImg.hidden = YES;
        seleteMoreImg.hidden = YES;
        
        _textField.text = [[dict objectForKey:@"option"][0] objectForKey:@"val"];
        _textField.tag = section*1000+row*10+type;

    }else if(type==4){
        if (row%2==0) {
            bgView.hidden = YES;
            titleLabel.hidden = NO;
            _textField.hidden = YES;
            _textView.hidden = YES;
            seleteImg.hidden = YES;
            seleteMoreImg.hidden = YES;

            NSArray *dataArr = [dict objectForKey:@"option"];
            NSDictionary *dataDict =dataArr[row/2];
            titleLabel.text = [dataDict objectForKey:@"key"];
            titleLabel.frame = CGRectMake(20, 5, kScreenWidth-40, 20);
        } else {
            bgView.hidden = YES;
            titleLabel.hidden = YES;
            _textField.hidden = NO;
            _textView.hidden = YES;
            seleteImg.hidden = YES;
            seleteMoreImg.hidden = YES;

            NSArray *dataArr = [dict objectForKey:@"option"];
            NSDictionary *dataDict =dataArr[row/2];
            _textField.text = [dataDict objectForKey:@"val"];
            _textField.tag = section*1000+row*10+type;
        }
    }else if(type==5){
        bgView.hidden = YES;
        titleLabel.hidden = YES;
        _textField.hidden = YES;
        _textView.hidden = NO;
        seleteImg.hidden = YES;
        seleteMoreImg.hidden = YES;

        _textView.tag = section*100+row;
        _textView.text = [[dict objectForKey:@"option"][0] objectForKey:@"val"];
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
