//
//  TCBleConnectView.m
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBleConnectView.h"

@interface TCBleConnectView (){
    UIImageView    *scanImageView;
    UILabel        *lanyaLabel;
    UIImageView    *scanAnimationImageView;
    
    UIImageView    *connectImageView;
    UILabel        *connectLabel;
    UIImageView    *conncectAnimationImageView;
    
    UIImageView    *testPaperImageView;
    UILabel        *testLabel;
    UIImageView    *testAnimationImageView;
    
    UIImageView    *measureImageView;
    UILabel        *measureLabel;
}

@end

@implementation TCBleConnectView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        CGFloat imgW=floor((kScreenWidth-40)/7.0);
        
        //开启蓝牙
        scanImageView=[[UIImageView alloc] initWithFrame:CGRectMake((imgW-40)/2+20, 10, 40, 40)];
        scanImageView.image=[UIImage imageNamed:@"ic_xty_lanya_off"];
        [self addSubview:scanImageView];
        
        lanyaLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, scanImageView.bottom+10, imgW+40, 20)];
        lanyaLabel.font=[UIFont systemFontOfSize:10];
        lanyaLabel.textAlignment=NSTextAlignmentCenter;
        lanyaLabel.text=@"开启蓝牙";
        [self addSubview:lanyaLabel];
        
        scanAnimationImageView=[[UIImageView alloc] initWithFrame:CGRectMake(imgW+30, 20, imgW-20, 20)];
        scanAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_un"];
        [self addSubview:scanAnimationImageView];
        
        //等待连接
        connectImageView=[[UIImageView alloc] initWithFrame:CGRectMake(2*imgW+(imgW-40)/2+20, 10, 40, 40)];
        connectImageView.image=[UIImage imageNamed:@"ic_xty_lianjie_off"];
        [self addSubview:connectImageView];
        
        connectLabel=[[UILabel alloc] initWithFrame:CGRectMake(2*imgW, scanImageView.bottom+10, imgW+40, 20)];
        connectLabel.font=[UIFont systemFontOfSize:10];
        connectLabel.textAlignment=NSTextAlignmentCenter;
        connectLabel.text=@"等待连接";
        [self addSubview:connectLabel];
        
        conncectAnimationImageView=[[UIImageView alloc] initWithFrame:CGRectMake(3*imgW+10+20, 20, imgW-20, 20)];
        conncectAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_un"];
        [self addSubview:conncectAnimationImageView];
        
        //插入试纸
        testPaperImageView=[[UIImageView alloc] initWithFrame:CGRectMake(4*imgW+(imgW-40)/2+20, 10, 40, 40)];
        testPaperImageView.image=[UIImage imageNamed:@"xty01_link_03_grey"];
        [self addSubview:testPaperImageView];
        
        testLabel=[[UILabel alloc] initWithFrame:CGRectMake(4*imgW, scanImageView.bottom+10, imgW+40, 20)];
        testLabel.font=[UIFont systemFontOfSize:10];
        testLabel.textAlignment=NSTextAlignmentCenter;
        testLabel.text=@"插入试纸";
        [self addSubview:testLabel];
        
        testAnimationImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5*imgW+10+20, 20, imgW-20, 20)];
        testAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_un"];
        [self addSubview:testAnimationImageView];
        
        //准备测量
        measureImageView=[[UIImageView alloc] initWithFrame:CGRectMake(6*imgW+(imgW-40)/2+20, 10, 40, 40)];
        measureImageView.image=[UIImage imageNamed:@"ic_xty_ready_off"];
        [self addSubview:measureImageView];
        
        measureLabel=[[UILabel alloc] initWithFrame:CGRectMake(6*imgW, scanImageView.bottom+10, imgW+40, 20)];
        measureLabel.font=[UIFont systemFontOfSize:10];
        measureLabel.textAlignment=NSTextAlignmentCenter;
        measureLabel.text=@"准备测量";
        [self addSubview:measureLabel];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, kScreenWidth, 10)];
        bgView.backgroundColor = [UIColor bgColor_Gray];
        [self addSubview:bgView];
        
    }
    return self;
}

