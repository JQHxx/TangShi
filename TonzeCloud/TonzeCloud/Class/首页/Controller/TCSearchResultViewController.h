//
//  TCSearchResultViewController.h
//  TonzeCloud
//
//  Created by vision on 17/3/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSearchViewController.h"


@protocol TCSearchResultViewControllerDelegate <NSObject>

//选择数据
-(void)searchResultViewControllerDidSelectModel:(id )model withType:(SearchType )searchType;
//滑动
-(void)searchResultViewControllerBeginDraggingAction;
//确定
-(void)searchResultViewControllerConfirmAction;

@end

@interface TCSearchResultViewController : UIViewController

@property (nonatomic,weak)id<TCSearchResultViewControllerDelegate>controllerDelegate;

@property (nonatomic,assign)SearchType type;
@property (nonatomic, copy )NSString   *keyword;

@end
