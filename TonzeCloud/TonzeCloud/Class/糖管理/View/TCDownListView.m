//
//  TCDownListView.m
//  TonzeCloud
//
//  Created by vision on 17/5/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDownListView.h"

@interface TCDownListView (){
    CGFloat       btnH;
    UIImageView   *selImageView;
}

@end


@implementation TCDownListView

-(instancetype)initWithFrame:(CGRect)frame list:(NSArray *)list{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat w=frame.size.width;
        NSInteger count=list.count>0?list.count:1;
        btnH=frame.size.height/count;
        
        for (NSInteger i=0; i<list.count; i++) {
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, btnH*i, w, btnH-1)];
            aView.backgroundColor=[UIColor whiteColor];
            aView.userInteractionEnabled=YES;
            [self addSubview:aView];
            
            UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, btnH-1, w, 1)];
            line.backgroundColor=kLineColor;
            [self addSubview:line];
            
            UILabel *textlbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, btnH-10)];
            textlbl.text=list[i];
            textlbl.font=[UIFont systemFontOfSize:14];
            textlbl.textColor=[UIColor blackColor];
            [aView addSubview:textlbl];
            
            aView.tag=i;
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForChooseWithGesture:)];
            [aView addGestureRecognizer:tap];
        }
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-1, w, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        selImageView=[[UIImageView alloc] initWithFrame:CGRectMake(w-40, 10, 20, 20)];
        selImageView.image=[UIImage imageNamed:@"ic_pub_choose_sel"];
        [self addSubview:selImageView];
        
    }
    return self;
}


-(void)tapForChooseWithGesture:(UITapGestureRecognizer *)sender{
    NSInteger index=sender.view.tag;
    CGRect imageFrame=selImageView.frame;
    imageFrame.origin.y=btnH*index+10;
    selImageView.frame=imageFrame;
    
    if ([_delegate respondsToSelector:@selector(selectObjectForIndex:)]) {
        [_delegate selectObjectForIndex:index];
    }
}


@end
