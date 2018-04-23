//
//  TCDynamicTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDynamicTableViewCell.h"
#import "TCMyDynamicButton.h"
#import "YHWorkGroupPhotoContainer.h"
#import "TCPraiseButton.h"
#import "TCMyResponseView.h"
#import "MYCoreTextLabel.h"

@interface TCDynamicTableViewCell ()<TCMyRespondDelegate,MYCoreTextLabelDelegate>{
    
    TCMyResponseView  *myRespondView;
    
    UIButton          *topicButton;
    UILabel           *timeLabel;
    UIButton          *deleteButton;
    UIImageView       *essenceImg;      // 精华标签
    UIImageView       *recommendImg;    // 推荐标签
    UIImageView       *topImg;          // 置顶标签
    
    YHWorkGroupPhotoContainer *picContainerView;
    UILabel           *lineLabel;
    UIButton          *commentsBtn;
    UIButton          *praiseButton;
    UILabel           *line;
    UIView            *bgView;
    UIView            *lenView;

    BOOL               isPraise;
    TCMyDynamicModel   *commentsModel;
}

@property (nonatomic, strong) MYCoreTextLabel *contentLabel;

@end
@implementation TCDynamicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //个人信息
        myRespondView = [[TCMyResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        myRespondView.delegate = self;
        [self.contentView addSubview:myRespondView];
        
        //话题
        topicButton = [[UIButton alloc] initWithFrame:CGRectZero];
        topicButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [topicButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        [topicButton addTarget:self action:@selector(topicDynamicButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:topicButton];
        
        //内容
        [self.contentView addSubview:self.contentLabel];
        
        //图片组
        picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        [self.contentView addSubview:picContainerView];
        
        //时间
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:timeLabel];
        
        //置顶、精华、推荐
        topImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        topImg.image = [UIImage imageNamed:@"top"];
        [self.contentView addSubview:topImg];
        topImg.hidden=YES;
        
        essenceImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        essenceImg.image =[UIImage imageNamed:@"best"];
        [self.contentView addSubview:essenceImg];
        essenceImg.hidden=YES;
        
        recommendImg =[[UIImageView alloc]initWithFrame:CGRectZero];
        recommendImg.image = [UIImage imageNamed:@"introduce"];
        [self.contentView addSubview:recommendImg];
        recommendImg.hidden=YES;
        
        //删除
        deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteButton addTarget:self action:@selector(deleteDynamic) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xdcdcdc"];
        [self.contentView addSubview:lineLabel];
        
        //评论
        commentsBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [commentsBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [commentsBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        commentsBtn.titleLabel.font = kFontWithSize(15);
        [commentsBtn  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        commentsBtn.tag = 100;
        [commentsBtn addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:commentsBtn];
        
        line = [[UILabel alloc] initWithFrame:CGRectZero];
        line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self.contentView addSubview:line];
        
        //点赞
        praiseButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [praiseButton setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        praiseButton.titleLabel.font = kFontWithSize(15);
        [praiseButton  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        praiseButton.tag = 101;
        [praiseButton addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:praiseButton];
        
        lenView = [[UIView alloc] initWithFrame:CGRectZero];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
        
    }
    return self;
}
- (void)cellDynamicDetailModel:(TCMyDynamicModel *)model{
    commentsModel = model;
    //头部
    [myRespondView myResponseModel:model type:1];
    
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
        topicButton.hidden = NO;
        [topicButton setTitle:[NSString stringWithFormat:@"#%@#",model.topic] forState:UIControlStateNormal];
        CGSize size = [topicButton.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        topicButton.frame =CGRectMake(18, myRespondView.bottom, size.width+5, 20);
    }else{
        topicButton.hidden = YES;
        topicButton.frame =CGRectMake(18, myRespondView.bottom, kScreenWidth-36, 0);
    }

    //内容
    NSMutableArray *atArray = [[NSMutableArray alloc] init];
    if (kIsArray(model.at_user_id)) {
        for (NSDictionary *dict in model.at_user_id) {
            [atArray addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    [self.contentLabel setText:model.news customLinks:atArray keywords:@[]];
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, CGFLOAT_MAX)];
    self.contentLabel.frame = CGRectMake(13, topicButton.bottom, kScreenWidth-26, contentSize.height);

    //图片
    NSMutableArray *image_url = [[NSMutableArray alloc] init];
    NSMutableArray *image_url_resize = [[NSMutableArray alloc] init];
    if (!kIsDictionary(model.image)) {
        for (NSDictionary *dict in model.image) {
            [image_url addObject:[NSURL URLWithString:[dict objectForKey:@"image_url"]]];
            [image_url_resize addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
        }
    }
    picContainerView.picOriArray = image_url;
    CGFloat  picContainerH = [picContainerView setupPicUrlArray:image_url_resize];
    picContainerView.frame = CGRectMake(18, self.contentLabel.bottom+5, kScreenWidth-36, picContainerH);
    
    //时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper] dateToRequiredString:timeStr];
    CGSize timeSize = [timeLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    if (model.image.count>0) {
        timeLabel.frame =CGRectMake(18, picContainerView.bottom+5, timeSize.width+10,30);
    }else{
        timeLabel.frame =CGRectMake(18, self.contentLabel.bottom, timeSize.width+10,30);
    }
    
    // 置顶图标
    topImg.hidden=model.is_top==0;
    topImg.frame = CGRectMake(timeLabel.right + 15, timeLabel.top + 7,model.is_top == 1 ? 35 : 0, 16);
    
    // 精华图标
    essenceImg.hidden=model.is_essence==0;
    essenceImg.frame = CGRectMake(topImg.right + (model.is_top == 1 ? 10 : 0), timeLabel.top + 7,model.is_essence == 1 ? 35 : 0, 16);
    
    // 推荐图标
    recommendImg.hidden=model.is_recommend==0;
    recommendImg.frame = CGRectMake(essenceImg.right + (model.is_essence == 1 ? 10 : 0), timeLabel.top + 7,model.is_recommend == 1 ? 35 : 0, 16);

    CGFloat btnW=[deleteButton.titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, 25) withTextFont:[UIFont systemFontOfSize:15]].width;
    if (model.is_self==1) {
        deleteButton.hidden = NO;
        deleteButton.frame =CGRectMake(timeLabel.left, timeLabel.bottom, btnW, 20);
    } else {
        deleteButton.hidden = YES;
        deleteButton.frame =CGRectMake(timeLabel.left, timeLabel.bottom, btnW, 0);
    }
    
    lineLabel.frame =CGRectMake(0, deleteButton.bottom+5, kScreenWidth, 0.5);
    
    //评论/点赞
    commentsBtn.frame =CGRectMake(0, lineLabel.bottom, kScreenWidth/2, 40);
    praiseButton.frame =CGRectMake(kScreenWidth/2, lineLabel.bottom, kScreenWidth/2, 40);
    
    line.frame =CGRectMake(kScreenWidth/2, commentsBtn.top+7, 0.5, 26);
    [commentsBtn setTitle:model.comment_count>0?[NSString stringWithFormat:@"%ld",(long)model.comment_count]:@"评论" forState:UIControlStateNormal];
    praiseButton.selected =model.like_status;
    
    [praiseButton setImage:[UIImage imageNamed:model.like_status==1?@"choose_thumbs":@"thumbs"] forState:UIControlStateNormal];
    [praiseButton setTitleColor:model.like_status==1?kbgBtnColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];
    if (model.like_count>=10000) {
        [praiseButton setTitle:[NSString stringWithFormat:@"%ld",model.like_count/10000] forState:UIControlStateNormal];
    } else {
        [praiseButton setTitle:model.like_count>0?[NSString stringWithFormat:@"%ld",(long)model.like_count]:@"赞" forState:UIControlStateNormal];
    }
    
    lenView.frame = CGRectMake(0, praiseButton.bottom, kScreenWidth, 10);
}
#pragma mark ====== 计算cell的高度 =======
+(CGFloat)getCellContentHeightWithModel:(TCMyDynamicModel *)model{
    CGFloat topicH=0.0;
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
        topicH=20;
    }
    //文字
    NSMutableArray *atArray = [[NSMutableArray alloc] init];
    if (kIsArray(model.at_user_id)) {
        for (NSDictionary *dict in model.at_user_id) {
            [atArray addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    MYCoreTextLabel *coreLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectZero];
    coreLabel.lineSpacing = 1.5;
    coreLabel.wordSpacing = 0.5;
    coreLabel.textColor = [UIColor blackColor];
    coreLabel.textFont = [UIFont systemFontOfSize:16.f];
    coreLabel.customLinkFont = [UIFont systemFontOfSize:16];
    [coreLabel setText:model.news customLinks:atArray keywords:@[]];
    CGFloat textHeight = [coreLabel sizeThatFits:CGSizeMake(kScreenWidth-26,CGFLOAT_MAX)].height;
    
    //图片
    CGFloat imageH=0.0;
    if (model.image.count>0) {
        YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        imageH = [picContainerView setupPicUrlArray:model.image]+5;
    }
    
    CGFloat timeH=30; //时间高度
    CGFloat btnH=model.is_self==1?20:0;//删除按钮高度
    return 54+topicH+textHeight+5+imageH+timeH+btnH+45+10;
}

#pragma mark -- 返回图片高度
+ (CGFloat)getContentImagesHeightForModel:(TCMyDynamicModel *)model{
    YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
    float height = [picContainerView setupPicUrlArray:model.image];
    return height;
}

#pragma mark -- 删除动态
- (void)deleteDynamic{
    if ([_delegate respondsToSelector:@selector(myDynamicDelete:)]) {
        [_delegate myDynamicDelete:commentsModel];
    }
}
#pragma mark -- 话题详情
- (void)topicDynamicButton{
    if ([_delegate respondsToSelector:@selector(myDynamicTopicDetail:topic_delete_status:topic:)]) {
        [_delegate myDynamicTopicDetail:commentsModel.topic_id topic_delete_status:commentsModel.topic_delete_status topic:commentsModel.topic];
    }
}
#pragma mark -- 评论／点赞
- (void)commentsButton:(UIButton *)button{
    if (button.tag == 100) {
        if ([_delegate respondsToSelector:@selector(myDynamicDetailComment:)]) {
            [_delegate myDynamicDetailComment:commentsModel];
        }
    } else {
        praiseButton.selected = !praiseButton.selected;
        if ([_delegate respondsToSelector:@selector(myDynamicDetailPraise:type:)]) {
            [_delegate myDynamicDetailPraise:commentsModel type:praiseButton.selected];
        }
    }
}
#pragma mark -- getter
- (UIView *)contentLabel{
    if (_contentLabel==nil) {
        _contentLabel = [[MYCoreTextLabel alloc] init];
        _contentLabel.lineSpacing = 1.5;
        _contentLabel.wordSpacing = 0.5;
        
        //设置普通文本的属性
        _contentLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _contentLabel.textColor = [UIColor blackColor];   // 设置普通内容文字颜色
        _contentLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置关键字的属性
        _contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
        _contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    }
    return _contentLabel;
}
#pragma mark -- TCMyRespondDelegate
#pragma mark -- 个人信息
- (void)myRespondView{
    if ([_delegate respondsToSelector:@selector(myDynamicDetailContent:)]) {
        [_delegate myDynamicDetailContent:commentsModel];
    }
}

#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    NSInteger userId = 0;
    NSInteger role_type = 0;
    for (NSDictionary *dict in commentsModel.at_user_id) {
        if ([[dict objectForKey:@"nick_name"] isEqualToString:clickString]) {
            userId = [[dict objectForKey:@"user_id"] integerValue];
            role_type =[[dict objectForKey:@"role_type_ed"] integerValue];
            if ([_delegate respondsToSelector:@selector(myLinkDetailSeleted:role_type:)]) {
                [_delegate myLinkDetailSeleted:userId role_type:role_type];
            }
            return;
        }
    }
}

@end
