//
//  TCDropmenuView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDropmenuView.h"

#define CCZROW_HEIGHT    35  //行高
#define CCZARROW_VHEIGHT 10 // 箭头垂直高度

NSTimeInterval const duration = 0.15; // 动画时长

typedef void(^indexHandle)(NSUInteger, NSString *);

@interface TCDropmenuView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *itemsArr;
@property (nonatomic, copy)   indexHandle handle;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, copy)   NSString *exceptItemName;
@property (nonatomic, assign) BOOL isMutableTable;
/// 记录每次点击的下标
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation TCDropmenuView
- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickBackground)];
        
        [self.backgroundView addGestureRecognizer:_tap];
    }
    return _tap;
}

- (CAShapeLayer *)arrowLayer {
    if (!_arrowLayer) {
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_arrowLayer];
    }
    
    return _arrowLayer;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _backgroundView.backgroundColor = [UIColor blackColor];
    }
    return _backgroundView;
}

#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _selectIndex = 0;
    _size = frame.size;
    self.offsetXOfArrow = 0;
    self.wannaToClickTempToDissmiss = YES;
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    
    [self tableButtonSetting];
    return self;
}

- (void)tableButtonSetting {
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CCZARROW_VHEIGHT, _size.width, _size.height - CCZARROW_VHEIGHT)];
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.bounces = NO;
    self.mainTableView.layer.cornerRadius = 5;
    self.mainTableView.clipsToBounds = YES;
    [self addSubview:self.mainTableView];
}

- (void)addItems:(NSArray<NSString *> *)itemsName {
    self.itemsArr = [NSMutableArray arrayWithArray:itemsName];
    self.isMutableTable = NO;
    
    [self updateTableAndFrame];
}

- (void)addItems:(NSArray<NSString *> *)itemsName exceptItem:(NSString *)itemName {
    
    self.itemsArr = [NSMutableArray arrayWithArray:itemsName];
    
    if ([itemsName containsObject:itemName]) {
        [self.itemsArr removeObject:itemName];
    }
    
    self.exceptItemName = itemName;
    self.isMutableTable = YES;
    
    [self updateTableAndFrame];
}

- (void)updateTableAndFrame {
    // 重新布局tableview
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, CCZROW_HEIGHT * self.itemsArr.count + CCZARROW_VHEIGHT);
    self.mainTableView.frame = CGRectMake(0, CCZARROW_VHEIGHT, _size.width, CCZROW_HEIGHT * self.itemsArr.count);
    [self.mainTableView reloadData];
    
    self.transform = CGAffineTransformMakeScale(0, 0);
}

- (void)selectedAtIndexHandle:(void (^)(NSUInteger, NSString *))indexHandle {
    if (indexHandle) {
        self.handle = indexHandle;
    }
}

- (void)didClickBackground {
    [self dismiss];
}

#pragma mark -- set

- (void)setOffsetXOfArrow:(CGFloat)offsetXOfArrow {
    _offsetXOfArrow = offsetXOfArrow;
    
    self.layer.anchorPoint = CGPointMake(0.5 + offsetXOfArrow / _size.width, 0);
    self.frame = CGRectMake(self.frame.origin.x + offsetXOfArrow, self.frame.origin.y, _size.width, self.frame.size.height);
    
    CGFloat l_ = CCZARROW_VHEIGHT / tan(M_PI / 3);
    CGPoint p1 = CGPointMake(_size.width / 2 + offsetXOfArrow, 0);
    CGPoint p2 = CGPointMake(p1.x - l_, p1.y + CCZARROW_VHEIGHT);
    CGPoint p3 = CGPointMake(p1.x + l_, p1.y + CCZARROW_VHEIGHT);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    
    self.arrowLayer.path = path.CGPath;
}

- (void)setWannaToClickTempToDissmiss:(BOOL)wannaToClickTempToDissmiss {
    _wannaToClickTempToDissmiss = wannaToClickTempToDissmiss;
    
    if (_wannaToClickTempToDissmiss && !self.tap) {
        [self.backgroundView addGestureRecognizer:self.tap];
    }
    if (!_wannaToClickTempToDissmiss && self.tap) {
        [self.backgroundView removeGestureRecognizer:self.tap];
    }
}


#pragma mark -- tag

- (void)show {
    
    [_mainTableView reloadData];
    
    NSEnumerator *windowEnnumtor = [UIApplication sharedApplication].windows.reverseObjectEnumerator;
    for (UIWindow *window in windowEnnumtor) {
        BOOL isOnMainScreen = window.screen == [UIScreen mainScreen];
        BOOL isVisible      = !window.hidden && window.alpha > 0;
        BOOL isLevelNormal  = window.windowLevel == UIWindowLevelNormal;
        
        if (isOnMainScreen && isVisible && isLevelNormal) {
            [window addSubview:self.backgroundView];
            [window addSubview:self];
            [self showAnimation];
        }
    }
}

- (void)dismiss {
    [self dismissAnimation];
}

- (void)showAnimation {
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.alpha = 0.4;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)dismissAnimation {
    
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
}

#pragma mark -- UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = @"ccz_cell_id";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
    cell.textLabel.text = self.itemsArr[indexPath.row];
    cell.textLabel.font = kFontWithSize(14);
    if (indexPath.row == _selectIndex) {
        cell.textLabel.textColor = kSystemColor;
    }else{
        cell.textLabel.textColor = UIColorFromRGB(0x313131);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CCZROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectIndex = indexPath.row;
    
    if (self.handle) {
        self.handle(indexPath.row, self.itemsArr[indexPath.row]);
    }
    
    if (self.isMutableTable) {
        NSString *selString = self.itemsArr[indexPath.row];
        [self.itemsArr removeObjectAtIndex:indexPath.row];
        [self.itemsArr insertObject:self.exceptItemName atIndex:indexPath.row];
        self.exceptItemName = selString;
        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self dismiss];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
