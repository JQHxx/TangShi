//
//  WLScrollView.h
//  WOWlife
//
//  Created by Jone on 15/11/20.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^singleTapBlock)();

@interface WLScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, copy) singleTapBlock block;

@end
