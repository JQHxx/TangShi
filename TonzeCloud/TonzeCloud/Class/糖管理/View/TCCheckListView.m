//
//  TCCheckListView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCheckListView.h"
#import "TCManagerRecordButton.h"
#import "TCDietRecordButton.h"
@interface TCCheckListView (){
    
    TCManagerRecordButton       *addRecord;
    UILabel                     *titleLabel;
    UILabel                     *detailLabel;
    UILabel                     *timeLabel;
    UIButton                    *button;
    
    UIImageView                 *oneImgView;
    UIImageView                 *twoImgView;
    UIImageView                 *threeImgView;
    UIImageView                 *fourImgView;

}

@end
@implementation TCCheckListView

- (instancetype)initWithFrame:(CGRect)frame rightCheckDict:(NSDictionary *)rightDict{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;

        button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width-55, 90)];
        [button addTarget:self action:@selector(seletedRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (height-30)/2, 30, 30)];
        imgView.image = [UIImage imageNamed:@"ic_record_jianchadan"];
        [button addSubview:imgView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+15, 8, width-imgView.right, 20)];
        titleLabel.text = @"检查单";
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [button addSubview:titleLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+15, titleLabel.bottom, width-imgView.right, 20)];
        detailLabel.text = @"上传检查表，更准确掌握健康状况";
        detailLabel.font = [UIFont systemFontOfSize:12];
        detailLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [button addSubview:detailLabel];
        
        oneImgView= [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom+5, 30, 30)];
        [button addSubview:oneImgView];

        twoImgView= [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.left+40, titleLabel.bottom+5, 30, 30)];
        [button addSubview:twoImgView];
        
        threeImgView= [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.left+40*2, titleLabel.bottom+5, 30, 30)];
        [button addSubview:threeImgView];
        
        fourImgView= [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.left+40*3, titleLabel.bottom+5, 30, 30)];
        [button addSubview:fourImgView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, oneImgView.bottom+5, detailLabel.width, 15)];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor grayColor];
        [button addSubview:timeLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.right, 10, 1, 70)];
        lineLabel.backgroundColor = [UIColor bgColor_Gray];
        [self addSubview:lineLabel];
        
        addRecord = [[TCManagerRecordButton alloc] initWithFrame:CGRectMake(lineLabel.right, 0, 54, 90) dictManager:rightDict bgColor:[UIColor whiteColor]];
        [addRecord addTarget:self action:@selector(addRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addRecord];
        
        
    }
    return self;
}
- (void)seletedRecord{
    if ([_delegate respondsToSelector:@selector(TCCheckListRecordForIndex:)]) {
        [_delegate TCCheckListRecordForIndex:self.type];
    }
}

- (void)addRecord{
    if ([_delegate respondsToSelector:@selector(TCAddCheckListForIndex:)]) {
        [_delegate TCAddCheckListForIndex:self.type];
    }
}
- (void)setImgArr:(NSArray *)imgArr{
    _imgArr = imgArr;
    if (_imgArr.count>0&&_imgArr.count<5) {
        titleLabel.frame=CGRectMake(60,8, self.width-60, 20);
        detailLabel.hidden = YES;
        timeLabel.hidden = NO;
        timeLabel.text = self.timeText;
        if (_imgArr.count==1) {
            oneImgView.hidden = NO;
            twoImgView.hidden = YES;
            threeImgView.hidden = YES;
            fourImgView.hidden = YES;
            [oneImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[0]] placeholderImage:[UIImage imageNamed:@""]];
        }else if (_imgArr.count==2){
            oneImgView.hidden = NO;
            twoImgView.hidden = NO;
            threeImgView.hidden = YES;
            fourImgView.hidden = YES;
            [oneImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[0]] placeholderImage:[UIImage imageNamed:@""]];
            [twoImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[1]] placeholderImage:[UIImage imageNamed:@""]];
        }else if (_imgArr.count==3){
            oneImgView.hidden = NO;
            twoImgView.hidden = NO;
            threeImgView.hidden = NO;
            fourImgView.hidden = YES;
            [oneImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[0]] placeholderImage:[UIImage imageNamed:@""]];
            [twoImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[1]] placeholderImage:[UIImage imageNamed:@""]];
            [threeImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[2]] placeholderImage:[UIImage imageNamed:@""]];
        }else if (_imgArr.count==4){
            oneImgView.hidden = NO;
            twoImgView.hidden = NO;
            threeImgView.hidden = NO;
            fourImgView.hidden = NO;
            [oneImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[0]] placeholderImage:[UIImage imageNamed:@""]];
            [twoImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[1]] placeholderImage:[UIImage imageNamed:@""]];
            [threeImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[2]] placeholderImage:[UIImage imageNamed:@""]];
            [fourImgView sd_setImageWithURL:[NSURL URLWithString:_imgArr[3]] placeholderImage:[UIImage imageNamed:@""]];
        }
    }else{
        titleLabel.frame=CGRectMake(60,20, self.width-60, 30);
        detailLabel.frame=CGRectMake(60, titleLabel.bottom,self.width-60, 20);
        
        detailLabel.hidden = NO;
        timeLabel.hidden = YES;
        oneImgView.hidden = YES;
        twoImgView.hidden = YES;
        threeImgView.hidden = YES;
        fourImgView.hidden = YES;

    }

}
@end
