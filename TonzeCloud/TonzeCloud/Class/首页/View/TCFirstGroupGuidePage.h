//
//  TCFriendGroupGuidePage.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^NextClickBlock)();


@interface TCFirstGroupGuidePage : UIView
///
@property (nonatomic, copy)  NextClickBlock nextClickBlock;

- (void)show;

@end


