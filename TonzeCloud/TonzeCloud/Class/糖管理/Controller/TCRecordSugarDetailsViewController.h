//
//  TCRecordSugarDetailsViewController.h
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCRecordSugarDetailsViewController : BaseViewController

@property (nonatomic,assign)double    sugarValue;      //血糖值

@property (nonatomic, copy )NSString  *measureTimeStr; //测量时间

@property (nonatomic, copy )NSString  *timeSlotStr;    //时间段

@property (nonatomic,strong)NSDictionary *sugarDict;

@property (nonatomic,assign)BOOL  isEditSugarRecord;

@property (nonatomic,assign)BOOL  isDeviceMesureIn;

@property (nonatomic,assign)BOOL  isSugarData;

@end
