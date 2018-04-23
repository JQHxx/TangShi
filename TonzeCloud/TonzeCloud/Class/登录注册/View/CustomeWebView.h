//
//  CustomeWebView.h
//  TestHZSDK
//
//  Created by Gibson on 2017/5/31.
//  Copyright © 2017年 huodonghezi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomeWebView : UIViewController
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)NSString *url;

-(void)load:(NSString *)url;

@end
