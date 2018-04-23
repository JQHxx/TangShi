//
//  TCPertainView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPertainView.h"


#define kImgBtnWidth (kScreenWidth-80)/4
@interface TCPertainView (){
    UILabel *titleLabel;
}

@end

@implementation TCPertainView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, kScreenWidth/2, 20)];
        titleLabel.text = @"检查报告";
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor grayColor];
        [self addSubview:titleLabel];
        
        

    }
    return self;
}

#pragma mark -- 删除图片
- (void)deleteImageForClickButton:(UIButton *)sender{
    NSInteger index=sender.tag;
    if ([_pertainDelegate respondsToSelector:@selector(pertainViewDeleteImageForIndex:)]) {
        [_pertainDelegate pertainViewDeleteImageForIndex:index];
    }
}

- (void)showBigImageDidTap:(UITapGestureRecognizer *)gesture{
    NSInteger index=gesture.view.tag;
    if ([_pertainDelegate respondsToSelector:@selector(pertainViewTapActionForIndex:)]) {
        [_pertainDelegate pertainViewTapActionForIndex:index];
    }
}

- (void)addImage:(UIButton *)button{
    if ([_pertainDelegate respondsToSelector:@selector(pertainViewAddImageAction)]) {
        [_pertainDelegate pertainViewAddImageAction];
    }
}
#pragma mark -- setter
- (void)setImageArray:(NSMutableArray *)imageArray{
    _imageArray = imageArray;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]||[view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (imageArray.count>0) {
        for (NSInteger i=0; i<imageArray.count; i++) {
            NSDictionary *imgDict=imageArray[i];
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(10+(kImgBtnWidth+20)*i, titleLabel.bottom+20, kImgBtnWidth, kImgBtnWidth)];
            imgView.tag=i;
            imgView.userInteractionEnabled=YES;
            NSInteger type=[imgDict[@"type"] integerValue];
            if (type==0) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:imgDict[@"image_url"]] placeholderImage:[UIImage imageNamed:@""]];
            }else{
                imgView.image=imgDict[@"image"];
            }
            [self addSubview:imgView];
            
            UITapGestureRecognizer *imgTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImageDidTap:)];
            [imgView addGestureRecognizer:imgTap];
            
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(imgView.right-10, imgView.top-10, 20, 20)];
            deleteBtn.tag=i;
            [deleteBtn setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteImageForClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteBtn];
        }
    }
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(10+(kImgBtnWidth+20)*imageArray.count, titleLabel.bottom+20, kImgBtnWidth, kImgBtnWidth)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"ic_frame_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
    addButton.hidden=imageArray.count>3;
}
@end
