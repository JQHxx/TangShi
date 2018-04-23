//
//  TCSugarModel.h
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSugarModel : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *measurement_time;   //测量时间

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, copy) NSString *way;           //添加方式 ，设备或手动

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *image_id;

@property (nonatomic, copy) NSString *deviceid;     //设备ID

@property (nonatomic, copy) NSString *time_slot;    //时间段

@property (nonatomic, copy) NSString *glucose;      //血糖值

@property (nonatomic, copy) NSString *remarks;      //备注

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *code;

@end
