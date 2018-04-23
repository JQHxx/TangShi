//
//  TCMessageHelper.h
//  TonzeCloud
//
//  Created by vision on 17/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCDeviceMessageModel.h"


@interface TCMessageHelper : NSObject

singleton_interface(TCMessageHelper)


@property (nonatomic,copy )NSString *workState;

-(TCDeviceMessageModel *)getMessageForHandlerNofication:(NSNotification *)notifi;

-(void)configNotification:(NSString *)alertBody withType:(NSString *)typeStr;

@end
