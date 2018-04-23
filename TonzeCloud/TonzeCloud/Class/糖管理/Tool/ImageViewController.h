//
//  ImageViewController.h
//  PushImageTest
//
//  Created by Eva on 17/4/10.
//  Copyright © 2017年 Eva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
//传入图片数组，可以是本地图片名，也可以为网络图片URL
@property (nonatomic,strong)NSArray<NSString *>*imageArray;

@property (nonatomic,assign)NSInteger index;
@end
