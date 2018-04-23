//
//  TCBirthdayViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBirthdayViewController.h"
#import "TCHeightViewController.h"
#import "TCUserTool.h"
#import "TCDatePickerView.h"
@interface TCBirthdayViewController ()<TCDatePickerViewDelegate>{
   
    UILabel *ageLabel;
    NSString *birthdayStr;
}
@end

@implementation TCBirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"年龄";
    
    NSString *yearStr =[[TCHelper sharedTCHelper] getLastYearDate:27];
    NSString *time =[yearStr substringToIndex:4];
    birthdayStr=[NSString stringWithFormat:@"%@-01-01",time];
    
    [self initAgeView];
}
#pragma mark --TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    birthdayStr = dateStr;
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthDay = [dateFormatter dateFromString:dateStr];
    //用来得到详细的时差
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *date = [calendar components:unitFlags fromDate:birthDay toDate:nowDate options:0];
    
    if([date year] >0){
        ageLabel.text=[NSString stringWithFormat:@"%ld岁",(long)[date year]];
    }
}
#pragma mark -- Event Response
#pragma mark -- 下一步
- (void)nextButton{
    [[TCUserTool sharedTCUserTool] insertValue:birthdayStr forKey:@"age"];
    TCHeightViewController *heightVC = [[TCHeightViewController alloc] init];
    [self.navigationController pushViewController:heightVC animated:YES];
}

#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initAgeView{
    UIImageView *birthdayImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2,kNewNavHeight+40, 80, 80)];
    birthdayImg.image = [UIImage imageNamed:@"ic_login_birthday"];
    [self.view addSubview:birthdayImg];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, birthdayImg.bottom+20, kScreenWidth, 30)];
    promptLabel.text = @"您的年龄？";
    promptLabel.font = [UIFont systemFontOfSize:20];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:promptLabel];
    
    ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, promptLabel.bottom+10, kScreenWidth, 20)];
    ageLabel.text = @"27";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.font = [UIFont boldSystemFontOfSize:20];
    ageLabel.textColor = [UIColor blackColor];
    [self.view addSubview:ageLabel];
    
    TCDatePickerView *datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, ageLabel.bottom, kScreenWidth, 200) ageValue:birthdayStr pickerAgeType:DatePickerViewTypeDate];
    datePickerView.pickerDelegate=self;
    [self.view addSubview:datePickerView];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, kScreenHeight-60, 150, 40)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    nextButton.backgroundColor = kbgBtnColor;
    [nextButton addTarget:self action:@selector(nextButton) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 5;
    
    [self.view addSubview:nextButton];

}
@end
