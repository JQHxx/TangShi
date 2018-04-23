//
//  HuoDongHttpRequest.m
//  TonzeCloud
//
//  Created by vision on 17/9/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "HuoDongHttpRequest.h"

#define HuoDongRequestRUI  @"http://data.huodonghezi.com%@"

@implementation HuoDongHttpRequest

singleton_implementation(HuoDongHttpRequest)

-(void)huoDongHZRequestWithURL:(NSString *)urlStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:HuoDongRequestRUI,urlStr];
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    MyLog(@"huoDongHZRequest:%@",urlString);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data != nil) {
            id json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MyLog(@"json:%@",json);
            NSInteger status=[[json objectForKey:@"error_code"] integerValue];
            NSString *message=[json objectForKey:@"error_msg"];
            if (status==0) {
                success(json);
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                failure(message);
            }
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        } else {
            MyLog(@"error:%@", connectionError.localizedDescription);
            failure(connectionError.localizedDescription);
        }
    }];
}



@end
