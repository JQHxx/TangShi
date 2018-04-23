//
//  TCReplyButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol linkReplyDelegate <NSObject>
@required

- (void)linkReply:(NSString *)linkContent;          //点击被标记区域

@end
@interface TCReplyButton : UIButton
@property (nonatomic,weak) id <linkReplyDelegate> delegate;

- (void)viewReplyDict:(NSDictionary *)dict;

+ (CGFloat)rowReplyForObject:(id)object;
@end
