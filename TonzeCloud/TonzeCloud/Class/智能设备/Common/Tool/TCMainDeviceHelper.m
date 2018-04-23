//
//  TCMainDeviceHelper.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMainDeviceHelper.h"
#import "TCDeviceModel.h"
#import "XLinkExportObject.h"
#import "NSData+Extension.h"
#import "SVProgressHUD.h"
#import "HttpRequest.h"

@interface TCMainDeviceHelper (){
    NSTimer    *myTimer;
    NSTimer    *overTimer;
}

@end

@implementation TCMainDeviceHelper

singleton_implementation(TCMainDeviceHelper)

#pragma mark 所有米种
-(NSMutableArray *)riceArray{
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    NSArray *arr=@[@{@"id":[NSNumber numberWithInteger:51], @"rice":@"丝苗米",@"percent":@"34",@"image":@"ic_mi_04"},@{@"id":[NSNumber numberWithInteger:1],@"rice":@"东北大米",@"percent":@"19",@"image":@"ic_mi_01"},@{@"id":[NSNumber numberWithInteger:52],@"rice":@"香米",@"percent":@"8",@"image":@"ic_mi_03"}];
    for (NSInteger i=0;i<arr.count;i++) {
        NSDictionary *dict=arr[i];
        TCRiceModel *rice=[[TCRiceModel alloc] init];
        rice.riceId=[dict[@"id"] integerValue];
        rice.riceName=dict[@"rice"];
        rice.riceImage=dict[@"image"];
        rice.lowSugarPercent=[NSString stringWithFormat:@"%ld",(long)([dict[@"percent"] integerValue])];
        [tempArr addObject:rice];
    }
    return tempArr;
}

#pragma mark 获取正在操作的米种
-(TCRiceModel *)getControlRiceWithRiceId:(NSInteger)riceId{
    for (TCRiceModel *rice in self.riceArray) {
        if (rice.riceId==riceId) {
            return rice;
        }
    }
    return nil;
}

-(void)setDeviceConnectArr:(NSMutableArray *)deviceConnectArr{
    _deviceConnectArr=deviceConnectArr;
}

-(void)setDeviceModelArr:(NSMutableArray *)deviceModelArr{
    _deviceModelArr=deviceModelArr;
}

#pragma mark 解析设备列表
-(NSMutableArray *)getDeviceListWithList:(NSArray *)list{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    for (NSDictionary *dic in list) {
        NSString *productID=dic[@"product_id"];
        TCDeviceModel *device=[[TCDeviceModel alloc] init];
        if ([productID isEqualToString:LowerSuagerCooker_ProductID]) {
            NSString *deviceNameStr=[NSUserDefaultsInfos getValueforKey:[dic[@"mac"] stringByAppendingString:@"name"]];
            device.deviceName=kIsEmptyString(deviceNameStr)?@"云智能降糖饭煲":deviceNameStr;
            device.device_id=[dic[@"id"] integerValue];
            device.product_id=productID;
            device.mac=dic[@"mac"] ;
            device.access_key=dic[@"access_key"];
            device.role=[dic[@"role"] integerValue];
            [device.stateDict setObject:@"离线" forKey:@"state"];
            [arr addObject:device];
        }
    }
    _deviceModelArr=arr;
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:list forKey:@"devices"];
    [userDefault synchronize];
    return arr;
}

#pragma mark 获取设备实体列表
-(void)getDeviceEntityListWithDeviceList:(NSArray *)list{
    NSMutableArray *deviceArr=[[NSMutableArray alloc]init];
    for (NSDictionary *dic in list) {
        NSString *productID=dic[@"product_id"];
        NSMutableDictionary *mdic=[NSMutableDictionary dictionary];
        if ([productID isEqualToString:LowerSuagerCooker_ProductID]) {
            NSString *deviceValue=[dic objectForKey:[dic[@"mac"] stringByAppendingString:@"name"]];
            NSString *deviceName=kIsEmptyString(deviceValue)?@"云智能降糖饭煲":deviceValue;
            [mdic setValue:@"" forKey:@"mcuHardVersion"];
            [mdic setValue:deviceName forKey:@"deviceName"];
            [mdic setValue:dic[@"id"] forKey:@"deviceID"];
            [mdic setValue:dic[@"product_id"] forKey:@"productID"];
            [mdic setValue:@"" forKey:@"mcuSoftVersion"];
            [mdic setValue:dic[@"mac"]  forKey:@"macAddress"];
            [mdic setValue:dic[@"mcu_version"] forKey:@"version"];
            [mdic setValue:[NSNumber numberWithBool:TRUE] forKey:@"deviceInit"];
            [mdic setValue:dic[@"access_key"] forKey:@"accessKey"];
            NSInteger roleInt=[dic[@"role"] integerValue];
            [mdic setValue:[NSNumber numberWithInteger:roleInt] forKey:@"role"];// 判断是否是管理员
            
            DeviceEntity *device=[[DeviceEntity alloc] initWithDictionary:mdic];
            [[XLinkExportObject sharedObject] initDevice:device];
            device.version=2;
            MyLog(@"devive---accessKey:%@",device.accessKey);
            [[XLinkExportObject sharedObject] connectDevice:device andAuthKey:device.accessKey];
            [deviceArr addObject:device];
        }
    }
    self.deviceConnectArr=deviceArr;
}

