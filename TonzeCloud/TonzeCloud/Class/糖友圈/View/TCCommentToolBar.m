//
//  TCCommentToolBar.m
//  TonzeCloud
//
//  Created by vision on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCommentToolBar.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseEmotionManager.h"
#import "EaseLocalDefine.h"

@interface TCCommentToolBar ()<UITextViewDelegate,EMFaceDelegate>

@property (strong, nonatomic) UIView    *toolbarView;
@property (strong, nonatomic) UIButton  *faceButton;

@property (nonatomic, assign) CGFloat inputViewMaxHeight;
@property (nonatomic, assign) CGFloat inputViewMinHeight;

@property (nonatomic) CGFloat previousTextViewContentHeight;//上一次inputTextView的contentSize.height

@property (strong, nonatomic) UIView *activityButtomView;

@end



@implementation TCCommentToolBar

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        self.inputViewMinHeight=36;
        self.inputViewMaxHeight=150;
        _activityButtomView = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UIImageView  *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundImageView.backgroundColor = [UIColor clearColor];
        backgroundImageView.image = [[UIImage imageNamed:@"EaseUIResource.bundle/messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
        [self addSubview:backgroundImageView];
        
        _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
        _toolbarView.backgroundColor = [UIColor clearColor];
        [self addSubview:_toolbarView];
        
        //input textview
        _inputTextView = [[EaseTextView alloc] initWithFrame:CGRectMake(8, 5, self.width -60, self.height -10)];
        _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _inputTextView.scrollEnabled = YES;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _inputTextView.delegate = self;
        _inputTextView.backgroundColor = [UIColor clearColor];
        _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _inputTextView.layer.borderWidth = 0.65f;
        _inputTextView.layer.cornerRadius = 6.0f;
        _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];
        [_toolbarView addSubview:_inputTextView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(_inputTextView.right+8, _inputTextView.top+5, kScreenWidth-_inputTextView.right-13, 0)];
        _textLabel.textColor = [UIColor redColor];
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.numberOfLines = 0;
        [_toolbarView addSubview:_textLabel];
        _textLabel.hidden = YES;
        
        //emoji
        self.faceButton = [[UIButton alloc] initWithFrame:CGRectMake(_inputTextView.right+8, 5, 36, 36)];
        self.faceButton.accessibilityIdentifier = @"face";
        self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.faceButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_face"] forState:UIControlStateNormal];
        [self.faceButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_faceSelected"] forState:UIControlStateHighlighted];
        [self.faceButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_keyboard"] forState:UIControlStateSelected];
        [self.faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:self.faceButton];
        
        [_toolbarView addSubview:self.faceView];
        [self setUpEmotions];
    }
    return self;
    
}

-(void)setUpEmotions{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *emotion = [emotions objectAtIndex:0];
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
    [self.faceView setEmotionManagers:@[manager]];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _delegate=nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

#pragma mark -- Event Response
#pragma mark 选择表情
- (void)faceButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        if ([_delegate respondsToSelector:@selector(didface)]) {
            [_delegate didface];
        }
        [self.inputTextView resignFirstResponder];
        [self willShowBottomView:self.faceView];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.inputTextView.hidden = !button.selected;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

#pragma mark -- getters
- (EaseFaceView *)faceView
{
    if (_faceView == nil) {
        _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame), self.frame.size.width, 180)];
        [(EaseFaceView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _faceView;
}

#pragma mark -- Private Methods
#pragma mark 获取textView的高度(实际为textView的contentSize的高度)
- (CGFloat)getTextViewContentH:(UITextView *)textView{
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}

#pragma mark 通过传入的toHeight，跳转toolBar的高度
- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < self.inputViewMinHeight) {
        toHeight = self.inputViewMinHeight;
    }
    if (toHeight > self.inputViewMaxHeight) {
        toHeight = self.inputViewMaxHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight){
        return;
    }else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        _previousTextViewContentHeight = toHeight;
    }
}


#pragma mark 调整toolBar的高度
- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    self.frame = toFrame;
}

#pragma mark 切换菜单视图
- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

#pragma mark 显示键盘
- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height){
        [self willShowBottomHeight:0];
        
    }else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

