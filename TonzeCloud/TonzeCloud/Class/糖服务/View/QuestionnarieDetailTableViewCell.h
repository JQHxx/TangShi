//
//  QuestionnarieDetailTableViewCell.h
//  TangShiService
//
//  Created by 肖栋 on 17/12/15.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionnarieDetailTableViewCell : UITableViewCell

@property (nonatomic ,strong)UITextField *textField;

@property (nonatomic ,strong)UITextView *textView;

- (void)questionnarieDetailData:(NSDictionary *)dict indexPath:(NSInteger)row section:(NSInteger)section;

@end
