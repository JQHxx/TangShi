
//
//  TCIntegralTaskView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCIntegralTaskNoticeView.h"

#define DEALY_WHEN_TITLE_IN_MIDDLE  4.0
#define DEALY_WHEN_TITLE_IN_BOTTOM  0.0


@interface TCIntegralTaskNoticeView ()<UIScrollViewDelegate>{
    NSInteger _carryOutNmb;   // 完成任务量
}
///
@property (nonatomic ,strong) UILabel *titleLabe;
@property (nonatomic, strong) UILabel *taskLabel;
@property (nonatomic ,strong) UILabel *taskNumLab;

/**
 *  滚动视图
 */
@property (nonatomic,strong) UIScrollView *ccpScrollView;
/**
 *  label的宽度
 */
@property (nonatomic,assign) CGFloat labelW;
/**
 *  label的高度
 */
@property (nonatomic,assign) CGFloat labelH;
/**
 *  定时器
 */
@property (nonatomic,strong) NSTimer *timer;
/**
 *  记录滚动的页码
 */
@property (nonatomic,assign) int page;


@end

@implementation TCIntegralTaskNoticeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.labelW = frame.size.width;
        
        self.labelH = frame.size.height;
        
        self.ccpScrollView.delegate = self;

        
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 15;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        _titleLabe = [[UILabel alloc]initWithFrame:CGRectMake(30, (CGRectGetHeight(frame) - 20)/2, 40 , 20)];
        _titleLabe.textColor = [UIColor whiteColor];
        _titleLabe.text = @"任务：";
        _titleLabe.font = kFontWithSize(13);
        _titleLabe.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabe];
        
        self.clipsToBounds = YES;   /*保证文字不跑出视图*/
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - 80,0, 1, CGRectGetHeight(frame))];
        len.backgroundColor = [UIColor whiteColor];
        [self addSubview:len];
        
        _taskLabel = [[UILabel alloc] initWithFrame: CGRectMake(len.right + 8 , 0, CGRectGetWidth(frame) - 120, CGRectGetHeight(frame))];
        _taskLabel.textColor = [UIColor whiteColor];
        _taskLabel.textAlignment = NSTextAlignmentLeft;
        _taskLabel.font = kFontWithSize(13);
        [self addSubview:_taskLabel];
        
        _taskNumLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - 65, (CGRectGetHeight(frame) - 20)/2, 40 , 20)];
        _taskNumLab.textColor = [UIColor whiteColor];
        _taskNumLab.font = kFontWithSize(13);
        [self addSubview:_taskNumLab];
        
        UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - 30, (CGRectGetHeight(frame) - 26/2)/2 , 14/2, 26/2)];
        arrowImg.image = [UIImage imageNamed:@"arrows"];
        [self addSubview:arrowImg];
        
        UIButton *taskListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        taskListBtn.frame = CGRectMake(CGRectGetWidth(frame) - 60, 0, 60, CGRectGetHeight(frame));
        taskListBtn.backgroundColor = [UIColor clearColor];
        [taskListBtn addTarget:self action:@selector(taskListBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:taskListBtn];
        
    }
    return self;
}

//重写set方法 创建对应的label
- (void)setTitleArray:(NSArray *)titleArray {
    
    _titleArray = titleArray;
    _carryOutNmb = titleArray.count;
    
    if (titleArray == nil) {
        [self removeTimer];
        return;
    }
    
    if (titleArray.count == 1) {
        [self removeTimer];
    }
    NSMutableArray *objArray = [[NSMutableArray alloc] init];
//    id lastObj = [titleArray lastObject];
//    [objArray addObject:lastObj];
    [objArray addObjectsFromArray:titleArray];
    
    self.titleNewArray = objArray;
    
    //CGFloat contentW = 0;
    CGFloat contentH = self.labelH *objArray.count;
    
    self.ccpScrollView.contentSize = CGSizeMake(0, contentH);
    
    CGFloat labelW = self.ccpScrollView.frame.size.width;
    self.labelW = labelW;
    CGFloat labelH = self.ccpScrollView.frame.size.height;
    self.labelH = labelH;
    CGFloat labelX = 70;
    
    [self.ccpScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj removeFromSuperview];
    }];
    
    for (int i = 0; i < objArray.count; i++) {
        
        UILabel  *titleLabel = [[UILabel alloc] init];
        
        titleLabel.userInteractionEnabled = YES;
        
        titleLabel.tag = 100 + i;
        titleLabel.font = kFontWithSize(13);
        titleLabel.textColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheLabel:)];
        
        [titleLabel addGestureRecognizer:tap];
        
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        CGFloat labelY = i * labelH;
        
        titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        titleLabel.text = objArray[i];
        
        [self.ccpScrollView addSubview:titleLabel];
    }
}

