//
//  BlueToothManager.m
//  TonzeCloud
//
//  Created by vision on 17/5/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BlueToothManager.h"
#import "NSData+Extension.h"
#import "NSDate+Extension.h"
#import "SVProgressHUD.h"

#define kSugarDeviceName        @"TJY-BGM503"    //血糖仪设备名称
#define kDeviceIdentifier       @"F1E38209-BD6B-4C57-B042-E510C931988B"
#define kDeviceIdentifier2      @"B7F46E35-598A-A7BD-320E-6DFF7793AF54"
//FBA97B12-1716-487A-B607-41141AFC5B0C

@interface BlueToothManager (){
    CBCentralManager      *manager;
    NSString              *tempDataString;
    BOOL                  isGetData;
    BloodDeiveWriteType   writeType;
    NSString              *tempString;
    NSTimer               *measureTimer;  //测量计时器
    NSTimer               *batchTimer;    //批量导入计时器
}

@property (strong,nonatomic) NSMutableArray      *peripherals;   //连接的外围设备
@property (nonatomic, strong) CBCharacteristic   *writeCharacteristic;
@property (nonatomic,strong)NSMutableDictionary  *macAddressDict;


@end

@implementation BlueToothManager


#pragma mark -- Private Methods
#pragma mark 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        manager.delegate = self;
        tempDataString=@"";
        tempString    =@"";
        self.macAddressDict=[[NSMutableDictionary alloc] init];
        isGetData=NO;
        writeType=BloodDeiveWriteTypeGetData;
    }
    return self;
}


#pragma mark －－ Public Methods
#pragma mark 开始扫描
-(void)scan{
    [manager scanForPeripheralsWithServices:nil options:nil];
    [_delegate blueToothManagerRefreshManagerState:BTManagerStateScanning];
    MyLog(@"开始扫描");
}

#pragma mark 断开连接
-(void)disconnect{
    if (self.peripheral) {
        [manager cancelPeripheralConnection:self.peripheral];
    }
}

#pragma mark 写入数据
-(void)writeToPeripheralWithDataStr:(NSString *)dataStr WriteType:(BloodDeiveWriteType)type{
    if(_writeCharacteristic == nil){
        MyLog(@"writeCharacteristic 为空");
        return;
    }
    writeType=type;
    tempDataString=@"";
    tempString=@"";
    NSData *value = [NSData dataWithHexString:dataStr];
    [_peripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
    MyLog(@"已经向外设%@写入数据%@",_peripheral.name,dataStr);
}

#pragma mark 血糖仪设备操作
#pragma mark 校对时间
-(void)bloodDeviceSyncDateTime{
    //唤醒MCU
    NSString *config = @"FE 81 00 00 00 01";
    [self writeToPeripheralWithDataStr:config WriteType:BloodDeiveWriteTypeSyncTime];
    
    //同步日期
    double delayInSeconds = 1.5;
    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSDate *now = [NSDate date];
        NSString *dateConfig = [NSString stringWithFormat:@"CA %02X %02X %02X %02X",([[NSDate getYearFromDate:now] intValue] % 100+0x80)&0xff , [[NSDate getMonthFromDate:now] intValue] , [[NSDate getDayFromDate:now] intValue],(0x80+[[NSDate getYearFromDate:now] intValue] % 100 + [[NSDate getMonthFromDate:now] intValue] + [[NSDate getDayFromDate:now] intValue])&0xff];
        MyLog(@"dateConfig:%@",dateConfig);
        [weakSelf writeToPeripheralWithDataStr:dateConfig WriteType:BloodDeiveWriteTypeSyncTime];
    });
    
    //同步时间
    double delayInSeconds2 = 3.0;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        NSDate *now = [NSDate date];
        NSString *timeConfig = [NSString stringWithFormat:@"CA %02X %02X %02X %02X",[[NSDate getHourFromDate:now] intValue], [[NSDate getMinuteFromDate:now] intValue] , [[NSDate getSecondFromDate:now] intValue],([[NSDate getHourFromDate:now] intValue]+[[NSDate getMinuteFromDate:now] intValue] + [[NSDate getSecondFromDate:now] intValue])&0xff];
        MyLog(@"timeConfig:%@",timeConfig);
        [weakSelf writeToPeripheralWithDataStr:timeConfig WriteType:BloodDeiveWriteTypeSyncTime];
    });
}