#pragma mark 隐藏键盘
-(void)willHiddenKeyboard{
    [self willShowBottomHeight:0];
    
    if (self.activityButtomView) {
        [self.activityButtomView removeFromSuperview];
    }
    self.activityButtomView = nil;

    [self.inputTextView resignFirstResponder];
    [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
}

#pragma mark --EMFaceDelegate
#pragma mark 点击表情键盘的发送回调
- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        //转义回来
        NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.inputTextView.attributedText.string];
        
        [_inputTextView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                  inRange:NSMakeRange(0, self.inputTextView.attributedText.length)
                                                  options:NSAttributedStringEnumerationReverse
                                               usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if (value) {
                 EMTextAttachment* attachment = (EMTextAttachment*)value;
                 NSString *str = [NSString stringWithFormat:@"%@",attachment.imageName];
                 [attStr replaceCharactersInRange:range withString:str];
             }
         }];

        if (attStr.length<=200) {
            if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
                if (![_inputTextView.text isEqualToString:@""]) {
                    [self.delegate didSendText:attStr];
                    [self willHiddenKeyboard];
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(didMoreSendText)]) {
                    [self.delegate didMoreSendText];
            }
        }
    }
}

#pragma mark 输入表情键盘的默认表情，或者点击删除按钮
-(void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete{
    NSString *chatText = self.inputTextView.text;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputTextView.attributedText];
    if (!isDelete && str.length > 0) {
        NSRange range = [self.inputTextView selectedRange];
        [attr insertAttributedString:[[EaseEmotionEscape sharedInstance] attStringFromTextForInputView:str textFont:self.inputTextView.font] atIndex:range.location];
        self.inputTextView.attributedText = attr;
    } else {
        if (chatText.length > 0) {
            NSInteger length = 1;
            if (chatText.length >= 2) {
                NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                if ([EaseEmoji stringContainsEmoji:subStr]) {
                    length = 2;
                }
            }
            self.inputTextView.attributedText = [self backspaceText:attr length:length];
        }
    }
    [self textViewDidChange:self.inputTextView];
}


-(void)sendFaceWithEmotion:(EaseEmotion *)emotion{
    
}

/*!
 @method
 @brief 删除文本光标前长度为length的字符串
 @discussion
 @param attr   待修改的富文本
 @param length 字符串长度
 @result   修改后的富文本
 */
-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
        if ([text isEqualToString:@"\n"]) {
            if ([self.delegate respondsToSelector:@selector(SendErrorText)]) {
                [self.delegate SendErrorText];
                [self willHiddenKeyboard];
            }
            return NO;
        }

    }
    if (textView.text.length<=200) {
        if ([text isEqualToString:@"\n"]) {
            if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
                [self.delegate didSendText:textView.text];
                [self willHiddenKeyboard];
            }
            return NO;
        }
    } else {
        if ([text isEqualToString:@"\n"]) {
            if ([self.delegate respondsToSelector:@selector(didMoreSendText)]) {
                [self.delegate didMoreSendText];
            }
            return NO;
        }
    }
       return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
    if (textView.text.length>=190&&textView.text.length<=200) {
        _textLabel.hidden = NO;
        _textLabel.text = [NSString stringWithFormat:@"%ld",200-textView.text.length];
        CGSize size = [_textLabel.text sizeWithLabelWidth:kScreenWidth-_inputTextView.right-13 font:[UIFont systemFontOfSize:13]];
        _textLabel.frame =CGRectMake(_inputTextView.right+8, _inputTextView.top+5, kScreenWidth-_inputTextView.right-13,size.height);
    }else if (textView.text.length>200){
        _textLabel.hidden = NO;
        _textLabel.text = [NSString stringWithFormat:@"超出%ld",textView.text.length-200];
        CGSize size = [_textLabel.text sizeWithLabelWidth:kScreenWidth-_inputTextView.right-13 font:[UIFont systemFontOfSize:13]];
        _textLabel.frame =CGRectMake(_inputTextView.right+8, _inputTextView.top+5, kScreenWidth-_inputTextView.right-13,size.height);
    }else{
        _textLabel.hidden = YES;
    }
}


#pragma mark - UIKeyboardNotification
- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}


@end
