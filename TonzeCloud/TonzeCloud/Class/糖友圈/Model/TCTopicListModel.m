
//
//  TCTopicListModel.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTopicListModel.h"

@implementation TCTopicListModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [self init]) {
        self.title = [dictionary objectForKey:@"title"];
        self.desc = [dictionary objectForKey:@"desc"];
        self.topic_id = [[dictionary objectForKey:@"topic_id"] integerValue];
        self.default_image = [dictionary objectForKey:@"default_image"];
        self.read_num = [[dictionary objectForKey:@"read_num"] integerValue];
        self.comment_num = [[dictionary objectForKey:@"comment_num"] integerValue];
        self.is_limit = [[dictionary objectForKey:@"is_limit"] integerValue];
    }
    return self;
}


@end