#pragma mark - CBCentralManager Delegate
#pragma mark 开始查看服务，蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStatePoweredOff:{
            [_delegate blueToothManagerRefreshManagerState:BTManagerStateDisable];
        }
            break;
        case CBCentralManagerStatePoweredOn:{
            [_delegate blueToothManagerRefreshManagerState:BTManagerStateEnable];
        }
            break;
        case CBCentralManagerStateUnknown:
            break;
        default:
            break;
    }
    
    MyLog(@"手机状态:%ld", (long)[central state]);
    if (central.state==CBManagerStatePoweredOn) {
        [self scan];
    }
}

#pragma mark 查到外设后，停止扫描，连接设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    MyLog(@"%@",[NSString stringWithFormat:@"发现外设:%@ rssi:%@, UUID:%@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier.UUIDString, advertisementData]);
    [_peripherals addObject:peripheral];
    
    if ([peripheral.name isEqualToString:kSugarDeviceName]) {
        [manager stopScan];
        [manager connectPeripheral:peripheral options:nil];
        MyLog(@"连接外设:%@",peripheral.description);
        self.peripheral = peripheral;
        
        [self getDeviceMacAddressWithPeripheral:peripheral success:^(CBPeripheral *peripheral, NSString *macAddress) {
            MyLog(@"获取到设备(%@)mac地址:%@",kSugarDeviceName,macAddress);
            if (!kIsEmptyString(macAddress)) {
                [_delegate blueToothManagerGetMacAddress:macAddress];
            }
        }];
        
        [_delegate blueToothManagerRefreshManagerState:BTManagerStateConnecting];
    }
}

#pragma mark 连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    MyLog(@"已经连接到:%@", peripheral.description);
    peripheral.delegate = self;
    [central stopScan];
    [peripheral discoverServices:nil];
    
    //(获取BLE的mac)2.扫描服务UUID:180A
    if ([self.macAddressDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
        MyLog(@"(获取BLE的mac)2.扫描服务UUID:180A");
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"180A"]]];
    }
    
    [_delegate blueToothManagerRefreshManagerState:BTManagerStateConnected];
}

#pragma mark 连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    MyLog(@"连接外设%@失败",peripheral);
    [_delegate blueToothManagerRefreshManagerState:BTManagerStateConnectFailed];
}

#pragma mark  断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    MyLog(@"与%@断开连接",peripheral);
    [_delegate blueToothManagerRefreshManagerState:BTManagerStateDisconnected];
}

#pragma mark -- CBPeripheral Delegate
#pragma mark 已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        MyLog(@"搜索服务%@时发生错误:%@", peripheral.name, [error localizedDescription]);
        return;
    }

    int i=0;
    for (CBService *service in peripheral.services) {
        MyLog(@"%@",[NSString stringWithFormat:@"%d :服务 UUID: %@(%@)",i,service.UUID.data,service.UUID.UUIDString]);
        i++;
        if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {  //血糖仪自定义服务
            [peripheral discoverCharacteristics:nil forService:service];
        }else if ([service.UUID.UUIDString isEqualToString:@"180A"]){
            //发送查询服务特征为2A23的特征
            MyLog(@"(获取BLE的mac)3.发送查询服务特征为2A23的特征");
            CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
            [peripheral discoverCharacteristics:@[macCharcteristicUUID] forService:service];
        }
    }
}

