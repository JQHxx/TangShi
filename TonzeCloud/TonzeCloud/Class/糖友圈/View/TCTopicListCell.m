//
//  TCTopicListCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTopicListCell.h"
#import "TCTopicListModel.h"

@implementation TCTopicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _topicIcon = [[UIImageView alloc]initWithFrame:CGRectMake(18, (98 - 70)/2, 110 , 70)];
        _topicIcon.layer.cornerRadius = 5;
        [self.contentView addSubview:_topicIcon];
        
        // 可换行
        _topicTitleLab = [[UILabel alloc]initWithFrame:CGRectMake( _topicIcon.right + 15, 42/2, kScreenWidth - _topicIcon.right - 30, 20)];
        _topicTitleLab.textColor = UIColorFromRGB(0x313131);
        _topicTitleLab.numberOfLines = 0;
        _topicTitleLab.font = kFontWithSize(15);
        [self.contentView addSubview:_topicTitleLab];
        
        // 一行
        _instructionsLab =[[UILabel alloc]initWithFrame:CGRectMake( _topicIcon.right + 15, _topicTitleLab.bottom + 10, kScreenWidth - _topicIcon.right - 30, 20)];
        _instructionsLab.textColor = UIColorFromRGB(0x5b5b5b);
        _instructionsLab.font = kFontWithSize(13);
        [self.contentView addSubview:_instructionsLab];
        
        _readLab =[[UILabel alloc]initWithFrame:CGRectMake( _topicIcon.right + 10, _topicIcon.bottom - 15, 100, 15)];
        _readLab.textColor = UIColorFromRGB(0x919191);
        _readLab.font = kFontWithSize(13);
        [self.contentView addSubview:_readLab];
        
        _discussLab =[[UILabel alloc]initWithFrame:CGRectMake( _readLab.right + 10, _readLab.top, 100, 15)];
        _discussLab.textColor = UIColorFromRGB(0x919191);
        _discussLab.font = kFontWithSize(13);
        [self.contentView addSubview:_discussLab];
    }
    return self;
}
#pragma mark ====== 设定列表数据 =======
- (void)setTopicListWithModel:(TCTopicListModel *)model{
    
    [_topicIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.default_image]] placeholderImage:[UIImage imageNamed:@""]];
    
    // 标题最多两行
    _topicTitleLab.text = [NSString stringWithFormat:@"#%@#",model.title];
    CGSize topicTextSize = [_topicTitleLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 158, 100) withTextFont:kFontWithSize(15)];
    if (topicTextSize.height > 20) {
        _topicTitleLab.frame = CGRectMake( _topicIcon.right + 15, _topicIcon.top, kScreenWidth - _topicIcon.right - 30, 36);
    }else{
        _topicTitleLab.frame = CGRectMake( _topicIcon.right + 15, _topicIcon.top, kScreenWidth - _topicIcon.right - 30, 20);
    }
    
    _instructionsLab.frame = CGRectMake( _topicIcon.right + 15, _topicTitleLab.bottom + (topicTextSize.height > 20 ? 0 : 10), kScreenWidth - _topicIcon.right - 30, 20);
    _instructionsLab.text = model.desc;
    
    _readLab.text = [NSString stringWithFormat:@"%ld 阅读",model.read_num];
    CGSize readTextSize = [_readLab.text boundingRectWithSize:CGSizeMake(kScreenWidth, 15) withTextFont:kFontWithSize(13)];
    _readLab.frame = CGRectMake( _topicIcon.right + 15, _topicIcon.bottom - 15, readTextSize.width, 15);
    
    _discussLab.frame = CGRectMake( _readLab.right + 15, _readLab.top, 150, 15);
    _discussLab.text = [NSString stringWithFormat:@"%ld 讨论",model.comment_num];
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