#pragma mark 获取设备状态
-(NSMutableDictionary *)getStateDicWithDevice:(DeviceEntity *)device Data:(NSData *)data{
    NSMutableDictionary *dic;
    uint8_t cmd_data[[data length]];
    uint32_t cmd_len = (uint32_t)[data length];
    memset(cmd_data, 0, [data length]);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    if ([device.productID isEqualToString:LowerSuagerCooker_ProductID]) {
        if (cmd_data[5]==0x12||cmd_data[5]==0x14||cmd_data[5]==0x15) {
            switch (cmd_data[8]) {
                case 0x01:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                    break;
                case 0x02:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                    break;
                case 0x03:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧报警",@"state", nil];
                    break;
                case 0x04:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"降糖饭",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"rice",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[15]],@"temperature",
                         [NSString stringWithFormat:@"%i",cmd_data[16]],@"calories1",
                         [NSString stringWithFormat:@"%i",cmd_data[17]],@"calories2",
                         [NSString stringWithFormat:@"%i",cmd_data[18]],@"percent", nil];
                    break;
                case 0x05:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"降糖煮",@"state",
                         [self getCloudMenuName:data],@"name",
                         [NSString stringWithFormat:@"%i",cmd_data[29]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[30]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[31]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[32]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[33]],@"rice",
                         [NSString stringWithFormat:@"%i",cmd_data[34]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[35]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[36]],@"temperature",
                         [NSString stringWithFormat:@"%i",cmd_data[37]],@"calories1",
                         [NSString stringWithFormat:@"%i",cmd_data[38]],@"calories2",
                         [NSString stringWithFormat:@"%i",cmd_data[39]],@"percent", nil];
                    break;
                case 0x06:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"蒸煮",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[15]],@"temperature",nil];
                    break;
                case 0x07:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煲粥",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[15]],@"temperature",nil];
                    break;
                case 0x08:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"杂粮粥",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[15]],@"temperature",nil];
                    break;
                case 0x09:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煮饭",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"rice",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[15]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[16]],@"temperature",nil];
                    break;
                case 0x0A:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煲汤",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"temperature",nil];
                    break;
                case 0x0B:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",
                         [self getCloudMenuName:data],@"name",
                         [NSString stringWithFormat:@"%i",cmd_data[29]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[30]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[31]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[32]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[33]],@"rice",
                         [NSString stringWithFormat:@"%i",cmd_data[34]],@"taste",
                         [NSString stringWithFormat:@"%i",cmd_data[35]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[36]],@"temperature",
                         [NSString stringWithFormat:@"%i",cmd_data[37]],@"calories1",
                         [NSString stringWithFormat:@"%i",cmd_data[38]],@"calories2",nil];
                    break;
                case 0x0C:
                    dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"热饭",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"temperature",nil];
                    break;
                case 0x0D:
                    dic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"保温",@"state",
                         [NSString stringWithFormat:@"%i",cmd_data[9]],@"orderHour",
                         [NSString stringWithFormat:@"%i",cmd_data[10]],@"orderMin",
                         [NSString stringWithFormat:@"%i",cmd_data[11]],@"WorkHour",
                         [NSString stringWithFormat:@"%i",cmd_data[12]],@"WorkMin",
                         [NSString stringWithFormat:@"%i",cmd_data[13]],@"progress",
                         [NSString stringWithFormat:@"%i",cmd_data[14]],@"temperature",nil];
                    break;
                default:
                    break;
            }
        }
    }
    return dic;
}


