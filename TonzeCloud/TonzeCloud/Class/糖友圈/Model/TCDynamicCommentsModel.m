//
//  TCDynamicCommentsModel.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDynamicCommentsModel.h"

@implementation TCDynamicCommentsModel
- (NSString *)identifier{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}

@end

@implementation TCCommentReplyModel



@end
