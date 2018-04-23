//
//  TCHttpRequest.m
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import "TCHttpRequest.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "JPUSHService.h"

@interface TCHttpRequest ()<UIAlertViewDelegate>

@end
@implementation TCHttpRequest

singleton_implementation(TCHttpRequest)
#pragma mark - 基本网络请求（GET POST）
-(BOOL)isConnectedToNet{
    BOOL isYes = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isYes = NO;
            break;
        case ReachableViaWiFi:
            isYes = YES;
            break;
        case ReachableViaWWAN:
            isYes = YES;
            
        default:
            break;
    }
    return isYes;
}

#pragma mark 网络请求封装 post
-(void)postMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"POST" url:urlString body:bodyStr isLoading:YES success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark 网络请求封装 post（不带加载器）
-(void)postMethodWithoutLoadingForURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"POST" url:urlString body:bodyStr isLoading:NO success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}


#pragma mark 网络请求封装 get
- (void)getMethodWithURL:(NSString *)urlStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"GET" url:urlString body:nil isLoading:YES success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark 网络请求封装 get （不带加载器）
- (void)getMethodWithoutLoadingForURL:(NSString *)urlStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"GET" url:urlString body:nil isLoading:NO success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}


#pragma mark -- 商城网络请求
#pragma mark 商城post网络请求封装
-(void)postShopMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"POST" url:urlString body:bodyStr isLoading:YES success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}
#pragma mark 商城post网络请求封装（不带加载器）
-(void)postShopMethodWithoutLoadingURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"POST" url:urlString body:bodyStr isLoading:NO success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark 商城get网络请求封装
- (void)getShopMethodWithURL:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"GET" url:urlString body:body isLoading:isLoading success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}


#pragma mark 刷新用户凭证
-(void)refreshUserTokenAction{
    NSString *userKey=[NSUserDefaultsInfos getValueforKey:kUserKey];             //用户key
    NSString *userSecret=[NSUserDefaultsInfos getValueforKey:kUserSecret];       //用户secret
    if (!kIsEmptyString(userKey)) {
        NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDateTime];
        NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
        NSString *userSign=[NSString stringWithFormat:@"%@%ld%@",userKey,(long)timeSp,userSecret];          //签名
        NSString *body=[NSString stringWithFormat:@"user_key=%@&user_sign=%@&timestamp=%ld",userKey,[[userSign MD5] uppercaseString],(long)timeSp];
        [self postMethodWithoutLoadingForURL:kGetTokenAPI body:body success:^(id json) {
            NSDictionary *result=[json objectForKey:@"result"];
            NSString *userToken=[result valueForKey:@"user_token"];
            [NSUserDefaultsInfos putKey:kUserToken andValue:userToken];
            [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
            
        } failure:^(NSString *errorStr) {
            [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
        }];
    }
 }
#pragma mark --其他数据转json数据
-(NSString *)getValueWithParams:(id)params{
    SBJsonWriter *writer=[[SBJsonWriter alloc] init];
    NSString *value=[writer stringWithObject:params];
    MyLog(@"value:%@",value);
    return value;
}

#pragma mark -- Private Methods
#pragma mark 具体请求方法
-(void)requstMethod:(NSString *)method url:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    if (isLoading) {
        [SVProgressHUD show];
    }
   
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [request setHTTPMethod:method];
    
    //请求头信息
    NSString *userKey=[NSUserDefaultsInfos getValueforKey:kUserKey];      //用户Key
    NSString *userToken=[NSUserDefaultsInfos getValueforKey:kUserToken];  //用户Secret
    NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDateTime];
    NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
    NSString *appToken=[[[NSString stringWithFormat:@"%@%ld%@",kAppID,(long)timeSp,kAppSecret] MD5] uppercaseString];   //app签名
    
    NSDictionary *headDict=nil;
    if (!kIsEmptyString(userToken)&&!kIsEmptyString(userKey)) {
        headDict=@{@"AppId":kAppID,@"AppToken":appToken,@"TimeStamp":[NSString stringWithFormat:@"%ld",(long)timeSp],@"UserKey":userKey,@"UserToken":userToken};
    }else{
        headDict=@{@"AppId":kAppID,@"AppToken":appToken,@"TimeStamp":[NSString stringWithFormat:@"%ld",(long)timeSp]};
    }
    [request setAllHTTPHeaderFields:headDict];
    MyLog(@"headerFields:%@",headDict);
    
    
    if ([method isEqualToString:@"POST"]) {
        NSData *bodyData=[body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
        MyLog(@"url:%@,bodyStr:%@",urlStr,body);
    }else{
        MyLog(@"url:%@",urlStr);
    }
    
    kSelfWeak;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        
        // 获取http状态码
        // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSInteger statusCode=httpResponse.statusCode;
        MyLog(@"获取http状态码 url:%@,statusCode:%ld",urlStr,statusCode);
        if (statusCode==500) {
            [weakSelf errorReportWithUrl:urlStr];
        }
        
        if (data != nil) {
            MyLog(@"html:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            id json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MyLog(@"url:%@, json:%@",urlStr,json);
            NSInteger status=[[json objectForKey:@"status"] integerValue];
            NSString *message=[json objectForKey:@"message"];
            if (status==1) {
                success(json);
            }else if(status==10000){
                [weakSelf refreshUserTokenAction];
            }else if (status==903){
                NSString *gag_time = [[json objectForKey:@"result"] objectForKey:@"gag_time"];
                NSString *gag_desc = [[json objectForKey:@"result"] objectForKey:@"gag_desc"];
                
                message = [NSString stringWithFormat:@"%@,%@,%@",message,gag_time,gag_desc];
                failure(message);
            }else if(status==10001||status==10002||status==10004){
                [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
                [NSUserDefaultsInfos putKey:@"targetDailyEnergy" andValue:@"0"];
                [TCHelper sharedTCHelper].isLogin=YES;
                failure(message);
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                failure(message);
            }
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        }  else {
            MyLog(@"请求失败－－－－code:%ld,error:%@", (long)connectionError.code,connectionError.localizedDescription);
            failure(connectionError.localizedDescription);
        }
    }];
}

