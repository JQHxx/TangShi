//
//  TCSugerFilesModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/16.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "id": 1,
 "user_id": "1",
 "diabetes_type": "2型糖尿病",
 "diagnosis_year": "1489680000",
 "treatment_method": "胰岛素,饮食控制,运动控制",
 "systolic_pressure": "22",
 "add_time": "1488938523",
 "edit_time": "1489744720",
 "diastolic_blood_pressure": "33",
 "other_diseases": "高血压,肥胖,神经病变,冠心病,胆石症,酮症酸中毒",
 "is_drinking": "1",
 "is_smoking": "0"
 */
#import <Foundation/Foundation.h>

@interface TCSugerFilesModel : NSObject
@property(nonatomic,assign)NSInteger id;                      //用户id
@property(nonatomic,assign)NSInteger user_id;                 //用户id
@property(nonatomic,copy)NSString *diabetes_type;             //糖尿病类型
@property(nonatomic,copy)NSString *diagnosis_year;            //确诊日期
@property(nonatomic,copy)NSString *treatment_method;          //治疗方式
@property(nonatomic,copy)NSString *systolic_pressure;         //收缩压
@property(nonatomic,copy)NSString *add_time;                  //添加时间
@property(nonatomic,copy)NSString *edit_time;                 //结束时间
@property(nonatomic,copy)NSString *diastolic_blood_pressure;  //舒张压
@property(nonatomic,copy)NSString *other_diseases;            //其它疾病
@property(nonatomic,copy)NSString *is_drinking;               //是否喝酒
@property(nonatomic,copy)NSString *is_smoking;                //是否吸烟
@property(nonatomic,copy)NSString *name;                      //姓名
@property(nonatomic,copy)NSString *image_id;
@property(nonatomic,copy)NSString *sex;                       //性别
@property(nonatomic,copy)NSString *birthday;                  //生日
@property(nonatomic,copy)NSString *weight;                    //体重
@property(nonatomic,copy)NSString *height;                    //身高
@property(nonatomic,copy)NSString *labour_intensity;          //年龄
@property(nonatomic,copy)NSString *image_url;                 //头像
@property(nonatomic,assign)NSInteger bmi;                       //bmi
@property(nonatomic,assign)NSInteger nutrients;                 //劳动强度


@end
