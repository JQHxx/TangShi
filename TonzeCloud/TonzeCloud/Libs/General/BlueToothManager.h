//
//  BlueToothManager.h
//  TonzeCloud
//
//  Created by vision on 17/5/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum : NSUInteger {
    BTManagerStateDisable,       //蓝牙不可用
    BTManagerStateEnable,        //蓝牙可用
    BTManagerStateScanning,      //扫描中
    BTManagerStateConnecting,    //连接中
    BTManagerStateConnected,     //连接成功
    BTManagerStateCancelConnect, //取消连接
    BTManagerStateConnectFailed, //连接失败
    BTManagerStateDisconnected,   //断开连接
    BTManagerStateInsertTestPaper,   //断开连接
    BTManagerStateMeasured,       //测量完成
} BTManagerState;   //蓝牙设备状态

typedef enum : NSUInteger {
    BloodDeiveWriteTypeGetData,      //获取血糖数据
    BloodDeiveWriteTypeSyncTime,     //同步时间
    BloodDeiveWriteTypeBatchImport,  //批量导入数据
} BloodDeiveWriteType;



@protocol BlueToothManagerDelegate <NSObject>

- (void)blueToothManagerRefreshManagerState:(BTManagerState)state;       //刷新状态
- (void)blueToothManagerGetMacAddress:(NSString *)macStr;                //获取设备mac地址
- (void)blueToothManagerInsertPaparAction;
- (void)blueToothManagerDidGetDataForString:(NSString *)dataString;              //获取测量数据
- (void)blueToothManagerDidGetBatchImportDataForString:(NSString *)dataString;   //获取批量导入数据

@end



///获取mac地址回调
typedef void(^getMacAddressSuccessCallBack)(CBPeripheral * peripheral, NSString * macAddress);

@interface BlueToothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (retain, nonatomic) id<BlueToothManagerDelegate> delegate;
@property (nonatomic, strong) CBPeripheral *peripheral;

- (void)writeToPeripheralWithDataStr:(NSString *)dataStr WriteType:(BloodDeiveWriteType)type;
- (void)scan;
- (void)disconnect;

-(void)getDeviceMacAddressWithPeripheral:(CBPeripheral *)mPeripheral success:(getMacAddressSuccessCallBack)callback;

@end
