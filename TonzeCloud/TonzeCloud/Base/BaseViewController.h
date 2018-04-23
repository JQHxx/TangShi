//
//  BaseViewController.h
//  Product
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef void(^TaskAleartViewClickBlock)(NSInteger clickIndex, BOOL isBack); // 积分完成回调

@interface BaseViewController : UIViewController

@property (nonatomic ,assign)BOOL      isHiddenBackBtn;     //隐藏返回按钮
@property (nonatomic ,assign)BOOL      isHiddenNavBar;     //隐藏导航栏
@property (nonatomic ,copy)NSString    *baseTitle;        //标题
@property (nonatomic ,copy)NSString    *leftImageName;
@property (nonatomic ,copy)NSString    *leftTitleName;
@property (nonatomic ,copy)NSString    *rightImageName;
@property (nonatomic ,copy)NSString    *rigthTitleName;

@property (nonatomic, assign) BOOL      rightBtnEnabled;    // 右按钮是否可点击

@property (nonatomic, copy) TaskAleartViewClickBlock  taskAleartViewClickBlock;

-(void)reloadForNetwork;

-(void)leftButtonAction;
-(void)rightButtonAction;

-(void)fastLoginAction;  // 快速登录

- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message;

// 获取任务积分 
- (void)getTaskPointsWithActionType:(NSInteger)actionType isTaskList:(BOOL)isTaskList taskAleartViewClickBlock:(TaskAleartViewClickBlock)taskAleartViewClickBlock;

@end
