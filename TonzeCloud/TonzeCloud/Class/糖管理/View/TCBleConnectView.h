//
//  TCBleConnectView.h
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothManager.h"

typedef enum : NSUInteger {
    ConnectTypeDisable,      //蓝牙未开启
    ConnectTypeEnable,       //蓝牙已开启
    ConnectTypeScanning,     //扫描中
    ConnectTypeScanSuccess,  //扫描成功
    ConnectTypeConnecting,   //连接中
    ConnectTypeConnected,    //连接成功
    ConnectTypeInsertTestPaper,    //插入试纸
    ConnectTypeMeasuring,    //测量中
    ConnectTypeMeasureSucess,//测量完成
} ConnectType;

@interface TCBleConnectView : UIView


@property (nonatomic,assign)ConnectType connectType;

@end
