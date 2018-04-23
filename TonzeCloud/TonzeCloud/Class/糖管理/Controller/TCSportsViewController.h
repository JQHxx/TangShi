//
//  TCSportsViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"


@protocol TCSportsViewControllerDelegate <NSObject>

-(void)sportsViewControllerDidSelectDict:(NSDictionary *)dict;


@end


@interface TCSportsViewController : BaseViewController


@property (nonatomic,assign)id<TCSportsViewControllerDelegate>controllerDelegate;

@end
