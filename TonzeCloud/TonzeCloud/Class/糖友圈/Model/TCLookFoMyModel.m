//
//  TCLookFoMyModel.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLookFoMyModel.h"

@implementation TCLookFoMyModel
- (NSString *)identifier{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}

@end
