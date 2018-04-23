//
//  TCRiceModel.h
//  TonzeCloud
//
//  Created by vision on 17/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCRiceModel : NSObject

@property (nonatomic, copy )NSString  *riceName;
@property (nonatomic, copy )NSString  *riceImage;
@property (nonatomic, copy )NSString  *lowSugarPercent;  //降糖比
@property (nonatomic,assign)NSInteger  riceId;
@property (nonatomic,assign)BOOL      isSelected;

@end