-(void)setConnectType:(ConnectType)connectType{
    _connectType=connectType;
    
    switch (connectType) {
        case ConnectTypeDisable:{
            scanImageView.image=[UIImage imageNamed:@"ic_xty_lanya_off"];
            connectImageView.image=[UIImage imageNamed:@"ic_xty_lianjie_off"];
            measureImageView.image=[UIImage imageNamed:@"ic_xty_ready_off"];
            conncectAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_un"];

            scanAnimationImageView.animationImages=@[[UIImage imageNamed:@"ic_xty_loading_01"],[UIImage imageNamed:@"ic_xty_loading_02"],[UIImage imageNamed:@"ic_xty_loading_03"]];
            scanAnimationImageView.animationDuration=1; //设置动画时间
            scanAnimationImageView.animationRepeatCount=0; //设置动画次数 0 表示无限
            [scanAnimationImageView startAnimating];

            [conncectAnimationImageView stopAnimating];
        }
            break;
        case ConnectTypeEnable:{
            scanImageView.image=[UIImage imageNamed:@"ic_xty_lanya_on"];
            lanyaLabel.text=@"蓝牙已开启";
        }
            
            break;
        case ConnectTypeScanning:{
            scanAnimationImageView.animationImages=@[[UIImage imageNamed:@"ic_xty_loading_01"],[UIImage imageNamed:@"ic_xty_loading_02"],[UIImage imageNamed:@"ic_xty_loading_03"]];
            scanAnimationImageView.animationDuration=1; //设置动画时间
            scanAnimationImageView.animationRepeatCount=0; //设置动画次数 0 表示无限
            [scanAnimationImageView startAnimating];
        }
            
            break;
        case ConnectTypeConnecting:{
            
            
        }
            break;
        case ConnectTypeConnected:{
            [scanAnimationImageView stopAnimating];
            scanAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_03"];
            
            connectImageView.image=[UIImage imageNamed:@"ic_xty_lianjie_on"];
            connectLabel.text=@"连接成功";
            
            conncectAnimationImageView.animationImages=@[[UIImage imageNamed:@"ic_xty_loading_01"],[UIImage imageNamed:@"ic_xty_loading_02"],[UIImage imageNamed:@"ic_xty_loading_03"]];
            conncectAnimationImageView.animationDuration=1; //设置动画时间
            conncectAnimationImageView.animationRepeatCount=0; //设置动画次数 0 表示无限
            [conncectAnimationImageView startAnimating];
            
            
        }
            break;
        case ConnectTypeInsertTestPaper:{
            [conncectAnimationImageView stopAnimating];
            conncectAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_03"];
            
            testPaperImageView.image=[UIImage imageNamed:@"xty01_link_03_green"];
            testLabel.text=@"已插试纸";
            
            testAnimationImageView.animationImages=@[[UIImage imageNamed:@"ic_xty_loading_01"],[UIImage imageNamed:@"ic_xty_loading_02"],[UIImage imageNamed:@"ic_xty_loading_03"]];
            testAnimationImageView.animationDuration=1; //设置动画时间
            testAnimationImageView.animationRepeatCount=0; //设置动画次数 0 表示无限
            [testAnimationImageView startAnimating];
            
        }
            break;
        case ConnectTypeMeasuring:
        {
            [testAnimationImageView stopAnimating];
            testAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_03"];
            
        }
            break;
        case ConnectTypeMeasureSucess:
        {
            [testAnimationImageView stopAnimating];
            testAnimationImageView.image=[UIImage imageNamed:@"ic_xty_loading_03"];
            measureImageView.image=[UIImage imageNamed:@"ic_xty_ready_on"];
            measureLabel.text=@"测量成功";
        }
            break;
            
        default:
            break;
    }
}

@end
