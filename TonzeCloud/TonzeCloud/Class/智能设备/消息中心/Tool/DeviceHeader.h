//
//  DeviceHeader.h
//  TonzeCloud
//
//  Created by vision on 17/9/4.
//  Copyright © 2017年 tonze. All rights reserved.
//

#ifndef DeviceHeader_h
#define DeviceHeader_h

#define D_GET_DEVICE_INFO 0x10   //查询设备类型
#define D_GET_DEVICE_PROP 0x11    //获取设备属性
#define D_GET_DEVICE_STA 0x12    //获取设备状态
#define D_SET_DEVICE_PROP  0x13     //设置设备属性
#define D_SET_DEVICE_STA  0x14       //设置设备状态
#define D_REPORT_DEVICE_STA 0x15      //设备上报状态

#define FREE 0x01                            //空闲
#define SENSOR_UNUSUAL 0x02                 //传感器异常
#define OVERHEATING 0x03                    //过热异常
#define DRY_STATE 0x04                       //干烧状态、电路系统异常
#define NO_POT_ALARM 0x05                   //无锅报警
#define POWER_VOLTAGE 0x06                  //电网电压异常
#define BATTERY_VOLTAGE 0x07                //电池电压异常
#define ESSENCE_COOK_COMMAND 0x08           //精华煮命令
#define ULTRAFAST_COOK_COMMAND 0x09         //超快煮命令
#define PORRIDGE_COMMAND 0x0A               //煮粥命令
#define COOKING_COMMAND 0x0B                //蒸煮命令
#define HOT_MEALS_COMMAND 0x0C              //热饭
#define NUTRITION_INSULATION_COMMAND 0x0D   //保温命令
#define CLOUD_RECIPES_COMMAND 0x0E          //云菜谱命令
#define SOUP_COMMAND_COMMAND 0x0F           //煲汤命令
#define PUSH_NOTI 0x10                      //推送提醒


#endif /* DeviceHeader_h */
