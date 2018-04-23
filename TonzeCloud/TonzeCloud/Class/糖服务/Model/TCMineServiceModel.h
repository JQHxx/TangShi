//
//  TCMineServiceModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "expert_id": 15,
 "expert_name": "专家1",
 "scheme_name": "低血糖",
 "head_portrait": "uploads/big/20170314\\68ce6c2820d5d8bd9d397cdc343fe59b.png",
 "positional_titles": "一级",
 "service_status": 1,
 "start_time": 1488973295,
 "end_time": 1489543811
 */
#import <Foundation/Foundation.h>

@interface TCMineServiceModel : NSObject

@property (nonatomic,assign)NSInteger   order_id;              //服务id
@property (nonatomic, copy )NSString    *scheme_name;          //服务名称
@property (nonatomic,assign)NSInteger   type;                  //服务类型 1.图文 2.医疗方案
@property (nonatomic, copy )NSString    *cover;                //方案封面图
@property (nonatomic, copy )NSString    *positional_titles;    //级别
@property (nonatomic, copy )NSString    *start_time;           //开始时间
@property (nonatomic, copy )NSString    *end_time;             //结束时间
@property (nonatomic,assign)NSInteger   service_status;        //服务状态 1 服务中 2 已完成 3 已退款
@property (nonatomic,assign)NSInteger   expert_type;           //专家分类
@property (nonatomic, copy )NSString    *order_sn;             //服务订单号
@property (nonatomic,assign)NSInteger   order_status;          //订单状态 1.已创建 2.已付款
@property (nonatomic, copy )NSString    *pay_money;            //支付金额

@property (nonatomic, copy )NSString    *im_groupid;                //群聊ID

/********专家信息********/
@property (nonatomic,assign)NSInteger   expert_id;              //专家ID
@property (nonatomic, copy) NSString    *im_expertname;         //专家IM用户名
@property (nonatomic, copy )NSString    *head_portrait;         //专家头像
@property (nonatomic, copy )NSString    *expert_name;           //专家姓名
@property (nonatomic, copy )NSString    *im_expertpositional;   //专家姓名

/*******用户信息******/
@property (nonatomic, copy) NSString    *im_username;            //用户IM用户名
@property (nonatomic,assign)NSInteger   user_id;                 //用户编号
@property (nonatomic, copy )NSString    *user_name;              //用户名
@property (nonatomic, copy )NSString    *user_photo;             //用户头像

/*******糖士助理******/
@property (nonatomic,assign)NSInteger   helper_id;               //助理ID
@property (nonatomic, copy )NSString    *im_helpername;          //助理IM用户名
@property (nonatomic, copy )NSString    *im_helperhead;          //助理头像
@property (nonatomic, copy )NSString    *im_helperusername;      //助理昵称
@property (nonatomic, copy )NSString    *im_helperpositional;      //助理昵称


/*******评论*******/
@property (nonatomic, copy) NSString    *is_commented;            //是否已评价  1为已评价，0反之
@property (nonatomic, copy) NSString    *comment_score;           //评价星级（1~5）
@property (nonatomic,assign)NSInteger   attitude_score;           //服务态度的星级
@property (nonatomic,assign)NSInteger   speed_score;              //回复速度的星级
@property (nonatomic,assign)NSInteger   satisfied_score;          //解决问题的星级
@property (nonatomic, copy )NSString    *msg;                     //评价内容
@property (nonatomic, copy )NSString    *comment_time;            //评价时间

/*****最新一条消息*******/
@property (nonatomic, copy)NSString   *lastMsgHeadPic;    //头像
@property (nonatomic, copy)NSString   *lastMsgUserName;    //昵称
@property (nonatomic, copy)NSString   *lastMsgLabel;       //职称
@property (nonatomic, copy)NSString   *lastMsg;
@property (nonatomic, copy)NSString   *lastMsgTime;
@property (nonatomic,assign)NSInteger unreadCount;

@end
