//
//  TCFriendGroupNavView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NavBtnClickBlock)(NSInteger tag);

@interface TCFriendGroupNavView : UIView
/// 头像
@property (nonatomic ,strong) UIImageView *headImg;

@property (nonatomic, copy) NavBtnClickBlock navBtnClickBlock ;

@end
