//
//  TCDeviceModel.h
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCRiceModel.h"

@interface TCDeviceModel : NSObject

@property (nonatomic, copy )NSString  *image;
@property (nonatomic, copy )NSString  *deviceName;
@property (nonatomic,assign)BOOL      isConnected;
@property (nonatomic,strong)NSMutableDictionary  *stateDict;   //设备状态

@property (nonatomic, copy )NSString  *product_id;
@property (nonatomic, copy )NSString  *mac;
@property (nonatomic,assign)NSInteger role;
@property (nonatomic,assign)NSInteger device_id;
@property (nonatomic, copy )NSString  *access_key;

//降糖饭米种
@property (nonatomic,strong)TCRiceModel *rice;


@end
