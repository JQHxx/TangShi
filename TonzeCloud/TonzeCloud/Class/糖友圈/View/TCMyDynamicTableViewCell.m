//
//  TCMyDynamicTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyDynamicTableViewCell.h"
#import "TCMyDynamicButton.h"
#import "YHWorkGroupPhotoContainer.h"
#import "TCPraiseButton.h"
#import "TCMyResponseView.h"
#import "MYCoreTextLabel.h"

@interface TCMyDynamicTableViewCell ()<MYCoreTextLabelDelegate,TCMyRespondDelegate>{
    
    TCMyResponseView  *myRespondView;
    
    UIButton          *topicButton;
    UILabel           *timeLabel;
    UIButton          *lookAllButton;
    UIButton          *deleteButton;
    UIView              *lenView;

    UIImageView       *essenceImg;      // 精华标签
    UIImageView       *recommendImg;    // 推荐标签
    UIImageView       *topImg;          // 置顶标签
    
    YHWorkGroupPhotoContainer *picContainerView;
    UILabel           *lineLabel;
    UIButton          *commentsBtn;
    UIButton          *praiseButton;
    UILabel           *line;
    UIView            *bgView;
    
    TCMyDynamicModel  *commentsModel;
    NSInteger          indexPathRow;
    CGFloat            picContainerH;
    
