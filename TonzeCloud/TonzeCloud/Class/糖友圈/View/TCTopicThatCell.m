//
//  TCMyDynamicTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//
#define KDynamicTextFont          16                    /// 动态内容字体大小

#import "TCTopicThatCell.h"
#import "TCMyDynamicButton.h"
#import "YHWorkGroupPhotoContainer.h"
#import "TCPraiseButton.h"
#import "TCMyResponseView.h"
#import "MYCoreTextLabel.h"
#import "NSDate+Extension.h"

@interface TCTopicThatCell ()<TCMyRespondDelegate,MYCoreTextLabelDelegate>{
    TCMyResponseView  *_myRespondView;
    UILabel           *_timeLabel;
    UIButton          *_lookAllButton;
    UIButton          *_deleteButton;
    YHWorkGroupPhotoContainer *_picContainerView;  
    CALayer           *_line;
    UIButton          *_commentsBtn;     // 评论
    TCPraiseButton   *_praiseButton;     //  点赞
    UIImageView       *_essenceImg;      // 精华标签
    UIImageView       *_recommendImg;    // 推荐标签
    UIImageView       *_topImg;          // 置顶标签
    CALayer           *_lens;            // cell 灰色分割线
    CALayer           *_verticalLen;     // 评论处竖线
    UIImageView       *_headImg;         // 头像
    UILabel           *_nickNameLab;     // 用户名
    UIImageView       *_sexImg;          // 用户性别
    UILabel           *_roleTypeLab;      // 用户类型
    UILabel           *_sugarTypeLab;     // 糖尿病类型
    CGFloat            _picContainerH;
}
///  动态内容
@property (nonatomic, strong) MYCoreTextLabel *contentLabel;
///  话题标题
@property (nonatomic ,strong) MYCoreTextLabel   *topicLab;

