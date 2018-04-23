//
//  TCFamilyBloodModel.h
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCFamilyBloodModel : NSObject

@property (nonatomic,assign)NSInteger     record_family_id;
@property (nonatomic, copy )NSString      *time_slot;
@property (nonatomic, copy )NSString      *glucose;
@property (nonatomic, copy )NSString      *measurement_time;
@property (nonatomic,assign)NSInteger     status;
@property (nonatomic,assign)NSInteger     family_id;
@property (nonatomic,strong)NSNumber      *is_read;
@property (nonatomic,strong)NSDictionary  *family_info;

@property (nonatomic,assign)BOOL   isRead;

@end


@interface TCFamilyUserModel : NSObject

@property (nonatomic, copy )NSString *mobile;
@property (nonatomic, copy )NSString *nick_name;
@property (nonatomic,assign)NSInteger sex;
@property (nonatomic, copy )NSString *call;
@property (nonatomic, copy )NSString *image_url;

@end
