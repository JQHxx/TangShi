//
//  TCArticleModel.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "id": 12,
 "name": "测试文章分类4",
 "article_id": "19,20,21,22",
 "add_time": "1489133877",
 "edit_time": "1489133877",
 "sort": "4",
 "is_used": "启动"
 "image_url" = "/uploads/big/20170220/efa5210565ba9007c73b1a11b30cf691.png";
 "reading_number" = 2;
 title = "\U4f60\U597d\U5417";
 "type_name" = "\U5206\U7c7b1";
 
 "id": 7,
 "title": "测试文章标题1",
 "datatime": "1489133934",
 "reading_number": "0",
 "content": "测试文章内容1",
 "is_used": "启动",
 "add_time": "1489133934",
 "edit_time": "1489133934",
 "classification_id": "9",
 "image_id": "",
 "classification_name": "测试文章分类1",
 "image_url": null
 */
#import <Foundation/Foundation.h>

@interface TCArticleModel : NSObject

@property (nonatomic,assign)NSInteger  id;
@property (nonatomic, copy )NSString  *title;
@property (nonatomic, copy )NSString  *add_time;
@property (nonatomic, assign)NSInteger reading_number;
@property (nonatomic, copy)NSString  *image_url;
@property (nonatomic, copy)NSString  *classification_id;

@property (nonatomic, copy )NSString  *edit_time;
@property (nonatomic, copy )NSString  *sort;
@property (nonatomic, copy )NSString  *is_used;
@property (nonatomic, copy)NSString  *datatime;
@property (nonatomic, copy)NSString  *content;
@property (nonatomic, copy)NSString  *image_id;
@property (nonatomic, copy)NSString  *classification_name;
@property (nonatomic, copy)NSString  *type_name;

@property (nonatomic ,copy)NSString  *l_url;
@property (nonatomic ,assign)NSInteger reading_num;

@end
