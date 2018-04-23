//
//  ChatViewController.h
//  TangShiService
//
//  Created by vision on 17/5/24.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "EaseMessageViewController.h"
#import "TCMineServiceModel.h"

@protocol ChatViewControllerDelegate <NSObject>

-(void)chatVCDidClickWithUrl:(NSURL *)url;
//点击头像跳转
-(void)chatVCDidSelectUserAtavarWithName:(NSString *)nickName;
//购买服务
-(void)chatVCDidBuyServiceAction;
//点击消息cell
-(void)chatVCDidSelectCellWithExt:(NSDictionary *)ext;

@end

@interface ChatViewController : EaseMessageViewController

@property (nonatomic,weak)id<ChatViewControllerDelegate>chatdelegate;

@end
