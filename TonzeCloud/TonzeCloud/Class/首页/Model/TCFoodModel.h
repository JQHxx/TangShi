//
//  TCFoodModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//


/*
 "id": 1,
 "name": "红米",
 "cat_id": "1",
 "brief": null,
 "display": 1,
 "adaptive_disorder_id": null,
 "effect_id": null,
 "efficacy_description": null,
 "food_suggestion": null,
 "orther_name": "红糯米、胭脂米",
 "flavor": "味甘、性温",
 "channel_tropism": "归脾、胃经",
 "nutrient_component": null,
 "department": 100,
 "protein": 8,
 "cholesterol": 0,
 "retinol": 0,
 "vitaminC": 0,
 "vitaminEOE": 0,
 "sodium": 4,
 "selenium": 3,
 "moisture": 14,
 "fat": 2,
 "ash": 1,
 "thiamine": 0,
 "vitaminE": 1,
 "calcium": 13,
 "magnesium": 16,
 "copper": 0,
 "energykcal": 346,
 "carbohydrate": 75,
 "totalvitamin": 0,
 "riboflavin": 0,
 "vitaminEAE": 1,
 "phosphorus": 183,
 "iron": 4,
 "manganese": 2,
 "energykj": 1448,
 "insolublefiber": 1,
 "carotene": 0,
 "niacin": 4,
 "vitaminEBYE": 0,
 "potassium": 219,
 "zinc": 2,
 "remark": null,
 "dietotherapy": "补气养阴、清热凉血、保护血管，防治血管动脉粥样硬化",
 "select_skills": "挑选红米时，以外观饱满、完整、带有光泽、无虫蛀、无破碎现象为佳。",
 "storage_environment": "红米要保存在通风、阴凉处。如果选购袋装密封红米，可直接放通风处即可。散装红米需要放入保鲜袋或不锈钢容器内，密封后置于阴冷通风处保存。",
 "supplier_id": null,
 "add_time": "1489477942",
 "edit_time": "1489477942",
 "classic_source": "",
 "ingredient_code": "01-2-304",
 "iodine": "",
 "gi": null,
 "gl": "",
 "images": [ ]
 }
 */
#import <Foundation/Foundation.h>

@interface TCFoodModel : NSObject


@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *storage_environment;

@property (nonatomic, assign) NSInteger niacin;

@property (nonatomic, assign) NSInteger phosphorus;

@property (nonatomic, assign) NSInteger insolublefiber;

@property (nonatomic, copy) NSString *cat_name;

@property (nonatomic, assign) NSInteger thiamine;

@property (nonatomic, assign) NSInteger riboflavin;

@property (nonatomic, assign) NSInteger calcium;

@property (nonatomic, strong) NSArray *supplier_id;

@property (nonatomic, assign) NSInteger department;

@property (nonatomic, assign) NSInteger carotene;

@property (nonatomic, assign) NSInteger totalvitamin;

@property (nonatomic, strong) NSArray *effect_name;

@property (nonatomic, copy) NSString *flavor;

@property (nonatomic, strong) NSArray *supplier_name;

@property (nonatomic, assign) NSInteger manganese;

@property (nonatomic, strong) NSArray *effect_id;

@property (nonatomic, assign) NSInteger vitaminEOE;

@property (nonatomic, assign) NSInteger vitaminEAE;

@property (nonatomic, assign) NSInteger energykj;

@property (nonatomic, copy) NSString *cat_id;

@property (nonatomic, strong) NSArray *adaptive_disorder_id;

@property (nonatomic, assign) NSInteger display;

@property (nonatomic, assign) NSInteger ash;

@property (nonatomic, assign) NSInteger protein;

@property (nonatomic, copy) NSString *orther_name;

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger selenium;

@property (nonatomic, assign) NSInteger energykcal;

@property (nonatomic, copy) NSString *select_skills;

@property (nonatomic, copy) NSString *brief;

@property (nonatomic, assign) NSInteger vitaminEBYE;

@property (nonatomic, copy) NSString *nutrient_component;

@property (nonatomic, copy) NSString *channel_tropism;

@property (nonatomic, assign) NSInteger moisture;

@property (nonatomic, assign) NSInteger fat;

@property (nonatomic, copy) NSString *remark;

@property (nonatomic, assign) NSInteger zinc;

@property (nonatomic, strong) NSArray *efficacy_description;

@property (nonatomic, assign) NSInteger sodium;

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *classic_source;

@property (nonatomic, assign) NSInteger cholesterol;

@property (nonatomic, assign) NSInteger vitaminC;

@property (nonatomic, strong) NSArray *adaptive_disorder_name;

@property (nonatomic, assign) NSInteger vitaminE;

@property (nonatomic, assign) NSInteger copper;

@property (nonatomic, assign) NSInteger retinol;

@property (nonatomic, assign) NSInteger magnesium;

@property (nonatomic, assign) NSInteger iodine;

@property (nonatomic, assign) NSInteger carbohydrate;

@property (nonatomic, assign) NSInteger potassium;

@property (nonatomic, copy) NSString *dietotherapy;

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) NSInteger iron;

@property (nonatomic, copy) NSString *food_suggestion;

@property (nonatomic, copy) NSString *gi;
@property (nonatomic, copy) NSString *gl;

@end
