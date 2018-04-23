//
//  TCRecipeModel.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCRecipeModel : NSObject

@property (nonatomic,strong)NSNumber  *amount;
@property (nonatomic, copy )NSString  *img;
@property (nonatomic, copy )NSString  *name;
@property (nonatomic, copy )NSString  *dining_type;

@end
