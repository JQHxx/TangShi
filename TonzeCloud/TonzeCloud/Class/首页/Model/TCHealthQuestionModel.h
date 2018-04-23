//
//  TCHealthQuestionModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
@class titleContentModel;
@interface TCHealthQuestionModel : NSObject

@property(nonatomic ,strong)NSString *name;

@property(nonatomic ,assign)NSInteger assess_id;

@property (nonatomic, strong) NSArray<titleContentModel *> *answer;

@end
@interface titleContentModel : NSObject

@property(nonatomic ,strong)NSString *name;

@property(nonatomic ,assign)NSInteger score;

@end

