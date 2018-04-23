//
//  TCPertainView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCPertainDelegate <NSObject>

-(void)pertainViewTapActionForIndex:(NSInteger)index;        //展开图片
-(void)pertainViewDeleteImageForIndex:(NSInteger)index;      //删除图片
-(void)pertainViewAddImageAction;     //添加图片


@end
@interface TCPertainView : UIView

@property (nonatomic,weak)id<TCPertainDelegate>pertainDelegate;

@property (nonatomic,strong)NSMutableArray *imageArray;

@end
