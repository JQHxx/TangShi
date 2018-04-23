
//
//  TodayMissionCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/8.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCTodayMissionCell.h"
#import "QLCoreTextManager.h"

@interface TCTodayMissionCell ()
{
    UIImageView *_arrowImg;
}
@end

@implementation TCTodayMissionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self TodayMissionCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)TodayMissionCellUI{
    
    _taskImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, (50 - 22)/2, 56/2, 56/2)];
    [self.contentView addSubview:_taskImg];
    
    _titleLab = [[UILabel alloc]initWithFrame: CGRectMake( _taskImg.right + 10, 8, kScreenWidth - _taskImg.width - 80, 20)];
    _titleLab.font = kFontWithSize(15);
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor =  UIColorFromRGB(0x313131);
    [self.contentView addSubview:_titleLab];
    
    _integraInfoLab = [[UILabel alloc]initWithFrame:CGRectMake( _titleLab.left ,_titleLab.bottom  , kScreenWidth - _taskImg.width - 80, 20)];
    _integraInfoLab.textAlignment = NSTextAlignmentLeft;
    _integraInfoLab.font = kFontWithSize(13);
    _integraInfoLab.textColor = UIColorFromRGB(0x959595);
    [self.contentView addSubview:_integraInfoLab];
    
    _taskTypeLabe = [[UILabel alloc]initWithFrame:CGRectMake( kScreenWidth - 135 ,(60 - 20)/2, 95, 20)];
    _taskTypeLabe.textColor = UIColorFromRGB(0x959595);
    _taskTypeLabe.font = kFontWithSize(13);
    _taskTypeLabe.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_taskTypeLabe];
    
    _arrowImg= [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (60 - 15)/2 , 15, 15)];
    _arrowImg.image =[UIImage imageNamed:@"ic_pub_arrow_nor"];
    [self.contentView addSubview:_arrowImg];
}
#pragma mark ====== Set Data =======
- (void)setTodayMissionWithModel:(TCIntegralTaskListModel *)model{
    _titleLab.text = model.action_name;
    
    if (model.click_num  == model.sum_num && model.sum_num !=0) {
        _taskTypeLabe.text = @"已完成";
    }else if (model.sum_num == 0){
        _taskTypeLabe.text = @"";
    }else{
        NSString *taskTypeStr = [NSString stringWithFormat:@"%ld/%ld",(long)model.click_num,(long)model.sum_num];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:taskTypeStr];
        //设置字号
        [str addAttribute:NSFontAttributeName value:kFontWithSize(13) range:NSMakeRange(0, 1)];
        //设置文字颜色
        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:NSMakeRange(0, 1)];
        _taskTypeLabe.attributedText = str;
    }
    NSString *tipStr = @"";
    switch ([model.action_type integerValue]) {
        case 1:
        {
            _taskImg.image = [UIImage imageNamed:@"sign_in"];
        }break;
        case 2:
        {
            tipStr = @"（首次完善）";
            _taskImg.image = [UIImage imageNamed:@"Perfect_information"];
        }break;
        case 3:
        {// 购买方案
            tipStr = @"1元=1积分（不限）";
            _taskImg.image = [UIImage imageNamed:@"health_ plan"];
        }break;
        case 4:
        {// 首次使用血糖仪
            tipStr = @"（首次）";
            _taskImg.image = [UIImage imageNamed:@"first_use"];
        }break;
        case 5:
        {// 血糖测量
            _taskImg.image = [UIImage imageNamed:@"measuring_ blood_ sugar"];
        }break;
        case 6:
        {// 手动测量
            _taskImg.image = [UIImage imageNamed:@"hand_record_blood"];
        }break;
        case 7:
        {// 记录饮食
            _taskImg.image = [UIImage imageNamed:@"record_food"];
        }break;
        case 8:
        {// 记录运动
            _taskImg.image = [UIImage imageNamed:@"record_sport"];
        }break;
        case 9:
        {// 记录血压
            _taskImg.image = [UIImage imageNamed:@"record_ blood pressure"];
        }break;
        case 10:
        {// 记录血红蛋白
            tipStr = @"（每月）";
            _taskImg.image = [UIImage imageNamed:@"record_protein"];
        }break;
        case 11:
        {// 上传检查单
            tipStr = @"（每周）";
            _taskImg.image = [UIImage imageNamed:@"upload"];
        }break;
        case 12:
        {// 阅读文章
            _taskImg.image = [UIImage imageNamed:@"read"];
        }break;
        case 13:
        {// 分享文章
            _taskImg.image = [UIImage imageNamed:@"share"];
        }break;
        case 14:
        {// 添加亲友
            tipStr = @"(首3次)";
            _taskImg.image = [UIImage imageNamed:@"add_family"];
        }break;
        case 15:
        {// 提交意见
            tipStr = @"（每月）";
            _taskImg.image = [UIImage imageNamed:@"opinion"];
        }break;
        case 16:
        {// 发布动态
            _taskImg.image = [UIImage imageNamed:@"dynamicTask"];
        }break;
        case 17:
        {// 注册送积分
            tipStr = @"（首次）";
            _taskImg.image = [UIImage imageNamed:@"gift"];
        }break;
        case 18:
        {// 评论糖友圈或文章
            _taskImg.image = [UIImage imageNamed:@"task_ic_pinglun"];
        }break;
        case 19:
        {// 邀请好友
            tipStr = @"（每月10次）";
            _taskImg.image = [UIImage imageNamed:@"task_ic_invite"];
        }break;
        case 20:
        {// 动态被推荐
            tipStr = @"（不限）";
            _taskImg.image = [UIImage imageNamed:@"task_ic_tuijian"];
        }break;
        case 21:
        {// 动态被加精华
            tipStr = @"（不限）";
            _taskImg.image = [UIImage imageNamed:@"task_ic_jinghua"];
        }break;
        default:
            break;
    }
    // -- 购买方案处理
    if ([model.action_name isEqualToString:@"购买方案"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:tipStr];
        //设置字号
        [str addAttribute:NSFontAttributeName value:kFontWithSize(13) range:NSMakeRange(0, 6)];
        //设置文字颜色
        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:NSMakeRange(0, 6)];
        _integraInfoLab.attributedText = str;
    }else{
        NSString *integralStr =[NSString stringWithFormat:@"%@ 积分 %@",model.use_points,tipStr];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
        NSString *pointStr = [NSString stringWithFormat:@"%@ 积分",model.use_points];
        [QLCoreTextManager setAttributedValue:attStr text:pointStr font:kFontWithSize(13) color:UIColorFromRGB(0xf9c92b)];
        _integraInfoLab.attributedText = attStr;
    }
    
    // 箭头
    if ([model.action_type integerValue] == 20 ||[model.action_type integerValue] == 21 ) {
        _arrowImg.hidden = YES;
    }else{
        _arrowImg.hidden = NO;
    }
}
@end
