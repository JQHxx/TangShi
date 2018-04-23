//
//  TCFamilyBloodDetailViewController.h
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^FamilyBloodDetailBackBlock)();

@interface TCFamilyBloodDetailViewController : BaseViewController

@property (nonatomic,assign)NSInteger record_family_id;
@property (nonatomic, copy)FamilyBloodDetailBackBlock backBlock;

@end
