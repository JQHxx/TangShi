//
//  CustomeWebView.m
//  TestHZSDK
//
//  Created by Gibson on 2017/5/31.
//  Copyright © 2017年 huodonghezi. All rights reserved.
//

#import "CustomeWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>

//param mark 用户跟盒子的 js 交互
@protocol JSObjcDelegate <JSExport>
//获取网页的分享内容
- (void)onShareClick:(NSString *)content;
//用于网页调用客户端的分享按钮
- (void)doShare;

//用于网页调用客户端关闭按钮
- (void)close;

@end

@interface CustomeWebView () <UIWebViewDelegate, JSObjcDelegate>
@property (strong, nonatomic) JSContext *jsContext;
@property (strong,nonatomic)UIView *navigationBar;
@property (strong,nonatomic)UILabel *titleView;
@property (assign,nonatomic)BOOL isTransparent;
@end

@implementation CustomeWebView


-(void)dealloc{
    //关闭广播监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)back:(UIButton *)id{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
  
     self.navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kNewNavHeight)];
    [self.navigationBar setBackgroundColor:kSystemColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(8, 22, 50, 44)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationBar addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(50, 22, [UIScreen mainScreen].bounds.size.width-100, 44)];
    self.titleView.text = @"糖士";
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.textColor = [UIColor whiteColor];
    [self.navigationBar addSubview:self.titleView];
    [self.view addSubview:self.navigationBar];
    
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
        webView.delegate = self;
        webView;
        
    });
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.webView];
    
    
     [self registerNotification];
    
    
    if (self.url && ![self.url containsString:@"transparent=1"]) {
        self.navigationBar.hidden = NO;
        self.webView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    }else{
        [self.view setBackgroundColor:[UIColor clearColor]];
        self.navigationBar.hidden = YES;
        self.webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];
    }
    
    if(self.url && self.url.length>0){
        NSURLRequest *nsRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
        
        [self.webView loadRequest:nsRequest];
    }
    
}

-(void)load:(NSString *)url{
    self.url = url;
   
}

#pragma mark 用于监听更新抽奖次数
-(void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataChance:) name:@"updatePrizeCount" object:nil];
}

-(void)updataChance:(NSNotification *)notification {
    NSDictionary *data = [notification userInfo];
    id dataId = [data objectForKey:@"data"];
    
    if(self.jsContext && dataId && [dataId isKindOfClass:[NSDictionary class]]){
        NSNumber *state = [dataId objectForKey:@"state"];
        NSNumber *chance = [dataId objectForKey:@"chance"];
        NSString *dataStr = [NSString stringWithFormat:@"{\"state\":%d,\"chance\":%d}",state.intValue,chance.intValue];
        NSString *updateChance = [NSString stringWithFormat:@"updateChance('%@')",dataStr];
        //        [self.webView stringByEvaluatingJavaScriptFromString:updateChance];
        [self.jsContext evaluateScript:updateChance];
    }
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if (currentURL && ![currentURL containsString:@"transparent=1"]) {
        self.navigationBar.hidden = NO;
        self.webView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    }else{
        self.navigationBar.hidden = YES;
        self.webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];
    }
    NSString *titleInfo = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.titleView setText:titleInfo];
    //跟盒子网页 js 交互 获取分享内容
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"HeziJs"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

#pragma mark - JSObjcDelegate
- (void)onShareClick:(NSString *)content {
    if (!content) {
        return;
    }
    NSLog(@"content===>%@",content);
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    if (dict) {
        NSString *title = dict[@"title"];
        NSLog(@"成功获取活动的分享内容 ==>%@",dict);
        NSLog(@"title===>%@",title);
    }
    
}

#pragma mark - JSObjcDelegate
- (void)doShare {
    NSLog(@"点击了分享按钮...");
}

#pragma mark -JSObjectDelegate
- (void)close {
    NSLog(@"页面被关闭...");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
