//
//  TCAddDeviceModel.h
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCAddDeviceModel : NSObject

@property (nonatomic, copy )NSString *deviceName;
@property (nonatomic, copy )NSString *desc;
@property (nonatomic, copy )NSString *image;
@property (nonatomic, copy )NSString *productID;
@property (nonatomic, copy )NSString *wifiImage;
@property (nonatomic, copy )NSString *macAddress;

@end
