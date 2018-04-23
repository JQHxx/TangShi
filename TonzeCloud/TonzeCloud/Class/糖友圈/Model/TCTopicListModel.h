//
//  TCTopicListModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTopicListModel : NSObject

/// 标题
@property (nonatomic, copy) NSString *title;
/// 摘要
@property (nonatomic, copy) NSString *desc;
/// 讨论
@property (nonatomic, assign) NSInteger  comment_num;
/// 阅读
@property (nonatomic, assign) NSInteger  read_num;
/// 图片
@property (nonatomic, copy) NSString     *default_image;
/// 是否可发布动态
@property (nonatomic, assign) NSInteger  is_limit;
/// id
@property (nonatomic, assign) NSInteger  topic_id;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

/*
"title": "话题2",
"desc": "hh",
"comment_num": 0,
"read_num": 0,
"default_image": ""
*/