#pragma mark 商城基本请求方法
-(void)requstShopMethod:(NSString *)method url:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    if (isLoading) {
        [SVProgressHUD show];
    }
    
    NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDateTime];
    NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
    NSString *tempBodyStr=nil;
    if (kIsEmptyString(body)) {
        tempBodyStr=[NSString stringWithFormat:@"timestamp=%ld&version=01",(long)timeSp];
    }else{
        tempBodyStr=[NSString stringWithFormat:@"%@&timestamp=%ld&version=01",body,(long)timeSp];
    }
    NSString *sortedStr= [self getSortedStrWithParamsString:tempBodyStr method:method];
    NSString *tempSortedStr=[sortedStr stringByAppendingString:kShopAuthoriseCode];
    NSString *signStr=[tempSortedStr MD5];
    
    NSString *tempUrlStr=nil;
    NSString *bodyStr=nil;
    sortedStr=[sortedStr substringToIndex:sortedStr.length-1];
    if ([method isEqualToString:@"POST"]) {
        bodyStr=[NSString stringWithFormat:@"%@&sign=%@&sign_type=MD5",sortedStr,signStr];
        tempUrlStr=urlStr;
        MyLog(@"url:%@,bodyStr:%@",tempUrlStr,bodyStr);
    }else{
        tempUrlStr=[NSString stringWithFormat:@"%@?%@&sign=%@&sign_type=MD5",urlStr,sortedStr,signStr];
        MyLog(@"url:%@",tempUrlStr);
    }
    
    NSURL *url=[NSURL URLWithString:tempUrlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"]&&!kIsEmptyString(bodyStr)) {
        NSData *bodyData=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    kSelfWeak;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        
        // 获取http状态码
        // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSInteger statusCode=httpResponse.statusCode;
        MyLog(@"获取http状态码 url:%@,statusCode:%ld",urlStr,statusCode);
        if (statusCode==500) {
            [weakSelf errorReportWithUrl:urlStr];
        }
        
        if (data != nil) {
            MyLog(@"html:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            id json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MyLog(@"json:%@",json);
            NSInteger status=[[json objectForKey:@"status"] integerValue];
            NSString *message=[json objectForKey:@"message"];
            if (status==1) {
                success(json);
            }else if(status==10000){
                [weakSelf refreshUserTokenAction];
            }else if (status==903){
                NSString *gag_time = [[json objectForKey:@"result"] objectForKey:@"gag_time"];
                NSString *gag_desc = [[json objectForKey:@"result"] objectForKey:@"gag_desc"];
                message = [NSString stringWithFormat:@"%@,%@,%@",message,gag_time,gag_desc];
                failure(message);
            }else if(status==10001||status==10002||status==10004){
                [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
                [NSUserDefaultsInfos putKey:@"targetDailyEnergy" andValue:@"0"];
                [TCHelper sharedTCHelper].isLogin=YES;
                failure(message);
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                failure(message);
            }
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        }  else {
            MyLog(@"请求失败－－－－code:%ld,error:%@", (long)connectionError.code,connectionError.localizedDescription);
            failure(connectionError.localizedDescription);
        }
    }];
}

#pragma mark -- 上报错误信息
- (void)errorReportWithUrl:(NSString *)urlStr{
    NSString *urlString=[NSString stringWithFormat:kHostURL,kError_report];
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *body = [NSString stringWithFormat:@"url=%@&code=500&request_platform=iOS&app_version=%@",urlStr,[UIDevice getSoftwareVer]];
    NSData *bodyData=[body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    MyLog(@"上报错误信息---url:%@,bodyStr:%@",urlString,body);
    
    //请求头信息
    NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDateTime];
    NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
    NSString *appToken=[[[NSString stringWithFormat:@"%@%ld%@",kAppID,(long)timeSp,kAppSecret] MD5] uppercaseString];   //app签名
    NSDictionary *headDict=@{@"AppId":kAppID,@"AppToken":appToken,@"TimeStamp":[NSString stringWithFormat:@"%ld",(long)timeSp]};
    [request setAllHTTPHeaderFields:headDict];
    MyLog(@"headerFields:%@",headDict);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        if (data != nil) {
            MyLog(@"html:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            MyLog(@"上报错误信息成功，json:%@",[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        }  else {
            MyLog(@"上报错误信息请求失败－－－－code:%ld,error:%@", (long)connectionError.code,connectionError.localizedDescription);
        }
    }];
}


#pragma mark 请求参数按字母排序
-(NSString *)getSortedStrWithParamsString:(NSString *)paramsStr method:(NSString *)method{
    NSArray *subArray = [paramsStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    for (int i = 0 ; i < subArray.count; i++){
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[i] componentsSeparatedByString:@"="];
        //给字典加入元素
        [tempDic setObject:dicArray[1] forKey:dicArray[0]];
    }
    MyLog(@"打印参数列表生成的字典：%@", tempDic);
    
    NSArray *keys = [tempDic allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    NSMutableString *contentString  =[NSMutableString string];
    for (NSString *categoryId in sortedArray) {
        [contentString appendFormat:@"%@=%@&", categoryId, [tempDic valueForKey:categoryId]];
    }
    
    return contentString;
}

@end
