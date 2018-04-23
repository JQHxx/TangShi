//
//  TCMyResponseView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyDynamicModel.h"
#import "TCLookFoMyModel.h"

@protocol TCMyRespondDelegate <NSObject>
@optional

- (void)myRespondView;      //个人信息

@end
@interface TCMyResponseView : UIView

@property (nonatomic,weak) id <TCMyRespondDelegate> delegate;

- (void)myResponseModel:(TCMyDynamicModel *)model type:(NSInteger)type;

- (void)myLookForMyModel:(TCLookFoMyModel *)model;

@end
