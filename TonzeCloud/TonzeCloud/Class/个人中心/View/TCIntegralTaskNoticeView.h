//
//  TCIntegralTaskView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class   TCIntegralTaskNoticeView;

@protocol NoticeViewDelegate <NSObject>

/*
 *  任务滚动点击
 */
- (void)gyChangeTextView:(TCIntegralTaskNoticeView *)textView didTapedAtIndex:(NSInteger)index;
/*
 * 任务列表点击
 */
- (void)taskListTapClcik;

@end

@interface TCIntegralTaskNoticeView : UIView
/**
 *  文字数组
 */
@property (nonatomic,strong) NSArray *titleArray;
/**
 *  总任务数组
 */
@property (nonatomic ,strong) NSArray *taskListArray;
/**
 *  拼接后的文字数组
 */
@property (nonatomic,strong) NSMutableArray *titleNewArray;
/**
 *  是否可以拖拽
 */
@property (nonatomic,assign) BOOL isCanScroll;
/**
 *  字体颜色
 */
@property (nonatomic,strong) UIColor *titleColor;
/**
 *  背景颜色
 */
@property (nonatomic,strong) UIColor *BGColor;
/**
 *  字体大小
 */
@property (nonatomic,assign) CGFloat titleFont;
/**
 定时器的循环时间
 */
@property (nonatomic , assign) NSInteger interval;
/// 已完成任务总数
@property (nonatomic, assign) NSInteger  carryOutNum;

@property (nonatomic , weak) id<NoticeViewDelegate> delegate;

/**
 *  添加定时器
 */
- (void)addTimer;


@end
