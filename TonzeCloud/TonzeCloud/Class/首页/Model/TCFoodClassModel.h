//
//  TCFoodClassModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 
 {
 "add_time" = 1487899463;
 "edit_time" = 1487899463;
 id = 304;
 "image_id" = 008919a6c92e643011a666fe0f4b51bb;
 "image_url" = "/uploads/big/20170224/7fffadbcf9fa16ef1eabf8e42f1768a4.jpg";
 name = "\U98df\U6750\U5206\U7c7b13";
 }
 
 */


#import <Foundation/Foundation.h>

@interface TCFoodClassModel : NSObject

@property (nonatomic, copy )NSString  *add_time;
@property (nonatomic, copy )NSString  *edit_time;
@property (nonatomic,strong)NSNumber  *id;
@property (nonatomic, copy )NSString  *image_id;
@property (nonatomic, copy )NSString  *image_url;
@property (nonatomic, copy )NSString  *name;

@end
