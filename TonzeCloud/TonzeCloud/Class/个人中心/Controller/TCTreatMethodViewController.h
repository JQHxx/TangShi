//
//  TCTreatMethodViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
@protocol TreatMethodDelegate
- (void)returnName:(NSArray *)filArray;
@end

@interface TCTreatMethodViewController : BaseViewController
@property (nonatomic, weak) id <TreatMethodDelegate> delegate;
@property (nonatomic, strong)NSMutableArray  *imageArray;
@end
