//
//  WLScrollView.m
//  WOWlife
//
//  Created by Jone on 15/11/20.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import "WLScrollView.h"

@interface WLScrollView ()

@end
@implementation WLScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.minimumZoomScale = 1 * self.zoomScale;
        self.maximumZoomScale = 3 * self.zoomScale;
        
        [self initImageView];
    }
    
    return self;
}

- (void)initImageView {
    self.imageView = [[UIImageView alloc] init];
//    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    
    //单击事件
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleTap.numberOfTouchesRequired = 1; //手指数
    singleTap.numberOfTapsRequired = 1; //tap次数
    [self addGestureRecognizer:singleTap];
    
    //增加双击事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleFingerEvent:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    //防止双击无效
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)tap {
    self.block();
}

- (void)handleDoubleFingerEvent:(UITapGestureRecognizer *)tap {
    static BOOL tapNum = YES;
    CGFloat scale = 1;
    if (tapNum) {
        scale = self.maximumZoomScale;
    }else {
        scale = self.minimumZoomScale;
    }
    tapNum = !tapNum;
    
    [self setZoomScale:scale animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale animated:NO];
}

@end
