//
//  TCDropmenuView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDropmenuView : UIView
@property (nonatomic, assign) CGFloat offsetXOfArrow;
@property (nonatomic, assign) BOOL wannaToClickTempToDissmiss;


- (instancetype)initWithFrame:(CGRect)frame;

- (void)addItems:(NSArray <NSString *> *)itesName;
- (void)addItems:(NSArray <NSString *> *)itemsName exceptItem:(NSString *)itemName;
- (void)selectedAtIndexHandle:(void(^)(NSUInteger index, NSString *itemName))indexHandle;

- (void)show;
- (void)dismiss;

@end


/* --- 示例
        
 _dropmenuView = [[TCDropmenuView alloc]initWithFrame:CGRectMake(kScreenWidth - 100, CGRectGetMaxY(_topicSelectionBtn.frame), 90, 0)];
 _dropmenuView.offsetXOfArrow = 20;
 [_dropmenuView addItems:@[@"按热度",@"按时间"]];
 [_dropmenuView selectedAtIndexHandle:^(NSUInteger index, NSString *itemName) {
 [_topicSelectionBtn setTitle:itemName forState:UIControlStateNormal];
 }];
 
 最后在点击事件 显示
 [_dropmenuView show];
 

*/
