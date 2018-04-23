//
//  TCLookForMyTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLookForMyTableViewCell.h"
#import "TCMyDynamicButton.h"
#import "YHWorkGroupPhotoContainer.h"
#import "TCPraiseButton.h"
#import "TCMyResponseView.h"
#import "MYCoreTextLabel.h"
#import "JSONKit.h"

@interface TCLookForMyTableViewCell ()<TCMyRespondDelegate,MYCoreTextLabelDelegate>{
    
    TCMyResponseView  *myRespondView;
    
    UIButton          *topicButton;
    UILabel           *timeLabel;
    UIImageView       *essenceImg;      // 精华标签
    UIImageView       *recommendImg;    // 推荐标签
    UIImageView       *topImg;          // 置顶标签
    
    YHWorkGroupPhotoContainer *picContainerView;
    UILabel           *lineLabel;
    UIButton          *commentsBtn;
    UIButton          *praiseButton;
    UILabel           *line;
    UIView            *lenView;
    BOOL               seletedBool;
    
    NSInteger          indexPathRow;
    CGFloat            picContainerH;
    
    NSArray            *jsonArr;
    NSDictionary       *newsDict;
    TCLookFoMyModel    *lookForModel;
}
@property (nonatomic, strong) MYCoreTextLabel *contentLabel;
@end
@implementation TCLookForMyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myRespondView = [[TCMyResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        myRespondView.delegate = self;
        [self.contentView addSubview:myRespondView];
        
        topicButton = [[UIButton alloc] initWithFrame:CGRectMake(14, myRespondView.bottom, kScreenWidth, 20)];
        topicButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [topicButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        [topicButton addTarget:self action:@selector(topicButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:topicButton];
        
        [self.contentView addSubview:self.contentLabel];
        
        picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        [self.contentView addSubview:picContainerView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, self.contentLabel.bottom, kScreenWidth/2, 20)];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:timeLabel];
        
        essenceImg = [[UIImageView alloc]initWithFrame:CGRectMake(timeLabel.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:essenceImg];
        
        recommendImg =[[UIImageView alloc]initWithFrame:CGRectMake(essenceImg.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:recommendImg];
        
        topImg = [[UIImageView alloc]initWithFrame:CGRectMake(recommendImg.right, timeLabel.top, 35 ,16)];
        [self.contentView addSubview:topImg];

        
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
        
        lenView = [[UIView alloc] initWithFrame:CGRectMake(0, praiseButton.bottom, kScreenWidth, 0)];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
    }
    return self;
}
- (void)cellLookForMyModel:(TCLookFoMyModel *)model{
    indexPathRow = model.news_id;
    newsDict = model.news_info;
    lookForModel = model;
    //头部
    [myRespondView myLookForMyModel:model];

    //话题
    if (!kIsEmptyString(model.topic)&&![model.topic isEqualToString:@"0"]&&![model.topic isEqualToString:@"(null)"]) {
        [topicButton setTitle:[NSString stringWithFormat:@"#%@#",model.topic] forState:UIControlStateNormal];
        CGSize size = [topicButton.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        topicButton.frame =CGRectMake(20, myRespondView.bottom, size.width, 25);
    }else{
        topicButton.frame =CGRectMake(20, myRespondView.bottom, 0, 0);
    }
    //内容
    jsonArr= [model.news_info objectForKey:@"at_json"];
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in jsonArr) {
        NSString *nickname =[dict objectForKey:@"nick_name"];
        [jsonArray addObject:nickname];
    }
    [self.contentLabel setText:[model.news_info objectForKey:@"news"] customLinks:jsonArray keywords:@[@"关键字"]];
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-30, [UIScreen mainScreen].bounds.size.height)];
    self.contentLabel.frame = CGRectMake(15, topicButton.bottom, kScreenWidth-30,size.height);
    //图片
    NSArray *imgArr =[model.news_info objectForKey:@"image"];
    NSMutableArray *picOriArr = [[NSMutableArray alloc] init];
    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    for (NSDictionary *imgDict in imgArr) {
        [picOriArr addObject:[NSURL URLWithString:[imgDict objectForKey:@"image_url"]]];
        [picUrlArr addObject:[imgDict objectForKey:@"image_url_resize"]];
    }
    picContainerView.picOriArray = picOriArr;
    picContainerH = [picContainerView setupPicUrlArray:picUrlArr];
    picContainerView.frame = CGRectMake(18, self.contentLabel.bottom+10, kScreenWidth-36, picContainerH);
    
    //时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    size = [timeLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    if (imgArr.count>0) {
        timeLabel.frame =CGRectMake(18, picContainerView.bottom+5, size.width, 20);
    }else{
        timeLabel.frame =CGRectMake(18, self.contentLabel.bottom+5, size.width, 20);
    }
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

    //评论/点赞
    lineLabel.frame =CGRectMake(18, timeLabel.bottom+10, kScreenWidth-36, 0.3);
    commentsBtn.frame =CGRectMake(18, lineLabel.bottom, kScreenWidth/2-18, 40);
    praiseButton.frame =CGRectMake(kScreenWidth/2, lineLabel.bottom, kScreenWidth/2-18, 40);
    line.frame =CGRectMake(kScreenWidth/2, commentsBtn.top+7, 1, 26);
    if ([[model.news_info objectForKey:@"comment_count"] integerValue]>0) {
        [commentsBtn setTitle:[NSString stringWithFormat:@"%@",[model.news_info objectForKey:@"comment_count"]] forState:UIControlStateNormal];
    } else {
        [commentsBtn setTitle:@"评论" forState:UIControlStateNormal];
    }
    [praiseButton setImage:[UIImage imageNamed:[[model.news_info objectForKey:@"is_like"] integerValue]==1?@"choose_thumbs":@"thumbs"] forState:UIControlStateNormal];
        [praiseButton setTitleColor:[[model.news_info objectForKey:@"is_like"] integerValue]==1?kbgBtnColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];
    if ([[model.news_info objectForKey:@"like_count"] integerValue]>=10000) {
        [praiseButton setTitle:[NSString stringWithFormat:@"%ld",[[model.news_info objectForKey:@"like_count"] integerValue]/10000] forState:UIControlStateNormal];
    } else {
        if ([[model.news_info objectForKey:@"like_count"] integerValue]>0) {
            [praiseButton setTitle:[NSString stringWithFormat:@"%@",[model.news_info objectForKey:@"like_count"]] forState:UIControlStateNormal];
        } else {
            [praiseButton setTitle:@"赞" forState:UIControlStateNormal];
        }
    }
    lenView.frame = CGRectMake(0, praiseButton.bottom+2, kScreenWidth, 10);
}
#pragma mark -- 返回文本高度
+ (CGFloat)tableView:(UITableView *)tableView rowLookForMyHeightForModel:(TCLookFoMyModel *)model{
    //计算文字高度
    NSMutableArray *customArr = [model.news_info objectForKey:@"at_json"];
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in customArr) {
        NSString *nickname =[dict objectForKey:@"nick_name"];
        [jsonArray addObject:nickname];
    }
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(65, 70, kScreenWidth-75-20, 0)];
    contentLabel.lineSpacing = 0.5;
    contentLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    [contentLabel setText:[model.news_info objectForKey:@"news"] customLinks:jsonArray keywords:@[]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];
    contentLabel.textColor = [UIColor blackColor];
    
    //设置关键字的属性
    contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
    contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    CGFloat contentHeight =[contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, [UIScreen mainScreen].bounds.size.height)].height;
    
    //计算图片高度
    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [model.news_info objectForKey:@"image"]) {
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
    //时间
    NSInteger timeHeight = 25;
    
    return contentHeight+height+topicHeight+timeHeight+114.3;
}
#pragma mark -- 返回图片高度
+ (CGFloat)tableView:(UITableView *)tableView toLookForMyCalculateHeight:(NSArray *)imgArray{
    YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-20];
    float height = [picContainerView setupPicUrlArray:imgArray];
    return height;
}
#pragma mark -- 查看话题
- (void)topicButton{
    if ([_delegate respondsToSelector:@selector(myLinkTopic:topic_delete_status:topic:)]) {
        [_delegate myLinkTopic:[[lookForModel.news_info objectForKey:@"topic_id"] integerValue] topic_delete_status:[lookForModel.news_info objectForKey:@"topic_delete_status"] topic:[lookForModel.news_info objectForKey:@"topic"]];
    }
}
#pragma mark -- 查看评论／点赞
- (void)commentsButton:(UIButton *)button{
    if (button.tag == 100) {
        if ([_delegate respondsToSelector:@selector(commentsLookForMyContent:User_id:role_type_ed:)]) {
            [_delegate commentsLookForMyContent:indexPathRow User_id:lookForModel.at_user_id role_type_ed:[[newsDict objectForKey:@"role_type"] integerValue]];
        }
    } else {
        [[TCHelper sharedTCHelper] loginClick:@"008-13-06"];
        [MobClick event:@"105_003018"];
        NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=0&is_like=%d",(long)lookForModel.news_id,(long)lookForModel.at_user_id,(long)lookForModel.role_type,[[lookForModel.news_info objectForKey:@"is_like"] integerValue]==1?0:1];
        [[TCHttpRequest  sharedTCHttpRequest] postMethodWithURL:KDynamicDoLike body:body success:^(id json) {
            if ([_delegate respondsToSelector:@selector(myPraiseDynamic:)]) {
                [_delegate myPraiseDynamic:lookForModel];
            }

        } failure:^(NSString *errorStr) {
            
        }];

    }
}
#pragma mark -- getter
- (UIView *)contentLabel{
    if (_contentLabel==nil) {
        _contentLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(5, 10,kScreenWidth-10, 20)];
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
#pragma mark -- TCMyRespondDelegate
#pragma mark -- 个人信息
- (void)myRespondView{
    if ([_delegate respondsToSelector:@selector(myDynamicLookForMyContent:)]) {
        [_delegate myDynamicLookForMyContent:lookForModel];
    }
}

#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    MyLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([_delegate respondsToSelector:@selector(myLinkSeletedClickContent:)]) {
        [_delegate myLinkSeletedClickContent:lookForModel];
    }
}
- (void)linkMoretag:(NSInteger)tag{
    if ([_delegate respondsToSelector:@selector(myLinkLookForMyMoreContent:User_id:role_type_ed:)]) {
        [_delegate myLinkLookForMyMoreContent:indexPathRow User_id:lookForModel.at_user_id role_type_ed:[[newsDict objectForKey:@"role_type"] integerValue]];
    }
    
    
}
@end
