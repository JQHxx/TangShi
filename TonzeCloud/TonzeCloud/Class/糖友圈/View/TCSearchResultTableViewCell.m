//
//  TCSearchResultTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSearchResultTableViewCell.h"
#import "TCFriendSearchModel.h"
#import "TCToolButton.h"

@interface TCSearchResultTableViewCell (){
    NSArray *friendArray;
}
@end
@implementation TCSearchResultTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
    }
    return self;
}
- (void)cellFriendSearchResult:(NSArray *)friendArr{
    friendArray = friendArr;
    for (UIView *view in self.subviews) {   //删除子视图
        if ([view isKindOfClass:[TCToolButton class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i=0; i<friendArr.count; i++) {
        TCFriendSearchModel *model = friendArr[i];
        TCToolButton *friendButton = [[TCToolButton alloc] initWithFrame:CGRectMake(i*kScreenWidth/4, 0, kScreenWidth/4, 110)];
        friendButton.tag = 100+i;
        [friendButton addTarget:self action:@selector(friendSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:friendButton];
        if (friendArr.count>4) {
            if (i==3) {
                friendButton.headImage.image = [UIImage imageNamed:@"ic_m_head_156"];
            } else {
                [friendButton.headImage sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
            }
            friendButton.titleLab.text = i==3?@"更多":model.nick_name;
            friendButton.bgView.hidden = i==3?NO:YES;
        } else {
            [friendButton.headImage sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
            friendButton.titleLab.text = model.nick_name;
            friendButton.bgView.hidden = YES;
        }
    }
}

- (void)friendSearch:(UIButton *)button{
    if (button.tag==103) {
        if (friendArray.count>4) {
            if ([_resultDelegate respondsToSelector:@selector(seletedMoreFriend)]) {
                [_resultDelegate seletedMoreFriend];
            }
        } else {
            if ([_resultDelegate respondsToSelector:@selector(seletedFriendModel:)]) {
                [_resultDelegate seletedFriendModel:friendArray[button.tag-100]];
            }
        }
    }else{
        if ([_resultDelegate respondsToSelector:@selector(seletedFriendModel:)]) {
            [_resultDelegate seletedFriendModel:friendArray[button.tag-100]];
        }
    }
}
@end
