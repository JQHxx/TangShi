//
//  TCCommentToolBar.h
//  TonzeCloud
//
//  Created by vision on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseTextView.h"
#import "EaseFaceView.h"

@protocol TCCommentToolBarDelegate <NSObject>

@optional

/*
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

- (void)didMoreSendText;

- (void)SendErrorText;

/*
 *  点击表情键盘不隐藏键盘文字数量提示文字
 */
- (void)didface;

@end


@interface TCCommentToolBar : UIView

@property (strong, nonatomic) EaseTextView *inputTextView;

@property (strong, nonatomic) UILabel *textLabel;

@property (strong, nonatomic) EaseFaceView *faceView;

@property (nonatomic,weak)id<TCCommentToolBarDelegate>delegate;
#pragma mark 隐藏键盘
-(void)willHiddenKeyboard;

@end
