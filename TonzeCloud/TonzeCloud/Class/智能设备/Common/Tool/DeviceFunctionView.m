//
//  DeviceFunctionView.m
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "DeviceFunctionView.h"
#import "TCFunctionButton.h"

@interface DeviceFunctionView (){
    UILabel       *titleLab;
    UILabel       *detailLab;
}

@property (nonatomic,strong)UIView *setPropertyView;

@end

@implementation DeviceFunctionView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=[UIColor whiteColor];
        
        [self addSubview:self.setPropertyView];
        
        CGFloat  btnW=130;
        CGFloat  space=(kScreenWidth-2*btnW)/3.0;
        NSArray *arr=@[@"立即启动",@"预约启动"];
        for (NSInteger i=0; i<arr.count; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(space*(i+1)+btnW*i, self.setPropertyView.bottom+25, btnW, 40)];
            btn.tag=i;
            btn.backgroundColor=kSystemColor;
            btn.layer.cornerRadius=20;
            btn.clipsToBounds=YES;
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            [btn addTarget:self action:@selector(functionButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
    }
    return self;
}



#pragma mark -- Event response
#pragma mark 设置属性（如时间）
-(void)deviceFunctionViewDidSelectProperty:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(deviceFunctionViewSetPorperty)]) {
        [_delegate deviceFunctionViewSetPorperty];
    }
}

#pragma mark 立即启动和预约启动
-(void)functionButtonDidClick:(UIButton *)sender{
    if (sender.tag==0) {
        if ([_delegate respondsToSelector:@selector(deviceFunctionViewStartNow)]) {
            [_delegate deviceFunctionViewStartNow];
        }
    }else{
        if ([_delegate respondsToSelector:@selector(deviceFunctionViewReserveStartup)]) {
            [_delegate deviceFunctionViewReserveStartup];
        }
    }
}

#pragma mark -- Setters and Getters
-(void)setIsSetProperty:(BOOL)isSetProperty{
    _isSetProperty=isSetProperty;
    self.setPropertyView.hidden=!isSetProperty;
}

-(void)setTitleStr:(NSString *)titleStr{
    _titleStr=titleStr;
    titleLab.text=titleStr;
}

-(void)setDetailStr:(NSString *)detailStr{
    _detailStr=detailStr;
    detailLab.text=detailStr;
}

#pragma mark 设置属性
-(UIView *)setPropertyView{
    if (!_setPropertyView) {
        _setPropertyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        _setPropertyView.backgroundColor=[UIColor whiteColor];
        
        titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth/2, 30)];
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textColor=[UIColor blackColor];
        [_setPropertyView addSubview:titleLab];
        
        detailLab=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-210, 10, 180, 30)];
        detailLab.font=[UIFont systemFontOfSize:16];
        detailLab.textColor=[UIColor lightGrayColor];
        detailLab.textAlignment=NSTextAlignmentRight;
        [_setPropertyView addSubview:detailLab];
        
        UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(detailLab.right, 13, 25, 25)];
        arrowImageView.image=[UIImage imageNamed:@"箭头"];
        [_setPropertyView addSubview:arrowImageView];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [_setPropertyView addSubview:line];
        
        UIButton *btn=[[UIButton alloc] initWithFrame:_setPropertyView.bounds];
        [btn addTarget:self action:@selector(deviceFunctionViewDidSelectProperty:) forControlEvents:UIControlEventTouchUpInside];
        [_setPropertyView addSubview:btn];
    }
    return _setPropertyView;
}



@end
