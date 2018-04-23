//
//  TCCommonNewsModel.h
//  TonzeCloud
//
//  Created by vision on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCommonNewsModel : NSObject

@property (nonatomic, copy )NSString *newsName;
@property (nonatomic, copy )NSString *newsImage;
@property (nonatomic,assign)NSInteger  newsIndex;
@property (nonatomic,assign)BOOL       hasNewMessages;

@end
