//
//  TCMyFeedbackModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

/*
 "id": 3,
 "user_id": "5",
 "feedback_time": "1491718818",
 "feedback_content": "摸摸摸摸摸摸哦弄嘻嘻嘻嘻嘻嘻嘻惜命命民工明明哦0你一嘻嘻嘻嘻嘻嘻嘻1亿嘻嘻嘻嘻嘻嘻嘻嘻嘻嘻嘻嘻嘻嘻我自己在家嘻嘻异界之九阳真经嘻嘻你明明您明敏morning匿名摸摸哦哦哦哦哦哦哦现在一直关机考虑考虑要一直一直嘻嘻主题4株呼呼呼呼骨头8股呼噜噜葫芦糊涂旅途聚聚啦啦啦啦啦啦啦8句噜噜噜噜噜噜噜噜噜噜噜噜噜噜噜噜噜噜可以提修图旅途图库兔兔兔兔兔兔图4组突突突提醒我嘻嘻嘻嘻一些事一些情嘻嘻嘻嘻嘻指挥官我现",
 "is_read": 1,
 "is_reply": 1
 */
#import <Foundation/Foundation.h>

@interface TCMyFeedbackModel : NSObject

@property (nonatomic ,assign)NSInteger id;                //反馈id
@property (nonatomic ,assign)NSInteger user_id;           //用户id
@property (nonatomic ,strong)NSString *feedback_time;     //反馈时间
@property (nonatomic ,strong)NSString *feedback_content;  //反馈内容
@property (nonatomic ,assign)NSInteger is_read;           //是否已读，1为已读，0为未读
@property (nonatomic ,assign)NSInteger is_reply;          //是否已回复，1为已回复，0为未回复

@end
