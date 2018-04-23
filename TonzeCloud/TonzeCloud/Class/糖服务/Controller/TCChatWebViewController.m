//
//  TCChatWebViewController.m
//  TonzeCloud
//
//  Created by vision on 17/11/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCChatWebViewController.h"
#import <WebKit/WebKit.h>

@interface TCChatWebViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView  *rootWebView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation TCChatWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.rootWebView];
    [self.view addSubview:self.progressView];
    
    /*
     *3.添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
     */
    [self.rootWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.rootWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:self.webUrl];
    [self.rootWebView loadRequest:req];
}

#pragma mark - WKWKNavigationDelegate Methods
#pragma mark 开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    MyLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
#pragma mark 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    MyLog(@"加载完成");
}

#pragma mark - 监听web加载进度
/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.rootWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else if ([keyPath isEqualToString:@"title"]){
        if (object == self.rootWebView) {
            self.baseTitle = self.rootWebView.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -- Setters
#pragma mark UIWebView
-(WKWebView *)rootWebView{
    if (!_rootWebView) {
        _rootWebView=[[WKWebView alloc] initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _rootWebView.UIDelegate=self;
        _rootWebView.navigationDelegate=self;
    }
    return _rootWebView;
}

#pragma mark 加载进度条
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNewNavHeight,kScreenWidth, 2)];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progressTintColor = UIColorFromRGB(0xfff100);
        //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    }
    return _progressView;
}


- (void)dealloc {
    [self.rootWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.rootWebView removeObserver:self forKeyPath:@"title"];
}

@end
