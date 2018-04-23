//
//  HuoDongHttpRequest.h
//  TonzeCloud
//
//  Created by vision on 17/9/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpSuccess)(id json);//请求成功后的回调
typedef void (^HttpFailure)(NSString *errorStr);//请求失败后的回调

@interface HuoDongHttpRequest : NSObject

singleton_interface(HuoDongHttpRequest)

-(void)huoDongHZRequestWithURL:(NSString *)urlStr success:(HttpSuccess)success failure:(HttpFailure)failure;

@end
