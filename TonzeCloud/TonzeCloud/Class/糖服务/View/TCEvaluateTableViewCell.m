//
//  TCEvaluateTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/6/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCEvaluateTableViewCell.h"

@interface TCEvaluateTableViewCell (){
    UIImageView   *userImageView;
    UILabel       *userLabel;
    UILabel       *commentLabel;
    
    NSMutableArray *scoreArray;
}

@end

@implementation TCEvaluateTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //    用户图片
        userImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        userImageView.layer.cornerRadius = 15;
        userImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:userImageView];
        
        //    用户昵称
        userLabel=[[UILabel alloc] initWithFrame:CGRectMake(userImageView.right+10, 5, 100, 30)];
        userLabel.font=[UIFont systemFontOfSize:14];
        userLabel.textColor=[UIColor colorWithHexString:@"#313131"];
        userLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:userLabel];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [scoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
        //    评论内容
        commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(userLabel.left, userLabel.bottom+5, kScreenWidth-userImageView.right-20, 0)];
        commentLabel.font=[UIFont systemFontOfSize:14];
        commentLabel.numberOfLines=0;
        commentLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:commentLabel];
    }
    return self;
}


-(void)setEvaluateModel:(TCEvaluateModel *)evaluateModel{
    _evaluateModel=evaluateModel;
    
    NSURL *url = [NSURL URLWithString:evaluateModel.photo];
    [userImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    userLabel.text = evaluateModel.nick_name;
    CGFloat userLabW=[userLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-userImageView.right-100, 30) withTextFont:userLabel.font].width;
    userLabel.frame=CGRectMake(userImageView.right+10, 5, userLabW, 30);
    
    //加星级
    CGSize scoreSize = CGSizeMake(15, 15);
    double scoreNum = [evaluateModel.comment_score doubleValue];
    NSInteger oneScroe=(NSInteger)scoreNum;
    NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
    for (int i = 0; i<scoreArray.count; i++) {
        UIImageView *scoreImage = scoreArray[i];
        [scoreImage setFrame:CGRectMake(kScreenWidth-90+scoreSize.width*i,10, scoreSize.width, scoreSize.height)];
        if (i<= num-1) {
            if ((i==num-1)&&scoreNum>oneScroe) {
                scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
            }
        }else{
            scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
        }
    }
    
    commentLabel.text=evaluateModel.msg;
    CGFloat commentH=[commentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-userImageView.right-20, CGFLOAT_MAX) withTextFont:commentLabel.font].height;
    commentLabel.frame=CGRectMake(userImageView.right+10, userLabel.bottom+5, kScreenWidth-userImageView.right-20, commentH);
   
}

+(CGFloat)getEvaluateCellHeightWithModel:(TCEvaluateModel *)model{
    CGFloat commentH=[model.msg boundingRectWithSize:CGSizeMake(kScreenWidth-60, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:14]].height;
    return commentH+50;
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
