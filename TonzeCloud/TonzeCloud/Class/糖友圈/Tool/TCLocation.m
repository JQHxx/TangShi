//
//  TCLocation.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLocation.h"

@implementation PBLocationModel

@end

@interface TCLocation ()<CLLocationManagerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,strong) CLGeocoder        *geocoder;
@property (nonatomic,copy) complateBlock       addressBlock;

@end

@implementation TCLocation

+ (instancetype)location {
    static TCLocation *location = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        location = [[TCLocation alloc] init];
    });
    return location;
}

- (void)startLocationAddress:(complateBlock)block {
    
    self.addressBlock = block;
    
    //判断用户定位服务是否开启
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.manager requestWhenInUseAuthorization];
        }
        [self.manager startUpdatingLocation];
        return;
    }
    
    //判断定位是否开启
    if ([CLLocationManager locationServicesEnabled])
    {
        //  判断用户是否允许程序获取位置权限
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse||[CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways)
        {
            //用户允许获取位置权限
        }else
        {
            //用户拒绝开启用户权限
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务权限]来允许[糖士]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
            alertView.delegate=self;
            alertView.tag=2;
            [alertView show];
            if (self.addressBlock) {
                self.addressBlock(NO,nil,1);
            }
        }
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务]来允许[糖士]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>糖士>始终)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        alertView.delegate=self;
        alertView.tag=1;
        [alertView show];
        if (self.addressBlock) {
            self.addressBlock(NO,nil,2);
        }
    }
    
    [self stopLocation];
    if (self.addressBlock) {
        self.addressBlock(NO,nil,0);
    }
}
#pragma mark ====== UIAlertViewDelegate =======

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.000000) {
                //跳转到定位权限页面
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }else {
                //跳转到定位开关界面
                NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}
#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    // 强制转换成简体中文
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil, nil] forKey:@"AppleLanguages"];
    
    __weak typeof (self) weakSelf = self;
    PBLocationModel *model = [[PBLocationModel alloc] init];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
        model.locatedAddress = placemark.addressDictionary;
        model.name = placemark.name;
        model.country = placemark.country;
        model.postalCode = placemark.postalCode;
        model.ISOcountryCode = placemark.ISOcountryCode;
        model.administrativeArea = placemark.administrativeArea;
        model.subAdministrativeArea = placemark.subAdministrativeArea;
        model.locality = placemark.locality;
        model.subLocality = placemark.subLocality;
        model.thoroughfare = placemark.thoroughfare;
        model.subThoroughfare = placemark.subThoroughfare;
        
        if (weakSelf.addressBlock) {
            weakSelf.addressBlock (YES,model,0);
        }
    }];
    // 停止定位
    [self stopLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocation];
    if (self.addressBlock) {
        self.addressBlock (NO,nil,0);
    }
}

#pragma mark - lazy loading
- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        [_manager requestWhenInUseAuthorization];
        [_manager setDelegate:self];
        [_manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_manager setDistanceFilter:kCLDistanceFilterNone];
    }
    return _manager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
/**
 * 停止定位
 */
-(void)stopLocation {
    [self.manager stopUpdatingLocation];
    self.manager = nil; //这句话必须加上，否则可能会出现调用多次的情况
}

@end