@end
@implementation TCTopicThatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //个人信息
        _myRespondView = [[TCMyResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        _myRespondView.delegate = self;
        [self.contentView addSubview:_myRespondView];
        
        //话题
        [self.contentView addSubview:self.topicLab];
        
        //内容
        [self.contentView addSubview:self.contentLabel];
        
        _lookAllButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.contentLabel.bottom+10, 120, 20)];
        _lookAllButton.tag =100;
        _lookAllButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _lookAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_lookAllButton setTitle:@"查看全文" forState:UIControlStateNormal];
        [_lookAllButton setImage:[UIImage imageNamed:@"lookAtAll"] forState:UIControlStateNormal];
        [_lookAllButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        [_lookAllButton setTitleColor:UIColorFromRGB(0x959595) forState:UIControlStateNormal];
        [_lookAllButton addTarget:self action:@selector(lookAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_lookAllButton];
        
        //图片组
        _picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        [self.contentView addSubview:_picContainerView];
        
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_timeLabel];
        
        //置顶、精华、推荐
        _topImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topImg.image = [UIImage imageNamed:@"top"];
        [self.contentView addSubview:_topImg];
        _topImg.hidden=YES;
        
        _essenceImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        _essenceImg.image =[UIImage imageNamed:@"best"];
        [self.contentView addSubview:_essenceImg];
        _essenceImg.hidden=YES;
        
        _recommendImg =[[UIImageView alloc]initWithFrame:CGRectZero];
        _recommendImg.image = [UIImage imageNamed:@"introduce"];
        [self.contentView addSubview:_recommendImg];
        _recommendImg.hidden=YES;
        
        //删除
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_deleteButton addTarget:self action:@selector(lookAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
        
        _line = [[CALayer alloc] init];
        _line.frame = CGRectZero;
        _line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"].CGColor;
        [self.contentView.layer addSublayer:_line];
        
        //评论
        _commentsBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_commentsBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [_commentsBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        _commentsBtn.titleLabel.font = kFontWithSize(15);
        [_commentsBtn  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        _commentsBtn.tag = 100;
        [_commentsBtn addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_commentsBtn];
        
        _verticalLen = [[CALayer alloc]init];
        _verticalLen.frame = CGRectZero;
        _verticalLen.backgroundColor = UIColorFromRGB(0xe5e5e5).CGColor;
        [self.contentView.layer addSublayer:_verticalLen];
        
        //点赞
        _praiseButton = [[TCPraiseButton alloc] initWithFrame:CGRectZero];
        _praiseButton.tag = 101;
        [_praiseButton setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        _praiseButton.titleLabel.font = kFontWithSize(15);
        [_praiseButton addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_praiseButton];
        
        _lens = [[CALayer alloc] init];
        _lens.frame = CGRectZero;
        _lens.backgroundColor = [UIColor bgColor_Gray].CGColor ;
        [self.contentView.layer addSublayer:_lens];
    }
    return self;
}
- (void)setMyDynamicModel:(TCMyDynamicModel *)myDynamicModel{
    _myDynamicModel = myDynamicModel;
    //头部
    [_myRespondView myResponseModel:_myDynamicModel type:2];
    // 话题
    if (kIsEmptyString(_myDynamicModel.topic) || [_myDynamicModel.topic isEqualToString:@"(null)"] || [_myDynamicModel.topic isEqualToString:@"0"]) {
        _topicLab.hidden = YES;
        _topicLab.frame =CGRectMake(18, _myRespondView.bottom, kScreenWidth-36,0);
    }else{
        _topicLab.hidden = NO;
        NSString *topicStr = [NSString stringWithFormat:@"#%@#",_myDynamicModel.topic];
        [self.topicLab  setText:topicStr customLinks:@[topicStr] keywords:@[@""]];
        CGSize topicSize =[self.topicLab sizeThatFits:CGSizeMake(kScreenWidth - 26, [UIScreen mainScreen].bounds.size.height)];
        _topicLab.frame =CGRectMake(18, _myRespondView.bottom, topicSize.width + 5, 25);
    }
    //内容
    NSMutableArray *atArray = [[NSMutableArray alloc] init];
    if (kIsArray(_myDynamicModel.at_user_id)) {
        for (NSDictionary *dict in _myDynamicModel.at_user_id) {
            [atArray addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    [self.contentLabel setText:_myDynamicModel.news customLinks:atArray keywords:@[]];
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, CGFLOAT_MAX)];
    self.contentLabel.frame = CGRectMake(13, _topicLab.bottom, kScreenWidth-26,contentSize.height>125?126 + 5:contentSize.height);
    
    //查看全部
    _lookAllButton.frame = CGRectMake(20, self.contentLabel.bottom, contentSize.height>125?100:0, contentSize.height>125?20:0);
    
    //图片
    NSMutableArray *image_url = [[NSMutableArray alloc] init];
    NSMutableArray *image_url_resize = [[NSMutableArray alloc] init];
    if (!kIsDictionary(_myDynamicModel.image)) {
        for (NSDictionary *dict in _myDynamicModel.image) {
            [image_url addObject:[NSURL URLWithString:[dict objectForKey:@"image_url"]]];
            [image_url_resize addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
        }
    }
    _picContainerView.picOriArray = image_url;
    CGFloat  picContainerH = [_picContainerView setupPicUrlArray:image_url_resize];
    if (picContainerH > 0) {
       _picContainerView.frame = CGRectMake(20,_lookAllButton.bottom + 10, kScreenWidth-40, picContainerH);
    }else{
       _picContainerView.frame = CGRectMake(20,_lookAllButton.bottom, kScreenWidth-40, 0);
    }
    
    //时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:_myDynamicModel.add_time format:@"yyyy-MM-dd HH:mm"] ;
    _timeLabel.text = [[TCHelper sharedTCHelper] dateToRequiredString:timeStr];
    CGSize timeSize = [_timeLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    _timeLabel.frame =CGRectMake(20, _picContainerView.bottom + 10, timeSize.width + 5,20);
   
    // 置顶图标
    _topImg.hidden=_myDynamicModel.is_top==0;
    _topImg.frame = CGRectMake(_timeLabel.right + 15, _timeLabel.top + 5,_myDynamicModel.is_top == 1 ? 35 : 0, 16);
    
    // 精华图标
    _essenceImg.hidden=_myDynamicModel.is_essence==0;
    _essenceImg.frame = CGRectMake(_topImg.right + (_myDynamicModel.is_top == 1 ? 10 : 0), _timeLabel.top + 5,_myDynamicModel.is_essence == 1 ? 35 : 0, 16);
    
    // 推荐图标
    _recommendImg.hidden=_myDynamicModel.is_recommend==0;
    _recommendImg.frame = CGRectMake(_essenceImg.right + (_myDynamicModel.is_essence == 1 ? 10 : 0), _timeLabel.top + 5,_myDynamicModel.is_recommend == 1 ? 35 : 0, 16);
    
    CGFloat btnW=[_deleteButton.titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, 25) withTextFont:[UIFont systemFontOfSize:15]].width;
    if (_myDynamicModel.is_self==1) {
        _deleteButton.hidden = NO;
        _deleteButton.frame =CGRectMake(_timeLabel.left, _timeLabel.bottom + 5, btnW, 20);
        _line.frame =CGRectMake(20, _deleteButton.bottom + 10, kScreenWidth - 40, 0.5);
    } else {
        _deleteButton.hidden = YES;
        _deleteButton.frame =CGRectMake(_timeLabel.left, _timeLabel.bottom, btnW, 0);
        _line.frame =CGRectMake(20, _deleteButton.bottom + 10, kScreenWidth- 40, 0.5);
    }
    
    //评论/点赞
    _commentsBtn.frame =CGRectMake(0, CGRectGetMaxY(_line.frame), kScreenWidth/2, 40);
    _praiseButton.frame =CGRectMake(kScreenWidth/2, _line.frame.origin.y + _line.frame.size.height, kScreenWidth/2, 40);
    
    _verticalLen.frame =CGRectMake(kScreenWidth/2, _commentsBtn.top+7, 0.5, 26);
    [_commentsBtn setTitle:_myDynamicModel.comment_count>0?[NSString stringWithFormat:@"%ld",(long)_myDynamicModel.comment_count]:@"评论" forState:UIControlStateNormal];
    _praiseButton.selected =_myDynamicModel.like_status;
    
    [_praiseButton setImage:[UIImage imageNamed:_myDynamicModel.like_status==1?@"choose_thumbs":@"thumbs"] forState:UIControlStateNormal];
    [_praiseButton setTitleColor:_myDynamicModel.like_status==1?kbgBtnColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];
    if (_myDynamicModel.like_count>=10000) {
        [_praiseButton setTitle:[NSString stringWithFormat:@"%ld",_myDynamicModel.like_count/10000] forState:UIControlStateNormal];
    } else {
        [_praiseButton setTitle:_myDynamicModel.like_count>0?[NSString stringWithFormat:@"%ld",(long)_myDynamicModel.like_count]:@"赞" forState:UIControlStateNormal];
    }
    _lens.frame = CGRectMake(0, _commentsBtn.bottom, kScreenWidth, 10);
}
-(void)setCellType:(TopicCellType)cellType{
    _cellType = cellType;
}
#pragma mark -- 查看全部／删除
- (void)lookAllButton:(UIButton *)button{
    if (button.tag==100) {
        if ([_topicCellDelegate respondsToSelector:@selector(didClickcLookAllContentInCell:)]) {
            [_topicCellDelegate didClickcLookAllContentInCell:self];
        }
    } else {
        if ([_topicCellDelegate respondsToSelector:@selector(didClickcDeleteDynamicInCell:)]) {
            [_topicCellDelegate didClickcDeleteDynamicInCell:self];
        }
    }
}
#pragma mark -- 查看评论／点赞
- (void)commentsButton:(UIButton *)button{
    if (button.tag == 100) {
        if ([_topicCellDelegate respondsToSelector:@selector(didClickcCommentButtonInCell:)]) {
            [_topicCellDelegate didClickcCommentButtonInCell:self];
        }
    } else {
        if (!_myDynamicModel.like_status) {
            [_praiseButton setImage:[UIImage imageNamed:@"choose_thumbs"] forState:UIControlStateNormal];
            [_praiseButton setTitleColor:kSystemColor forState:UIControlStateNormal];
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@2.0,@0.8,@1.0,@1.1,@1.0];
            animation.duration = 1.2f;
            animation.calculationMode = kCAAnimationCubic;
            [_praiseButton.layer addAnimation:animation forKey:@"transform.scale"];
        }
        if ([_topicCellDelegate respondsToSelector:@selector(didClickLikeButtonInCell:)]) {
            [_topicCellDelegate didClickLikeButtonInCell:self];
        }
    }
}
#pragma mark -- TCMyRespondDelegate
#pragma mark -- 个人信息
- (void)myRespondView{
    if ([_topicCellDelegate respondsToSelector:@selector(didClickcPersonalInfoInCell:)]) {
        [_topicCellDelegate didClickcPersonalInfoInCell:self];
    }
}
#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    MyLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,(long)linkType);
    NSString *topicFirstStr = [clickString substringToIndex:1];
    if ([topicFirstStr isEqualToString:@"#"]) {
        MyLog(@"话题内容是%@",_myDynamicModel.topic);
        if ([_topicCellDelegate respondsToSelector:@selector(didClickTagLinkSeletedContent:clickStrId:role_type:topic_delete_status:topic:)]) {
            [_topicCellDelegate didClickTagLinkSeletedContent:clickString clickStrId:_myDynamicModel.topic_id role_type:_myDynamicModel.role_type topic_delete_status:_myDynamicModel.topic_delete_status topic:_myDynamicModel.topic];
        }
    }else{
        if (kIsArray(_myDynamicModel.at_user_id) && _myDynamicModel.at_user_id.count > 0) {
            NSInteger userID = 0;
            for (NSDictionary *dict in _myDynamicModel.at_user_id) {
                if ([[dict objectForKey:@"nick_name"] isEqualToString:clickString]) {
                    userID = [[dict objectForKey:@"user_id"] integerValue];
                }
            }
            if ([_topicCellDelegate respondsToSelector:@selector(didClickTagLinkSeletedContent:clickStrId:role_type:topic_delete_status:topic:)]) {
                [_topicCellDelegate didClickTagLinkSeletedContent:clickString clickStrId:userID role_type:_myDynamicModel.role_type topic_delete_status:_myDynamicModel.topic_delete_status topic:_myDynamicModel.topic];
            }
        }
    }
}
#pragma mark ====== 点击标记区域之外 =======
- (void)linkMoretag:(NSInteger)tag{
    if ([_topicCellDelegate respondsToSelector:@selector(didClickcDynamicContentInCell:)]) {
        [_topicCellDelegate didClickcDynamicContentInCell:self];
    }
}
#pragma mark -- 返回文本高度
+ (CGFloat)getDynamicContentTextHeightWithDynamic:(TCMyDynamicModel *)model{
    //话题高度
    NSInteger topicHeight = 0;
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
        topicHeight = 25;
    }else{
        topicHeight = 0;
    }
    //计算文字高度
    NSMutableArray *customArr = [[NSMutableArray alloc] init];
    if (kIsArray(model.at_user_id)) {
        for (NSDictionary *dict in model.at_user_id) {
            [customArr addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(65, 70, kScreenWidth-75-20, 0)];
    contentLabel.lineSpacing = 1.5;
    contentLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    [contentLabel setText:model.news customLinks:customArr keywords:@[@""]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
    CGFloat contentHeight =[contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, [UIScreen mainScreen].bounds.size.height)].height;
    contentHeight = contentHeight > 125 ? 126  : contentHeight;
    //查看全文
    NSInteger allHeight = contentHeight > 125 ? 25 : 0;
    
    //计算图片高度
    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in model.image) {
        [picUrlArr addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
    }
    YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
    float photoheight = [picContainerView setupPicUrlArray:picUrlArr];
    photoheight = photoheight > 0 ? photoheight + 10:0;
    //是否自己
    NSInteger isself = model.is_self==0?0:25;
    //时间
    NSInteger timeHeight = 30;
    return contentHeight + photoheight + topicHeight + allHeight + isself + timeHeight + 114.5;
}
#pragma mark -- getter
// 动态内容
- (MYCoreTextLabel *)contentLabel{
    if (_contentLabel==nil) {
        _contentLabel = [[MYCoreTextLabel alloc]init];
        //设置普通文本的属性
        _contentLabel.textFont = [UIFont systemFontOfSize:KDynamicTextFont];   //设置普通内容文字大小
        _contentLabel.textColor = UIColorFromRGB(0x313131);   // 设置普通内容文字颜色
        _contentLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        _contentLabel.wordSpacing = 0.5;
        _contentLabel.lineSpacing = 1.5;
        _contentLabel.customLinkColor = kSystemColor;
        _contentLabel.customLinkFont = [UIFont systemFontOfSize:KDynamicTextFont];
    }
    return _contentLabel;
}
// 话题
- (MYCoreTextLabel *)topicLab{
    if (_topicLab == nil) {
        _topicLab = [[MYCoreTextLabel alloc]init];
        //设置 #话题#的属性
        //设置普通文本的属性
        _topicLab.textFont = [UIFont systemFontOfSize:KDynamicTextFont];   //设置普通内容文字大小
        _topicLab.textColor = UIColorFromRGB(0x313131);   // 设置普通内容文字颜色
        _topicLab.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        _topicLab.wordSpacing = 0.5;
        _topicLab.lineSpacing = 1.5;
        _topicLab.showTopicLink = YES;
        _topicLab.topicLinkFont = [UIFont systemFontOfSize:KDynamicTextFont];
        _topicLab.topicLinkColor = kSystemColor;
        _topicLab.customLinkColor = kSystemColor;
        _topicLab.customLinkFont = [UIFont systemFontOfSize:KDynamicTextFont];
    }
    return _topicLab;
}
@end
