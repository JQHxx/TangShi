//
//  TCMainDeviceHelper.h
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCAddDeviceModel.h"
#import "DeviceEntity.h"
#import "TCDeviceModel.h"

@interface TCMainDeviceHelper : NSObject

singleton_interface(TCMainDeviceHelper)


@property (nonatomic,strong)TCAddDeviceModel *mainDevice;
@property (nonatomic,assign)BOOL             isGotoWifiSet;
@property (nonatomic,strong)NSMutableArray   *deviceModelArr;
@property (nonatomic,strong)NSMutableArray   *deviceConnectArr;     //设备实体数组
@property (nonatomic,assign)BOOL             isConnectDeviceSuccess;  //设备连接成功
@property (nonatomic,assign)BOOL             isReloadDeviceList;    //刷新设备列表

@property (nonatomic,strong)NSMutableArray   *riceArray;   //米种

/*
 *获取正在操作的米种
 */
-(TCRiceModel *)getControlRiceWithRiceId:(NSInteger)riceId;

/*
 *解析设备列表
 */
-(NSMutableArray *)getDeviceListWithList:(NSArray *)list;

/*
 *获取设备实体列表
 */
-(void)getDeviceEntityListWithDeviceList:(NSArray *)list;


-(DeviceEntity *)getDeviceEntityWithDeviceMac:(NSString *)mac;
/*
 *获取设备状态
 */
-(NSMutableDictionary *)getStateDicWithDevice:(DeviceEntity *)device Data:(NSData *)data;

/*
 *发送设备指令
 */
-(void)sendCommandForDevice:(TCDeviceModel *)model;

/*
 *发送获取偏好设备指令
 */
-(void)sendGetPeferenceCommandForDevice:(TCDeviceModel *)model preferenceString:(NSString *)preferenceString;

/*
 *发送设置偏好设备指令
 */
-(void)sendSetPreferenceCommandForDevice:(TCDeviceModel *)model;

/*
 *调用计时器发送获取设备状态指令
 */
-(void)getStateForSendCommandWithDevice:(TCDeviceModel *)model;

/*
 *停止计时器(获取设备状态)
 */
-(void)cancelGetDeviceStateTimer;


/*
 *重置设备
 */
-(void)resetDevice:(TCDeviceModel *)model;

/*
 *停止重置设备
 */
-(void)dismissProgressView;

/*
 *连接设备
 */
-(void)connectDevice:(TCDeviceModel *)model;

/*
 *根据设备ID获取设备名称
 */
-(NSString *)getDeviceNameFormDeviceID:(NSInteger )deviceID;

/*
 *根据mac地址获取设备对象
 */
-(TCDeviceModel *)getDeviceModelWithMac:(NSString *)mac;

/*
 *云菜谱名称解析
 */
-(NSString *)getCloudMenuName:(NSData *)data;

@end