    BOOL               isPraise;
}
@property (nonatomic, strong) MYCoreTextLabel *contentLabel;
@end
@implementation TCMyDynamicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isPraise = YES;
        
        myRespondView = [[TCMyResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        myRespondView.delegate = self;
        [self.contentView addSubview:myRespondView];
        
        topicButton = [[UIButton alloc] initWithFrame:CGRectMake(15, myRespondView.bottom, kScreenWidth, 20)];
        topicButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [topicButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        [topicButton addTarget:self action:@selector(topicButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:topicButton];
        
        [self.contentView addSubview:self.contentLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.contentLabel.bottom, kScreenWidth/2, 20)];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:timeLabel];
        
        essenceImg = [[UIImageView alloc]initWithFrame:CGRectMake(timeLabel.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:essenceImg];
        
        recommendImg =[[UIImageView alloc]initWithFrame:CGRectMake(essenceImg.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:recommendImg];
        
        topImg = [[UIImageView alloc]initWithFrame:CGRectMake(recommendImg.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:topImg];
        
        lookAllButton = [[UIButton alloc] initWithFrame:CGRectMake(20, timeLabel.bottom+10, 50, 20)];
        lookAllButton.tag =100;
        lookAllButton.titleLabel.font = [UIFont systemFontOfSize:13];
        lookAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [lookAllButton setTitle:@"查看全文" forState:UIControlStateNormal];
        [lookAllButton setImage:[UIImage imageNamed:@"lookAtAll"] forState:UIControlStateNormal];
        [lookAllButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        [lookAllButton setTitleColor:UIColorFromRGB(0x959595) forState:UIControlStateNormal];
        
        [lookAllButton addTarget:self action:@selector(lookAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:lookAllButton];
        
        picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        [self.contentView addSubview:picContainerView];
        
        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(lookAllButton.right+20, timeLabel.bottom+10, 40, 20)];
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        deleteButton.tag = 101;
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        deleteButton.titleLabel.textColor = [UIColor blackColor];
        [deleteButton addTarget:self action:@selector(lookAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
        
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, picContainerView.bottom+10, kScreenWidth-36, 0.3)];
        lineLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lineLabel];
        
        commentsBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, lineLabel.bottom, kScreenWidth/2, 40)];
        [commentsBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [commentsBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        commentsBtn.titleLabel.font = kFontWithSize(14);
        [commentsBtn  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
        commentsBtn.tag = 100;
        [commentsBtn addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:commentsBtn];
        
        line = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, commentsBtn.top+7, 1, 26)];
        line.backgroundColor = [UIColor colorWithHexString:@"0xdcdcdc"];
        [self.contentView addSubview:line];
        
        praiseButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, lineLabel.bottom, kScreenWidth/2, 40)];
        [praiseButton setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        praiseButton.titleLabel.font = kFontWithSize(14);
        [praiseButton  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
        praiseButton.tag = 101;
        [praiseButton addTarget:self action:@selector(commentsButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:praiseButton];
        
        lenView = [[UIView alloc] initWithFrame:CGRectMake(0, commentsBtn.bottom, kScreenWidth, 0)];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
    }
    return self;
}
- (void)cellMyDynamicModel:(TCMyDynamicModel *)model{
    commentsModel = model;
    indexPathRow = model.news_id;
    //头部
    [myRespondView myResponseModel:model type:2];
    
    //话题
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
    [topicButton setTitle:[NSString stringWithFormat:@"#%@#",model.topic] forState:UIControlStateNormal];
    CGSize size = [topicButton.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    topicButton.frame =CGRectMake(20, myRespondView.bottom, size.width, 25);
    }else{
    topicButton.frame =CGRectMake(20, myRespondView.bottom, 0, 0);
    }
    //内容
    NSMutableArray *customArr = [[NSMutableArray alloc] init];
    if (kIsArray(model.at_user_id)) {
        for (NSDictionary *dict in model.at_user_id) {
            [customArr addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    [self.contentLabel setText:model.news customLinks:customArr keywords:@[@""]];
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, [UIScreen mainScreen].bounds.size.height)];
    self.contentLabel.frame = CGRectMake(13, topicButton.bottom, kScreenWidth-26,size.height>125?126:size.height);
    //查看全部
    lookAllButton.frame = CGRectMake(20, self.contentLabel.bottom+5, size.height>125?70:0, size.height>125?20:0);

    //图片
    NSMutableArray *picOriArr = [[NSMutableArray alloc] init];
    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in model.image) {
        [picOriArr addObject:[NSURL URLWithString:[dict objectForKey:@"image_url"]]];
        [picUrlArr addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
    }
    picContainerView.picOriArray = picOriArr;
    picContainerH = [picContainerView setupPicUrlArray:picUrlArr];
    picContainerView.frame = CGRectMake(18, lookAllButton.bottom+10, kScreenWidth-36,picContainerH);
    //时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    size = [timeLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    timeLabel.frame =CGRectMake(18, picUrlArr.count>0?picContainerView.bottom+10:lookAllButton.bottom+5, size.width, 20);
    deleteButton.frame = CGRectMake(18, timeLabel.bottom+10, 40, 20);
    
    // 热推图标
    // 置顶图标
    if (model.is_top == 1) {
        topImg.image = [UIImage imageNamed:@"top"];
    }
    topImg.frame = CGRectMake(timeLabel.right + 15, timeLabel.top + 2,model.is_top == 1 ? 35 : 0, 16);
    
    // 精华图标
    if (model.is_essence == 1) {
        essenceImg.image =[UIImage imageNamed:@"best"];
    }
    essenceImg.frame = CGRectMake(topImg.right + (model.is_top == 1 ? 10 : 0), timeLabel.top + 2,model.is_essence == 1 ? 35 : 0, 16);
    
    // 推荐图标
    if (model.is_recommend == 1) {
        recommendImg.image = [UIImage imageNamed:@"introduce"];
    }
    recommendImg.frame = CGRectMake(essenceImg.right + (model.is_essence == 1 ? 10 : 0), timeLabel.top + 2,model.is_recommend == 1 ? 35 : 0, 16);
    
    size = [deleteButton.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    deleteButton.frame =CGRectMake(timeLabel.left, timeLabel.bottom+5, size.width, 20);
    //评论/点赞
    if (model.is_self==0) {
        deleteButton.hidden = YES;
        lineLabel.frame =CGRectMake(18, timeLabel.bottom+10, kScreenWidth-36, 0.3);
    }else{
        deleteButton.hidden = NO;
        lineLabel.frame =CGRectMake(18, deleteButton.bottom+10, kScreenWidth-36, 0.3);
    }
    commentsBtn.frame =CGRectMake(18, lineLabel.bottom, kScreenWidth/2-18, 40);
    praiseButton.frame =CGRectMake(kScreenWidth/2, lineLabel.bottom, kScreenWidth/2-18, 40);
    line.frame =CGRectMake(kScreenWidth/2, commentsBtn.top+7, 1, 26);
    [commentsBtn setTitle:model.comment_count>0?[NSString stringWithFormat:@"%ld",(long)model.comment_count]:@"评论" forState:UIControlStateNormal];
    [praiseButton setImage:[UIImage imageNamed:model.like_status==1?@"choose_thumbs":@"thumbs"] forState:UIControlStateNormal];
    [praiseButton setTitleColor:model.like_status==1?kbgBtnColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];

    if (model.like_count>=10000) {
        [praiseButton setTitle:[NSString stringWithFormat:@"%ld",model.like_count/10000] forState:UIControlStateNormal];
    } else  if(model.like_count==0){
        [praiseButton setTitle:@"赞" forState:UIControlStateNormal];
    } else{
        [praiseButton setTitle:model.like_count>0?[NSString stringWithFormat:@"%ld",(long)model.like_count]:@"赞" forState:UIControlStateNormal];
    }
    lenView.frame = CGRectMake(0, commentsBtn.bottom, kScreenWidth, 10);

}

#pragma mark -- 返回文本高度
+ (CGFloat)getDynamicContentTextHeightWithDynamic:(TCMyDynamicModel *)model{
    //计算文字高度
    NSMutableArray *customArr = [[NSMutableArray alloc] init];
    if (kIsArray(model.at_user_id)) {
        for (NSDictionary *dict in model.at_user_id) {
            [customArr addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(65, 70, kScreenWidth-75-20, 0)];
    contentLabel.lineSpacing = 0.5;
    contentLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    [contentLabel setText:model.news customLinks:customArr keywords:@[@""]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];
    contentLabel.textColor = [UIColor blackColor];
    
    //设置关键字的属性
    contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
    contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    CGFloat contentHeight =[contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, [UIScreen mainScreen].bounds.size.height)].height;
    contentHeight = contentHeight>125+5?125:contentHeight+5;
    
    //计算图片高度
    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in model.image) {
        [picUrlArr addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
    }
    YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
    float height = [picContainerView setupPicUrlArray:picUrlArr];
    height = height>0?height+10:0;
    
    //话题高度
    NSInteger topicHeight = 0;
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
        topicHeight = 25;
    }else{
        topicHeight = 0;
    }
    //是否自己
    NSInteger isself = model.is_self==0?0:25;
    
    //查看全文
    NSInteger allHeight = contentHeight==125?25:0;
    
    //时间
    NSInteger timeHeight = picUrlArr.count>0?30:25;
    return contentHeight+height+topicHeight+allHeight+isself+timeHeight+114.3;
}
#pragma mark -- 查看话题
- (void)topicButton{
    if ([_delegate respondsToSelector:@selector(myLookTopicDetail:topic_delete_status:topic:)]) {
        [_delegate myLookTopicDetail:commentsModel.topic_id topic_delete_status:commentsModel.topic_delete_status topic:commentsModel.topic];
    }
}
#pragma mark -- 查看全部／删除
- (void)lookAllButton:(UIButton *)button{

    if (button.tag==100) {
        if ([_delegate respondsToSelector:@selector(lookAllContent:)]) {
            [_delegate lookAllContent:commentsModel];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(deleteContent:role_type:)]) {
            [_delegate deleteContent:indexPathRow role_type:commentsModel.role_type];
        }
    }
}

#pragma mark -- 查看评论／点赞
- (void)commentsButton:(UIButton *)button{
    if (button.tag == 100) {
        if (self.reviewClick) {
            self.reviewClick();
        }
    } else {
        if (isPraise==YES) {
            [[TCHelper sharedTCHelper] loginClick:@"008-07-06"];
            [MobClick event:@"105_002041"];
            NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=0&is_like=%d",(long)commentsModel.news_id,(long)commentsModel.user_id,(long)commentsModel.role_type,commentsModel.like_status==1?0:1];
            [[TCHttpRequest  sharedTCHttpRequest] postMethodWithURL:KDynamicDoLike body:body success:^(id json) {
                isPraise = YES;
                if ([_delegate respondsToSelector:@selector(myPreiseDynamic:)]) {
                    [_delegate myPreiseDynamic:commentsModel];
                }
            } failure:^(NSString *errorStr) {
                
            }];
            isPraise = NO;
        }
    }
}
#pragma mark -- getter
- (UIView *)contentLabel{
    if (_contentLabel==nil) {
        _contentLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectZero];
        _contentLabel.lineSpacing = 1.5;
        _contentLabel.wordSpacing = 0.5;
        //设置普通文本的属性
        _contentLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x313131"];   // 设置普通内容文字颜色
        _contentLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置关键字的属性
        _contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
        _contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    }
    return _contentLabel;
}

#pragma mark -- MYCoreTextLabelDelegate
#pragma mark -- 点击标记区域
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    NSInteger newsID = 0;
    NSInteger role_type = 0;
    for (NSDictionary *dict in commentsModel.at_user_id) {
        
        if ([[dict objectForKey:@"nick_name"] isEqualToString:clickString]) {
            newsID = [[dict objectForKey:@"user_id"] integerValue];
            role_type =[[dict objectForKey:@"role_type_ed"] integerValue];
        }
    }
    if ([_delegate respondsToSelector:@selector(myLinSeletedContent:role_type:)]) {
        [_delegate myLinSeletedContent:newsID role_type:role_type];
    }

}
#pragma mark -- 点击未标记区域
- (void)linkMoretag:(NSInteger)tag{
    if (self.dynamicContentClickBlock) {
        self.dynamicContentClickBlock();
    }
}
#pragma mark -- 点击用户头像
- (void)myRespondView{
    if ([_delegate respondsToSelector:@selector(myLinkUserInfo:)]) {
        [_delegate myLinkUserInfo:commentsModel];
    }
}
@end
