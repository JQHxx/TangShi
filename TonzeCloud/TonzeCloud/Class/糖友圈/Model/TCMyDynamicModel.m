//
//  TCMyDynamicModel.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyDynamicModel.h"
#import "MYCoreTextLabel.h"
#import "YHWorkGroupPhotoContainer.h"

@implementation TCMyDynamicModel

- (NSString *)identifier{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}
- (CGFloat)cellHight{
    if (!_cellHight) {
        //话题高度
        NSInteger topicHeight = 0;
        if (!kIsEmptyString(self.topic)&&![self.topic isEqualToString:@"0"]&&![self.topic isEqualToString:@"(null)"]) {
            topicHeight = 25;
        }else{
            topicHeight = 0;
        }
        //计算文字高度
        NSMutableArray *customArr = [[NSMutableArray alloc] init];
        if (kIsArray(self.at_user_id)) {
            for (NSDictionary *dict in self.at_user_id) {
                [customArr addObject:[dict objectForKey:@"nick_name"]];
            }
        }
        MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(65, 70, kScreenWidth-75-20, 0)];
        contentLabel.lineSpacing = 1.5;
        contentLabel.wordSpacing = 0.5;
        //设置普通文本的属性
        [contentLabel setText:self.news customLinks:customArr keywords:@[@""]];
        contentLabel.textFont = [UIFont systemFontOfSize:16.f];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
        CGFloat contentHeight =[contentLabel sizeThatFits:CGSizeMake(kScreenWidth-26, [UIScreen mainScreen].bounds.size.height)].height;
        contentHeight = contentHeight > 125 ? 126  : contentHeight;
        //查看全文
        NSInteger allHeight = contentHeight > 125 ? 25 : 0;
        
        //计算图片高度
        NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in self.image) {
            [picUrlArr addObject:[NSURL URLWithString:[dict objectForKey:@"image_url_resize"]]];
        }
        YHWorkGroupPhotoContainer *picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kScreenWidth-36];
        float photoheight = [picContainerView setupPicUrlArray:picUrlArr];
        photoheight = photoheight > 0 ? photoheight + 10:0;
        //是否自己
        NSInteger isself = self.is_self==0?0:25;
        //时间
        NSInteger timeHeight = 30;
        _cellHight =  contentHeight + photoheight + topicHeight + allHeight + isself + timeHeight + 114.5;
    }
    return _cellHight;
}

@end
