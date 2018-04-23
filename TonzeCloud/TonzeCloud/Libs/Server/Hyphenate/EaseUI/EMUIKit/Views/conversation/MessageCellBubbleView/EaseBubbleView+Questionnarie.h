//
//  EaseBubbleView+Questionnarie.h
//  TangShiService
//
//  Created by vision on 17/12/13.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (Questionnarie)

/*!
 @method
 @brief 构建检查单类型消息气泡视图
 */
- (void)setupQuestionnarieBubbleView;

/*!
 @method
 @brief 变更检查单类型消息气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateQuestionnarieMargin:(UIEdgeInsets)margin;


- (void)_setupQuestionnarieBubbleMarginConstraints;

@end