#pragma mark 发送设备指令
-(void)sendCommandForDevice:(TCDeviceModel *)model{
    NSString *commandType=[model.stateDict objectForKey:@"state"];
    NSString *commandStr=@"0000000000140000";
    if ([model.product_id isEqualToString:LowerSuagerCooker_ProductID]) {
        if ([commandType isEqualToString:@"空闲"]) {
            commandStr=[commandStr stringByAppendingString:@"01"];
        }else{
            int orderhour=[[model.stateDict objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.stateDict objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            NSString *feel=@"00";   //口感
            if ([commandType isEqualToString:@"降糖饭"]) {
                feel=[NSString stringWithFormat:@"%02lX",(long)model.rice.riceId];
                NSInteger percent=[model.rice.lowSugarPercent integerValue];
                NSString *percentStr=[NSString stringWithFormat:@"%02lX",(long)percent];
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",orderHour,orderMin,feel,percentStr]];
            }else if ([commandType isEqualToString:@"降糖煮"]){
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"05",orderHour,orderMin]];
            }else if ([commandType isEqualToString:@"煮饭"]){
                NSString *riceStr=@"00";
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"09",orderHour,orderMin,riceStr,feel]];
            }else if ([commandType isEqualToString:@"云菜谱"]){
                NSString *controlStr=[NSString stringWithFormat:@"%@",[model.stateDict objectForKey:@"cloudMenu"]];
                NSInteger calorie1=[[model.stateDict objectForKey:@"calorie1"] integerValue];
                NSString *calorieStr1=[NSString stringWithFormat:@"%02lX",(long)calorie1];
                NSInteger calorie2=[[model.stateDict objectForKey:@"calorie2"] integerValue];
                NSString *calorieStr2=[NSString stringWithFormat:@"%02lX",(long)calorie2];
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"0B",orderHour,orderMin,controlStr,calorieStr1,calorieStr2]];
            }else if ([commandType isEqualToString:@"热饭"]){
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"0C",orderHour,orderMin]];
            }else if ([commandType isEqualToString:@"保温"]){
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"0D",orderHour,orderMin]];
            }else{
                int workhour=[[model.stateDict objectForKey:@"workHour"] intValue];
                NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
                
                int workmin = [[model.stateDict objectForKey:@"workMin"] intValue];
                NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
                
                if ([commandType isEqualToString:@"蒸煮"]) {
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"06",orderHour,orderMin,workHour,workMin,feel]];
                }else if ([commandType isEqualToString:@"煲粥"]){
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"07",orderHour,orderMin,workHour,workMin,feel]];
                }else if ([commandType isEqualToString:@"杂粮粥"]){
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"08",orderHour,orderMin,workHour,workMin,feel]];
                }else if ([commandType isEqualToString:@"煲汤"]){
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"0A",orderHour,orderMin,workHour,workMin]];
                }
            }
        }
    }
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        NSData *sendData=[NSData nsstringToHex:commandStr];
        NSLog(@"%@(%@)发送>>命令: %@",model.deviceName,[device getMacAddressSimple], [sendData hexString]);
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject] sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:sendData];
        }
    }
}

#pragma mark 发送获取偏好设备指令
-(void)sendGetPeferenceCommandForDevice:(TCDeviceModel *)model preferenceString:(NSString *)preferenceString{
    NSData * Data;
    if ([model.product_id isEqualToString:LowerSuagerCooker_ProductID]) {
        Data=[NSData nsstringToHex:@"000000000011000005"];
    }
    MyLog(@"获取（%@）%@偏好－－－data:%@",model.deviceName,preferenceString,[Data hexString]);
    
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:Data];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:Data];
        }
    }
}

#pragma mark 发送设置偏好设备指令
-(void)sendSetPreferenceCommandForDevice:(TCDeviceModel *)model{
    NSString *commandStr=@"000000000013000005";;
    NSString *commandType=[model.stateDict objectForKey:@"state"];
    
    if ([commandType isEqualToString:@"降糖煮"]){
        NSString *controlStr= [model.stateDict objectForKey:@"cloudMenu"];
        //卡路里
        int calorie=[[model.stateDict objectForKey:@"calorie"] intValue];
        NSString *calorieStr=nil;
        if (calorie<256) {
           calorieStr=[NSString stringWithFormat:@"%02X00",calorie];
        }else if(calorie<4096){
           calorieStr=[NSString stringWithFormat:@"%02X0",calorie];
        }else{
           calorieStr=[NSString stringWithFormat:@"%02X",calorie];
        }
        //降糖比
        int percent=[[model.stateDict objectForKey:@"lowerSugarPercent"] intValue];
        NSString *percentStr=[NSString stringWithFormat:@"%02X",percent];
        
        commandStr=[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",controlStr,calorieStr,percentStr]];
    }
    
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        NSData *sendData=[NSData nsstringToHex:commandStr];
        MyLog(@"%@(%@)发送>>命令: %@",device.deviceName,[device getMacAddressSimple], [sendData hexString]);
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}



#pragma mark -- Private Methods
#pragma mark 云菜谱名称解析  //00000000 00140000 0b647177 64717700 00000000 00000000 00000000 00000000 00000002 2969fe
-(NSString *)getCloudMenuName:(NSData *)data{
    uint8_t cmd_data[[data length]];
    uint32_t cmd_len = (uint32_t)[data length];
    memset(cmd_data, 0, [data length]);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    NSString *PreferenceInfo=@"";
    for (int i=9;i<28;i++) {
        NSString *codeStr=[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]];
        if ([codeStr isEqualToString:@"\0"]) {
            break;
        }
        int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
        i++;
        NSString *tempStr=[NSString stringWithFormat:@"%C",(unichar)acciiCode];
        PreferenceInfo=[PreferenceInfo stringByAppendingString:tempStr];
    }
    return PreferenceInfo;
}

