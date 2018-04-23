//
//  TCBlankView.h
//  TonzeCloud
//
//  Created by vision on 17/3/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCBlankView : UIView
/// 提示文字
@property (nonatomic ,strong) NSString *tipStr;

-(instancetype)initWithFrame:(CGRect)frame img:(NSString *)imgName text:(NSString *)text;

-(instancetype)initWithFrame:(CGRect)frame Searchimg:(NSString *)imgName text:(NSString *)text;

- (instancetype)initWithFrame:(CGRect)frame unOrderImg:(NSString *)imgName tipText:(NSString *)tipText  chooseText:(NSString *)chooseText;

@end