#pragma mark 已搜索到Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        MyLog(@"搜索特征%@时发生错误:%@", service.UUID, [error localizedDescription]);
        return;
    }
    if ([peripheral.name isEqualToString:kSugarDeviceName]) {
        if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {    //血糖仪自定义服务接口
            for (CBCharacteristic *character in service.characteristics) {
                MyLog(@"特征 UUID: %@ (%@)",character.UUID.data,character.UUID);
                if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
                    _writeCharacteristic = character;
                    
                    [peripheral setNotifyValue:YES forCharacteristic:character]; //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
                    /***校验时间***/
                    [self bloodDeviceSyncDateTime];
                }else if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
                    MyLog(@"激活接口FFF2的通知功能");
                    [peripheral readValueForCharacteristic:character];
                    [peripheral setNotifyValue:YES forCharacteristic:character]; //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
                }
            }
        }else if ([service.UUID.UUIDString isEqualToString:@"180A"]){
            MyLog(@"(获取BLE的mac)4.根据服务特征值2A23找到对应的服务特征，读取服务特征的value");
            CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
            for(CBCharacteristic *characteristic in service.characteristics){
                MyLog(@"180A特征 UUID: %@ (%@)",characteristic.UUID.data,characteristic.UUID);
                if([characteristic.UUID isEqual:macCharcteristicUUID]){
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error){
        MyLog(@"更新特征值%@时发生错误:%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    // 收到数据
    NSString *dataString = [characteristic.value hexString];
    MyLog(@"BLE “%@” data recv(%@): %@", peripheral.name, characteristic.UUID.UUIDString, dataString);
    NSString *charUUID = characteristic.UUID.UUIDString;
    if ([peripheral.name isEqualToString:kSugarDeviceName]) {
        if ([charUUID isEqualToString:@"FFF2"]) {  //接口2
            tempDataString=[tempDataString stringByAppendingString:dataString];
            if ([tempDataString containsString:@"82 00 00 00 02"]) {
                if ([_delegate respondsToSelector:@selector(blueToothManagerInsertPaparAction)]) {
                    [_delegate blueToothManagerInsertPaparAction];
                }
                [_delegate blueToothManagerRefreshManagerState:BTManagerStateInsertTestPaper];
                MyLog(@"插入试纸成功");
                tempDataString=@"";
                writeType=BloodDeiveWriteTypeGetData;
            }else{
                if (writeType==BloodDeiveWriteTypeGetData) {
                    tempString=dataString;
                    if (!measureTimer) {
                        measureTimer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getDeviceMeasureData) userInfo:nil repeats:YES];
                    }
                }else if (writeType==BloodDeiveWriteTypeSyncTime){
                    tempDataString=@"";
                    writeType=BloodDeiveWriteTypeGetData;
                }else if (writeType==BloodDeiveWriteTypeBatchImport){
                    tempString=dataString;
                    if (!batchTimer) {
                        batchTimer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getDeviceBatchData) userInfo:nil repeats:YES];
                    }
                }
            }
        }
    }
    
    
    //(获取BLE的mac)5.获取到mac地址的数据，转化，回调
    if ([_macAddressDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
        if ([charUUID isEqualToString:@"2A23"]) {
            MyLog(@"(获取BLE的mac)5.获取到mac地址的数据，转化，回调");
            NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];//如：7c40660000489120
            NSMutableString *macString = [[NSMutableString alloc] init];
            [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
            MyLog(@"获取到设备的macString:%@",macString);//如：C6:05:04:03:5C:52
            //回调
            getMacAddressSuccessCallBack callback = _macAddressDict[peripheral.identifier.UUIDString];
            if (callback) {
                callback(peripheral,macString);
            }
            //销毁
            [_macAddressDict removeObjectForKey:peripheral.identifier.UUIDString];
        }
    }
    
}

#pragma mark 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        MyLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else { // Notification has stopped
        MyLog(@"Notification stopped on %@.  Disconnecting", characteristic);
    }
}

#pragma mark  用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        MyLog(@"发送数据失败=======%@",error.userInfo);
    }else{
        MyLog(@"发送数据成功");
    }
    
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark 获取测量数据
-(void)getDeviceMeasureData{
    if (kIsEmptyString(tempString)) {
        if (measureTimer) {
            [measureTimer invalidate];
            measureTimer=nil;
        }
        
        //拼接接收的指令
        if ([tempDataString containsString:@"FF"]&&[tempDataString containsString:@"FE"]) {
            NSRange startRange = [tempDataString rangeOfString:@"FF"];
            NSRange endRange = [tempDataString rangeOfString:@"FE"];
            if (endRange.location>startRange.location+startRange.length) {
                NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
                NSString *result = [tempDataString substringWithRange:range];  //拼接后的字符串
                if ([_delegate respondsToSelector:@selector(blueToothManagerDidGetDataForString:)]) {
                    [_delegate blueToothManagerDidGetDataForString:result];
                }
                tempDataString=@"";
                MyLog(@"读取数据成功");
                [_delegate blueToothManagerRefreshManagerState:BTManagerStateMeasured];
            }
        }
    }else{
        tempString=@"";
    }
}


#pragma mark 获取批量数据
-(void)getDeviceBatchData{
    if (kIsEmptyString(tempString)) {
        MyLog(@"length:%ld",(long)tempDataString.length);
        if (batchTimer) {
            [batchTimer invalidate];
            batchTimer=nil;
        }
        [_delegate blueToothManagerRefreshManagerState:BTManagerStateMeasured];
        if ([_delegate respondsToSelector:@selector(blueToothManagerDidGetBatchImportDataForString:)]) {
            [_delegate blueToothManagerDidGetBatchImportDataForString:tempDataString];
        }
    }else{
        tempString=@"";
    }
}

#pragma mark 获取mac地址
-(void)getDeviceMacAddressWithPeripheral:(CBPeripheral *)mPeripheral success:(getMacAddressSuccessCallBack)callback{
    //(获取BLE的mac)1.连接传入的Peripheral
    MyLog(@"(获取BLE的mac)1.连接传入的Peripheral");
    
    self.macAddressDict[mPeripheral.identifier.UUIDString]=callback;
}

@end
