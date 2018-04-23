//
//  DownListMenu.h
//  TangShiService
//
//  Created by vision on 17/7/18.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^backUpCoverBlock) (void);


@protocol DownListMenuDelegate  <NSObject>

-(void)downListMenuDidSelectedMenu:(NSInteger )index;

@end

@interface DownListMenu : UIView

@property (nonatomic,weak)id<DownListMenuDelegate>viewDelegate;
@property (nonatomic,strong)NSMutableArray  *menuArray;
@property (nonatomic, copy )backUpCoverBlock backUpCoverBlock;

-(void)downListMenuShow;

-(void)backUpCoverAction;

@end