#pragma mark ====== 任务滚动点击 =======
- (void)clickTheLabel:(UITapGestureRecognizer *)tap {
    
    NSInteger tag = tap.view.tag;
    if ([self.delegate respondsToSelector:@selector(gyChangeTextView:didTapedAtIndex:)]) {
        [self.delegate gyChangeTextView:self didTapedAtIndex:tag - 100];
    }
}
#pragma mark ====== 任务列表统计数量点击 =======
- (void)taskListBtnClick{
    if ([self.delegate respondsToSelector:@selector(taskListTapClcik)]) {
        [self.delegate taskListTapClcik];
    }
}
- (void)setIsCanScroll:(BOOL)isCanScroll {
    
    if (isCanScroll) {
        
        self.ccpScrollView.scrollEnabled = YES;
        
    } else {
        
        self.ccpScrollView.scrollEnabled = NO;
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    
    _titleColor = titleColor;
    
    for (UILabel *label in self.ccpScrollView.subviews) {
        
        label.textColor = titleColor;
    }
}

- (void)setTitleFont:(CGFloat )titleFont {
    
    _titleFont = titleFont;
    
    for (UILabel *label in self.ccpScrollView.subviews) {
        
        label.font = [UIFont systemFontOfSize: titleFont];;
    }
}

- (void)setBGColor:(UIColor *)BGColor {
    
    _BGColor = BGColor;
    
    self.backgroundColor = BGColor;
}

- (void)nextLabel {
    
    CGPoint oldPoint = self.ccpScrollView.contentOffset;
    oldPoint.y += self.ccpScrollView.frame.size.height;
    [self.ccpScrollView setContentOffset:oldPoint animated:YES];
}
//当滚动时调用scrollView的代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.ccpScrollView.contentOffset.y == self.ccpScrollView.frame.size.height*(self.titleArray.count )) {
        
        [self.ccpScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
// 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self removeTimer];
}
#pragma mark ====== 定时 =======

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //开启定时器
    [self addTimer];
}

- (void)addTimer{
    
    /*
     scheduledTimerWithTimeInterval:  滑动视图的时候timer会停止
     这个方法会默认把Timer以NSDefaultRunLoopMode添加到主Runloop上，而当你滑tableView的时候，就不是NSDefaultRunLoopMode了，这样，你的timer就会停了。
     self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextLabel) userInfo:nil repeats:YES];
     */
    
    self.timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(nextLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark ====== Setter =======
- (void)setCarryOutNum:(NSInteger)carryOutNum{
    _taskNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)carryOutNum,self.taskListArray.count];
}

- (UIScrollView *)ccpScrollView {
    
    if (_ccpScrollView == nil) {
        _ccpScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _ccpScrollView.showsHorizontalScrollIndicator = NO;
        _ccpScrollView.showsVerticalScrollIndicator = NO;
        _ccpScrollView.scrollEnabled = NO;
        _ccpScrollView.pagingEnabled = YES;
        [self addSubview:_ccpScrollView];
        
        [_ccpScrollView setContentOffset:CGPointMake(0 , self.labelH) animated:YES];
    }
    return _ccpScrollView;
}
#pragma mark ====== dealloc =======

- (void)dealloc {
    
    [self.timer invalidate];
    self.timer = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
