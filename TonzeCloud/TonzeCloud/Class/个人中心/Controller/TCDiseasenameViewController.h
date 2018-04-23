//
//  TCDiseasenameViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
@protocol DiseasenameDelegate
- (void)returnDiseasename:(NSArray *)filArray;
@end

@interface TCDiseasenameViewController : BaseViewController
@property (nonatomic, weak) id <DiseasenameDelegate> delegate;
@property (nonatomic, strong)NSMutableArray  *indexArray;


@end