#pragma mark 获取对应设备实体
-(DeviceEntity *)getDeviceEntityWithDeviceMac:(NSString *)mac{
    DeviceEntity *device=[[DeviceEntity alloc] init];
    for (DeviceEntity *entity in self.deviceConnectArr) {
        if ([[entity getMacAddressSimple] isEqualToString:mac]) {
            device=entity;
            break;
        }
    }
    return device;
}

#pragma mark 调用计时器发送获取设备状态指令
-(void)getStateForSendCommandWithDevice:(TCDeviceModel *)model{
    if (!myTimer) {
        myTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getDeviceStateForDevice:) userInfo:model repeats:YES];
    }
}

#pragma mark 停止计时器
-(void)cancelGetDeviceStateTimer{
    if (myTimer) {
        [myTimer invalidate];
        myTimer=nil;
    }
}

#pragma mark 重置设备
-(void)resetDevice:(TCDeviceModel *)model{
    [SVProgressHUD show];

    if (!overTimer) {
        overTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendControllCommandOverTime) userInfo:nil repeats:NO];
    }
    
    NSString *commandStr=@"16AA0000";
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        NSData *sendData=[NSData nsstringToHex:commandStr];
        MyLog(@"重置设备(%@)发送指令：%@",model.mac,[sendData hexString]);
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject] sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:sendData];
        }
    }
}

#pragma mark 停止重置
-(void)dismissProgressView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (overTimer) {
                [overTimer invalidate];
                overTimer=nil;
            }
            [SVProgressHUD dismiss];
        });
    });
}

#pragma mark 连接设备
-(void)connectDevice:(TCDeviceModel *)model{
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        [[XLinkExportObject sharedObject] initDevice:device];
        device.version=2;
        [[XLinkExportObject sharedObject] connectDevice:device andAuthKey:device.accessKey];
    }
}

#pragma mark 根据设备ID获取设备名称
-(NSString *)getDeviceNameFormDeviceID:(NSInteger)deviceID{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"devices"];
    for (NSDictionary *dict in arr) {
        if ([dict[@"id"] integerValue]==deviceID) {
            if ([dict[@"product_id"] isEqualToString:LowerSuagerCooker_ProductID]) {
                NSString *deviceName=[NSUserDefaultsInfos getValueforKey:[dict[@"mac"] stringByAppendingString:@"name"]];
                return kIsEmptyString(deviceName)?@"云智能降糖饭煲":deviceName;
            }
        }
    }
    return nil;
}


#pragma mark 根据mac地址获取设备对象
-(TCDeviceModel *)getDeviceModelWithMac:(NSString *)mac{
    for (TCDeviceModel *device in _deviceModelArr) {
        if ([device.mac isEqualToString:mac]) {
            return device;
        }
    }
    return nil;
}

#pragma mark -- Private methods
#pragma mark 发送获取设备状态指令
-(void)getDeviceStateForDevice:(NSTimer *)timer{
    TCDeviceModel *model=(TCDeviceModel *)timer.userInfo;
    NSData * Data=[NSData nsstringToHex:@"0000000000120000"];
    DeviceEntity *device=[self getDeviceEntityWithDeviceMac:model.mac];
    if (device) {
        MyLog(@"发送查询设备(%@)状态>>：%@", device.getMacAddressSimple,[Data hexString]);
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
        }else{
            [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
        }
    }
}

-(void)sendControllCommandOverTime{
    [SVProgressHUD showErrorWithStatus:@"重置设备失败"];
}

@end
