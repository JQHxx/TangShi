//
//  TCEvaluateModel.h
//  TonzeCloud
//
//  Created by vision on 17/6/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCEvaluateModel : NSObject

@property (nonatomic ,assign)NSInteger user_id;
@property (nonatomic , copy )NSString *comment_score;
@property (nonatomic , copy )NSString *photo;
@property (nonatomic , copy )NSString *msg;
@property (nonatomic , copy )NSString *add_time;
@property (nonatomic , copy )NSString *nick_name;

@end
