//
//  TCResponseView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyCommentsModel.h"
#import "TCDynamicCommentsModel.h"
#import "TCMyPraiseModel.h"

@protocol TCRespondViewDelegate <NSObject>
@required
- (void)respondView;      //个人信息

@end
@interface TCResponseView : UIView

@property (nonatomic,weak) id <TCRespondViewDelegate> delegate;

@property (nonatomic,assign)NSDictionary *dict;


- (void)responseViewModel:(TCMyCommentsModel *)model type:(NSInteger)type;

- (void)dynamicCommentsViewModel:(TCDynamicCommentsModel *)model;

- (void)myPraiseModel:(TCMyPraiseModel *)model;

- (void)myMaxReplyDict:(NSDictionary *)dict;
@end
