//
//  TCMyCommentsModel.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyCommentsModel.h"

@implementation TCMyCommentsModel

- (NSString *)identifier{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}
@end
