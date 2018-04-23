//
//  DevicePeferenceFunctionView.m
//  TonzeCloud
//
//  Created by vision on 17/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "DevicePeferenceFunctionView.h"
#import "TCFunctionButton.h"
#import "TCMainDeviceHelper.h"
#import "NSData+Extension.h"
#import "TCCookListModel.h"

@interface DevicePeferenceFunctionView (){
    UIImageView    *menuImageView;    //菜谱图片
    UILabel        *menuNameLab;      //菜谱名称
    UILabel        *menuDetailLab;    //菜谱摘要
    UILabel        *detailLab;        //更换偏好
    
    UIActivityIndicatorView  *activityView;
    UILabel       *activityLab;
}

@end

@implementation DevicePeferenceFunctionView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        menuImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 60)];
        menuImageView.image=[UIImage imageNamed:@"img_bg_title"];
        [self addSubview:menuImageView];
        
        menuNameLab=[[UILabel alloc] initWithFrame:CGRectMake(menuImageView.right+10, 10, kScreenWidth-menuImageView.right-80, 30)];
        menuNameLab.font=[UIFont systemFontOfSize:16];
        menuNameLab.textColor=[UIColor blackColor];
        [self addSubview:menuNameLab];
        menuNameLab.hidden=YES;
        
        activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(menuImageView.right, 10, 30, 30)];
        [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        activityView.color=kSystemColor;
        [self addSubview:activityView];
        
        activityLab=[[UILabel alloc] initWithFrame:CGRectMake(activityView.right, 10, 120, 30)];
        activityLab.font=[UIFont systemFontOfSize:14];
        activityLab.textColor=[UIColor blackColor];
        activityLab.text=@"正在加载设备偏好";
        [self addSubview:activityLab];
       
        menuDetailLab=[[UILabel alloc] initWithFrame:CGRectMake(menuImageView.right+10, menuNameLab.bottom, 120, 30)];
        menuDetailLab.font=[UIFont systemFontOfSize:12];
        menuDetailLab.textColor=[UIColor lightGrayColor];
        menuDetailLab.text=@"当前设备偏好";
        [self addSubview:menuDetailLab];
        
        detailLab=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-80, 25, 60, 30)];
        detailLab.font=[UIFont systemFontOfSize:14];
        detailLab.textColor=[UIColor lightGrayColor];
        detailLab.textAlignment=NSTextAlignmentRight;
        detailLab.text=@"更换偏好";
        [self addSubview:detailLab];
        detailLab.hidden=YES;
        
        UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-20, (80-20)/2, 20, 20)];
        arrowImageView.image=[UIImage imageNamed:@"箭头"];
        [self addSubview:arrowImageView];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 79, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        UIButton *changePeferenceBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
        [changePeferenceBtn addTarget:self action:@selector(changeDevicePeferenceAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changePeferenceBtn];
        
        CGFloat  btnW=130;
        CGFloat  space=(kScreenWidth-2*btnW)/3.0;
        NSArray *arr=@[@"立即启动",@"预约启动"];
        for (NSInteger i=0; i<arr.count; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(space*(i+1)+btnW*i, 80+35, btnW, 40)];
            btn.tag=100+i;
            btn.backgroundColor=kSystemColor;
            btn.layer.cornerRadius=20;
            btn.clipsToBounds=YES;
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            [btn addTarget:self action:@selector(functionButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        UILabel *descLab=[[UILabel alloc] initWithFrame:CGRectMake(30, 190, kScreenWidth-60, 30)];
        descLab.textAlignment=NSTextAlignmentCenter;
        descLab.font=[UIFont systemFontOfSize:14];
        descLab.text=@"降糖煮可有效降低单一食物的糖分";
        descLab.textColor=[UIColor lightGrayColor];
        [self addSubview:descLab];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(preferenceFunctionViewOnPipeData:) name:kOnRecvLocalPipeData object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(preferenceFunctionViewOnPipeData:) name:kOnRecvPipeData object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(preferenceFunctionViewOnPipeData:) name:kOnRecvPipeSyncData object:nil];
        
    }
    return self;
}

-(void)showForGetDevicePreference{
    [activityView startAnimating];
    [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendGetPeferenceCommandForDevice:self.model preferenceString:@"降糖煮"];
}

#pragma mark -- NSNotification
-(void)preferenceFunctionViewOnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    
    //00000000 00110000 05bdb5cc c7baecca ed000000 00000000 00000000 00000000
    MyLog(@"降糖饭煲降糖煮偏好,preferenceFunctionViewOnPipeData--%@",[recvData hexString]);
    
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        if (cmd_data[5]==0x11) {
            NSString *preferenceName=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getCloudMenuName:recvData];
            MyLog(@"降糖饭煲降糖煮菜谱名称:%@",preferenceName);
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kCloudMenuList body:@"page_num=1&page_size=20&type=1&equipment=11&tag=5" success:^(id json) {
                NSMutableArray *resultArr = [json objectForKey:@"result"];
                if (kIsArray(resultArr)) {
                    for (NSDictionary *dic  in resultArr) {
                        if ([dic[@"name"] isEqualToString:preferenceName]) {
                            [self performSelectorOnMainThread:@selector(getCloudMenuDetailWithMenuDict:) withObject:dic waitUntilDone:YES];
                            break;
                        }
                    }
                }
            } failure:^(NSString *errorStr) {
                
            }];
        }
    }
}

-(void)getCloudMenuDetailWithMenuDict:(NSDictionary *)menuDict{
    [activityView stopAnimating];
    activityView.hidden=YES;
    activityLab.hidden=YES;
    menuNameLab.hidden=NO;
    detailLab.hidden=NO;
    menuNameLab.text=menuDict[@"name"];
    [menuImageView sd_setImageWithURL:[NSURL URLWithString:menuDict[@"image_id_cover"]] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
}


#pragma mark -- Event Response
#pragma mark 立即启动或预约启动
-(void)functionButtonClickAction:(UIButton *)sender{
    if ([_viewDelegate respondsToSelector:@selector(devicePeferenceFunctionViewDidSelectedFunctionWithTag:)]) {
        [_viewDelegate devicePeferenceFunctionViewDidSelectedFunctionWithTag:sender.tag];
    }
}

#pragma mark 更换偏好
-(void)changeDevicePeferenceAction{
    if ([_viewDelegate respondsToSelector:@selector(devicePeferenceFunctionViewChangePeferenceMenuAction)]) {
        [_viewDelegate devicePeferenceFunctionViewChangePeferenceMenuAction];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
}

@end
