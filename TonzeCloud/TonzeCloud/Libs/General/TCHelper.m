//
//  TCHelper.m
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHelper.h"
#import "TCLocialNotificationManager.h"
#import <Hyphenate/Hyphenate.h>
#import "NSDate+Extension.h"

@implementation TCHelper
static CGRect oldframe;

singleton_implementation(TCHelper);

-(void)setIsLogin:(BOOL)isLogin{
    _isLogin=isLogin;
    if (isLogin) {
        self.isBloodReload=self.isDietReload=self.isSportsReload=self.isUserReload=self.isHomeReload=self.isManagerRecordReload=YES;
    }
}

-(void)setIsBloodReload:(BOOL)isBloodReload{
    _isBloodReload=isBloodReload;
    if (isBloodReload) {
        self.isRecordsReload=YES;
    }
}

-(void)setIsDietReload:(BOOL)isDietReload{
    _isDietReload=isDietReload;
    if (isDietReload) {
        self.isRecordsReload=YES;
    }
}
-(void)setIsHomeDietReload:(BOOL)isHomeDietReload{
    _isHomeDietReload=isHomeDietReload;
    if (isHomeDietReload) {
        self.isRecordsReload=YES;
    }
}
-(void)setIsSportsReload:(BOOL)isSportsReload{
    _isSportsReload=isSportsReload;
    if (isSportsReload) {
        self.isRecordsReload=YES;
    }
}
-(void)setIsHomeSportsReload:(BOOL)isHomeSportsReload{
    _isHomeSportsReload=isHomeSportsReload;
    if (isHomeSportsReload) {
        self.isRecordsReload=YES;
    }
}

#pragma mark 劳动强度
-(NSArray *)laborInstensityArr{
    return @[@{@"title":@"休息状态",@"content":@"卧床等"},
             @{@"title":@"轻体力劳动",@"content":@"办公室职员、教师等静态生活方式的人士"},
             @{@"title":@"中体力劳动",@"content":@"司机、家庭主妇等站着或走着工作的人士"},
             @{@"title":@"重体力劳动",@"content":@"建筑工人、林业工人、农民、运动员等以体力工作为主的人士"}];
}

#pragma mark 血糖记录时间段
-(NSArray *)sugarPeriodArr{
    return @[@"凌晨",@"早餐前",@"早餐后",@"午餐前",@"午餐后",@"晚餐前",@"晚餐后",@"睡前",@"随机"];
}
#pragma mark 亲友关系
-(NSArray *)relationshipArr{
    return @[@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"外公",@"外婆",@"岳父",@"岳母",@"老公",@"老婆",@"儿子",@"女儿",@"孙子",@"孙女",@"其他"];
}
#pragma mark 定时提醒类型
- (NSArray *)reminderTypeArr{
    return @[@"测量血糖",@"去运动",@"服药",@"注射胰岛素",@"量血压",@"其他"];
}

#pragma mark 血糖记录时间段英文名
-(NSArray *)sugarPeriodEnArr{
    return @[@"morning",@"beforeBreakfast",@"afterBreakfast",@"beforeLunch",@"afterLunch",@"beforeDinner",@"afterDinner",@"beforeSleep",@"random"];
}

#pragma mark 不同时间段血糖值正常范围
-(NSDictionary *)getNormalValueDictWithPeriodString:(NSString *)periodStr{
    NSArray *valuesArray=@[@{@"min":@4.5,@"max":@10},
                           @{@"min":@4.5,@"max":@7},
                           @{@"min":@4.5,@"max":@10},
                           @{@"min":@4.5,@"max":@7},
                           @{@"min":@4.5,@"max":@10},
                           @{@"min":@4.5,@"max":@7},
                           @{@"min":@4.5,@"max":@10},
                           @{@"min":@4.5,@"max":@10},
                           @{@"min":@4.5,@"max":@10}];
    NSArray *periodArray=[self sugarPeriodArr];
    NSInteger index=[periodArray indexOfObject:periodStr];
    return valuesArray[index];
}

#pragma mark 不同血糖值范围内显示颜色
-(UIColor *)getTextColorWithSugarValue:(double)value period:(NSString *)periodStr{
    NSDictionary *valueDict=[self getNormalValueDictWithPeriodString:periodStr];
    double minValue=[[valueDict valueForKey:@"min"] doubleValue];
    double maxValue=[[valueDict valueForKey:@"max"] doubleValue];
    
    NSArray *colorItems=[NSArray arrayWithObjects:[UIColor colorWithHexString:@"#fa6f6e"],
                         [UIColor colorWithHexString:@"#37deba"],
                         [UIColor colorWithHexString:@"#ffd03e"],nil];
    UIColor *color;
    if (value>maxValue) {
        color=colorItems[0];
    }else if (value<minValue){
        color=colorItems[2];
    }else{
        color=colorItems[1];
    }
    return color;
}

#pragma mark 不同血糖值范围内显示背景图
-(NSString *)getBgImageNameWithSugarValue:(double)value period:(NSString *)periodStr{
    NSDictionary *valueDict=[self getNormalValueDictWithPeriodString:periodStr];
    double minValue=[[valueDict valueForKey:@"min"] doubleValue];
    double maxValue=[[valueDict valueForKey:@"max"] doubleValue];
    
    NSArray *imageItems=[NSArray arrayWithObjects:@"img_xq_bg_01",@"img_xq_bg_02",@"img_xq_bg_03",nil];
    NSString *imgName;
    if (value>maxValue) {
        imgName=imageItems[2];
    }else if (value<minValue){
        imgName=imageItems[0];
    }else{
        imgName=imageItems[1];
    }
    return imgName;
}


#pragma mark 判断当前时间在哪个时间段 (血糖)
-(NSString *)getInPeriodOfCurrentTime{
    NSString *periodStr=nil;
    NSDate *currentDate = [NSDate date];
    if ([currentDate compare:[self getCustomDateWithHour:0]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:6]]==NSOrderedAscending){
        periodStr=@"凌晨";
    }else if ([currentDate compare:[self getCustomDateWithHour:6]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedAscending){
        periodStr=@"早餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:12]]==NSOrderedAscending){
        periodStr=@"早餐后";
    }else if ([currentDate compare:[self getCustomDateWithHour:12]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedAscending){
        periodStr=@"午餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedAscending){
        periodStr=@"午餐后";
    }else if ([currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:19]]==NSOrderedAscending){
        periodStr=@"晚餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:19]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:22]]==NSOrderedAscending){
        periodStr=@"晚餐后";
    }else{
        periodStr=@"睡前";
    }
    return periodStr;
}

#pragma mark 判断某一时间在哪个时间段 (血糖)
-(NSString *)getInPeriodOfHour:(NSInteger )hour minute:(NSInteger)minute{
    NSString *periodStr=nil;
    NSDate *currentDate = [self getCustomDateWithHour:hour minute:minute];
    if ([currentDate compare:[self getCustomDateWithHour:0]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:6]]==NSOrderedAscending){
        periodStr=@"凌晨";
    }else if ([currentDate compare:[self getCustomDateWithHour:6]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedAscending){
        periodStr=@"早餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:12]]==NSOrderedAscending){
        periodStr=@"早餐后";
    }else if (([currentDate compare:[self getCustomDateWithHour:12]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedAscending)){
        periodStr=@"午餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedAscending){
        periodStr=@"午餐后";
    }else if ([currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:19]]==NSOrderedAscending){
        periodStr=@"晚餐前";
    }else if ([currentDate compare:[self getCustomDateWithHour:19]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:22]]==NSOrderedAscending){
        periodStr=@"晚餐后";
    }else{
        periodStr=@"睡前";
    }
    return periodStr;
}

#pragma mark 时间段中文转英文名
-(NSString *)getPeriodEnNameForPeriod:(NSString *)period{
    NSString *periodEn=nil;
    if ([period isEqualToString:@"凌晨"]) {
        periodEn=@"morning";
    }else if ([period isEqualToString:@"早餐前"]){
        periodEn=@"beforeBreakfast";
    }else if ([period isEqualToString:@"早餐后"]){
        periodEn=@"afterBreakfast";
    }else if ([period isEqualToString:@"午餐前"]){
        periodEn=@"beforeLunch";
    }else if ([period isEqualToString:@"午餐后"]){
        periodEn=@"afterLunch";
    }else if ([period isEqualToString:@"晚餐前"]){
        periodEn=@"beforeDinner";
    }else if ([period isEqualToString:@"晚餐后"]){
        periodEn=@"afterDinner";
    }else if ([period isEqualToString:@"睡前"]){
        periodEn=@"beforeSleep";
    }else{
        periodEn=@"random";
    }
    return periodEn;
}

#pragma mark 时间段英文名转中文
-(NSString *)getPeriodChNameForPeriodEn:(NSString *)period{
    NSString *periodCh=nil;
    if ([period isEqualToString:@"morning"]) {
        periodCh=@"凌晨";
    }else if ([period isEqualToString:@"beforeBreakfast"]){
        periodCh=@"早餐前";
    }else if ([period isEqualToString:@"afterBreakfast"]){
        periodCh=@"早餐后";
    }else if ([period isEqualToString:@"beforeLunch"]){
        periodCh=@"午餐前";
    }else if ([period isEqualToString:@"afterLunch"]){
        periodCh=@"午餐后";
    }else if ([period isEqualToString:@"beforeDinner"]){
        periodCh=@"晚餐前";
    }else if ([period isEqualToString:@"afterDinner"]){
        periodCh=@"晚餐后";
    }else if([period isEqualToString:@"beforeSleep"]){
        periodCh=@"睡前";
    }else{
        periodCh=@"随机";
    }
    return periodCh;
}

#pragma mark 饮食 判断当前时间是在哪个时间段（返回时间段名称）
-(NSString *)getDietPeriodOfCurrentTime{
    NSString *periodStr=nil;
    NSDate *currentDate = [NSDate date];
    if ([currentDate compare:[self getCustomDateWithHour:0]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedAscending){
        periodStr=@"早餐（00:00-08:59）";
    }else if ([currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:11]]==NSOrderedAscending){
        periodStr=@"上午加餐（9:00-10:59）";
    }else if ([currentDate compare:[self getCustomDateWithHour:11]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedAscending){
        periodStr=@"午餐（11:00-13:59）";
    }else if ([currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedAscending){
        periodStr=@"下午加餐（14:00-16:59）";
    }else if ([currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:20]]==NSOrderedAscending){
        periodStr=@"晚餐（17:00-19:59）";
    }else{
        periodStr=@"晚上加餐（20:00-23:59）";
    }
    return periodStr;
}

#pragma mark 饮食时间段 中文转英文
-(NSString *)getDietPeriodEnNameWithPeriod:(NSString *)period{
    NSString *periodEn=nil;
    if ([period isEqualToString:@"早餐（00:00-08:59）"]) {
        periodEn=@"breakfast";
    }else if ([period isEqualToString:@"上午加餐（9:00-10:59）"]){
        periodEn=@"morningMeal";
    }else if ([period isEqualToString:@"午餐（11:00-13:59）"]){
        periodEn=@"lunch";
    }else if ([period isEqualToString:@"下午加餐（14:00-16:59）"]){
        periodEn=@"afternoonSnacks";
    }else if ([period isEqualToString:@"晚餐（17:00-19:59）"]){
        periodEn=@"dinner";
    }else if ([period isEqualToString:@"晚上加餐（20:00-23:59）"]){
        periodEn=@"supper";
    }else{
        periodEn=@"";
    }
    return periodEn;
}

#pragma mark 饮食时间段 英文文转中文
-(NSString *)getDietPeriodChNameWithPeriod:(NSString *)period{
    NSString *periodCh=nil;
    if ([period isEqualToString:@"breakfast"]) {
        periodCh=@"早餐";
    }else if ([period isEqualToString:@"morningMeal"]){
        periodCh=@"上午加餐";
    }else if ([period isEqualToString:@"lunch"]){
        periodCh=@"午餐";
    }else if ([period isEqualToString:@"afternoonSnacks"]){
        periodCh=@"下午加餐";
    }else if ([period isEqualToString:@"dinner"]){
        periodCh=@"晚餐";
    }else if ([period isEqualToString:@"supper"]){
        periodCh=@"晚上加餐";
    }else{
        periodCh=@"";
    }
    return periodCh;
}

#pragma mark 饮食时间段 英文文转中文2
-(NSString *)getDietPeriodChTimeNameWithPeriod:(NSString *)period{
    NSString *periodCh=nil;
    if ([period isEqualToString:@"breakfast"]) {
        periodCh=@"早餐（00:00-08:59）";
    }else if ([period isEqualToString:@"morningMeal"]){
        periodCh=@"上午加餐（9:00-10:59）";
    }else if ([period isEqualToString:@"lunch"]){
        periodCh=@"午餐（11:00-13:59）";
    }else if ([period isEqualToString:@"afternoonSnacks"]){
        periodCh=@"下午加餐（14:00-16:59）";
    }else if ([period isEqualToString:@"dinner"]){
        periodCh=@"晚餐（17:00-19:59）";
    }else if ([period isEqualToString:@"supper"]){
        periodCh=@"晚上加餐（20:00-23:59）";
    }else{
        periodCh=@"";
    }
    return periodCh;
}

#pragma mark 今天往前一段时间 如一周 days＝7，一个月days＝30
-(NSMutableArray *)getDateFromTodayWithDays:(NSInteger)days{
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    for (NSInteger i = days-1; i >=0; i --) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M/d"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    return dateArr;
}

#pragma mark 任意某时间段
-(NSMutableArray *)getDateFromStartDate:(NSString *)startDate toEndDate:(NSString *)endDate format:(NSString *)format{
    NSMutableArray *dateArr=[[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startD =[formatter dateFromString:startDate];
    NSDate *endD = [formatter dateFromString:endDate];
    
    NSTimeInterval time=[endD timeIntervalSinceDate:startD];
    NSInteger days=((NSInteger)time)/(3600*24);
    
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:endD];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *aDate=[calendar dateByAddingComponents:components toDate:endD options:0];
    for (NSInteger i=days; i>=0; i--) {
        [components setHour:-i*24];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *date=[calendar dateByAddingComponents:components toDate:aDate options:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:format];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        [dateArr addObject:dateStr];
        
    }
    return [NSMutableArray arrayWithArray:[[dateArr reverseObjectEnumerator] allObjects]];
}

#pragma mark 最近一周时间
-(NSMutableArray *)getDateOfCurrentWeek{
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 6; i >=0; i --) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M/d"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    return dateArr;
}

#pragma mark  获取当前时间（年月日时分秒）
-(NSString *)getCurrentDateTimeSecond{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

#pragma mark  获取当前时间（年月日时分）
-(NSString *)getCurrentDateTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
#pragma mark ====== 获取当前时间多少分钟后的时间 =======
- (NSString *)getCurrentDateTimeMinutesLater:(NSUInteger)minu{
    NSDate *dates = [NSDate date];
    NSTimeInterval interval = minu * 60;
    NSDate *detea = [NSDate dateWithTimeInterval:interval sinceDate:dates];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"BeiJing"];
    [dateformatter setTimeZone:timeZone];
    NSString *  locationString=[dateformatter stringFromDate:detea];
    return locationString;
}
#pragma mark 获取days之前的日期(一周 6；20天 19)
-(NSString *)getLastWeekDateWithDays:(NSInteger)days{
    NSTimeInterval secondsPerDay = -days * 24*60*60;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}

#pragma mark  获取当天日期（年月日）
-(NSString *)getCurrentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
#pragma mark  将时间戳转换为 yyyy-MM-dd格式
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    NSTimeInterval time=[timeString doubleValue]+28800;//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSLog(@"date:%@",[detaildate description]);
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
}
#pragma mark 将某个时间转化成 时间戳
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];    //将字符串按formatter转成nsdate
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];     //时间转时间戳的方法
    return timeSp;
}

#pragma mark 将某个时间转化成 时间戳
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}
#pragma mark ====== 订单倒计时 =======
- (NSTimeInterval)getOrderCountdownWithCreationTime:(NSString *)timeString{
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *data = [self timeWithTimeIntervalString:timeString format:@"yyyy-MM-dd HH:mm:ss"];
    // 截止时间date格式
    NSDate  *expireDate = [formater dateFromString:data];
    NSDate  *nowDate = [NSDate date];
    // 当前时间字符串格式
    NSString *nowDateStr = [formater stringFromDate:nowDate];
    // 当前时间date格式
    nowDate = [formater dateFromString:nowDateStr];
    NSTimeInterval maxTime = 120 * 60;
    NSTimeInterval timeInterval = maxTime - [nowDate timeIntervalSinceDate:expireDate];
    return timeInterval;
}
#pragma mark ====== 处理时间返回格式 =======
- (NSString *)dateToRequiredString:(NSString *)timeString
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    // 帖子的创建时间
    NSDate *create = [fmt dateFromString:timeString];
    
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                fmt.dateFormat = @"HH:mm";
                return [fmt stringFromDate:create];
            } else if (cmps.minute >= 1) { // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 1分钟 > 时间差距
                return @"刚刚";
            }
        } else if (create.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:create];
        } else { // 其他
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:create];
        }
    } else { // 非今年
        return timeString;
    }
}
#pragma mark -- 处理禁言时间返回格式
- (NSString *)dateGagtimeToRequiredString:(NSInteger)time{
    
    NSString *timeStr = nil;
    if (time<=60) {
        timeStr = @"1分钟";
    }else if (time<3600){
        timeStr =[NSString stringWithFormat:@"%ld",time/60];
    }else if (time<3600*24){
        NSInteger hour =time/3600;
        timeStr = [NSString stringWithFormat:@"%ld小时%ld分钟",hour,(time-hour*3600)/60];
    }else if (time>=3600*24){
        NSInteger day = time/(3600*24);
        NSInteger hour = (time - day*3600*24)/3600;
        NSInteger mine = (time - day*3600*24 - hour*3600)/60;
        timeStr = [NSString stringWithFormat:@"%ld天%ld小时%ld分钟",day,hour,mine];
    }
    return timeStr;
}
#pragma mark 时间戳转化为时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)format
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString integerValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}


#pragma mark 时间戳转化为时间
-(NSString *)timeSPToTime:(NSString *)sp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sp.floatValue/1000.0];
    return [formatter stringFromDate:date];
}

#pragma mark 时间戳（毫秒）转化为时间
-(NSString *)getDateTimeFromMilliSeconds:(long long) miliSeconds{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    
    NSDate *aDate=[NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [dateFormatter stringFromDate:aDate];
    
    return dateTime;
}

#pragma mark 与当前时间间隔
-(NSInteger)getTimeIntervalWithDate:(NSString *)aDateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timeDate = [dateFormatter dateFromString:aDateStr]
    ;
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:timeDate];
    NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];
    NSDate *nowDate = [[NSDate date]dateByAddingTimeInterval:interval];
    //两个时间间隔
    NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
    timeInterval = -timeInterval;
    return timeInterval/60;
}

#pragma mark 计算每日目标摄入
-(void)calculateTargetIntakeEnergyWithHeight:(NSInteger)height weight:(double)weight labor:(NSString *)laborIntensity{
    NSInteger calorie=0;
    double bmiValue=weight/(height/100)*(height/100);
    if (bmiValue>=24.0) {  //肥胖
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=70;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=90;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=120;
        }else{
            calorie=140;
        }
    }else if (bmiValue<18.5){ //偏瘦
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=110;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=140;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=160;
        }else{
            calorie=190;
        }
    }else{  //正常
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=90;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=120;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=140;
        }else{
            calorie=160;
        }
    }
    NSInteger normalWeight=height-105;
    NSInteger tempEnergy=normalWeight*calorie;  //KJ
    NSInteger intakeEnergy=tempEnergy*0.239+0.5;
    [NSUserDefaultsInfos putKey:@"targetDailyEnergy" andValue:[NSNumber numberWithInteger:intakeEnergy]];
}

#pragma mark -- private Methods
#pragma mark 生成当天的某个点
- (NSDate *)getCustomDateWithHour:(NSInteger)hour{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    return [self getCustomDate:currentDate WithHour:hour];
}

#pragma mark 生成某一天的某个点
-(NSDate *)getCustomDate:(NSDate *)currentDate WithHour:(NSInteger)hour{
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = nil;
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

-(NSDate *)getCustomDateWithHour:(NSInteger)hour minute:(NSInteger)minute{
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = nil;
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}
#pragma mark -- 比较两个日期大小
- (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateA = [dateFormatter dateFromString:aDate];
    NSDate *dateB = [dateFormatter dateFromString:bDate];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}
#pragma mark -- 比较两个日期大小
- (NSInteger)comSuderpareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dateA = [dateFormatter dateFromString:aDate];
    NSDate *dateB = [dateFormatter dateFromString:bDate];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}
#pragma mark ====== 当月的开始和结束“时间戳” =======
- (NSString *)getMonthBeginAndEndWith:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return nil;
    }
    NSString *beginString = [NSString stringWithFormat:@"%ld",(long)[beginDate timeIntervalSince1970]];
    NSString *endString = [NSString stringWithFormat:@"%ld",(long)[endDate timeIntervalSince1970]];
    NSString *timeStr = [NSString stringWithFormat:@"%@,%@",beginString,endString];
    return timeStr;
}

#pragma mark -- 获取年份时间（年月日）
-(NSString *)getLastYearDate:(NSInteger)page{
    NSTimeInterval secondsPerDay = -page* 24*60*60*365;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}
#pragma mark -- 限制emoji表情输入
-(BOOL)strIsContainEmojiWithStr:(NSString*)str{
    __block BOOL returnValue =NO;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         const unichar hs = [substring characterAtIndex:0];
         if(0xd800<= hs && hs <=0xdbff){
             if(substring.length>1){
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs -0xd800) *0x400) + (ls -0xdc00) +0x10000;
                 if(0x1d000<= uc && uc <=0x1f77f){
                     returnValue =YES;
                 }
             }
         }
         else if(substring.length>1){
             const unichar ls = [substring characterAtIndex:1];
             if(ls ==0x20e3)
             {
                 returnValue =YES;
             }
         }else{
             // non surrogate
             if(0x2100<= hs && hs <=0x27ff&& hs !=0x263b)
             {
                 returnValue =YES;
             }
             else if(0x2B05<= hs && hs <=0x2b07)
             {
                 returnValue =YES;
             }
             else if(0x2934<= hs && hs <=0x2935)
             {
                 returnValue =YES;
             }
             else if(0x3297<= hs && hs <=0x3299)
             {
                 returnValue =YES;
             }
             else if(hs ==0xa9|| hs ==0xae|| hs ==0x303d|| hs ==0x3030|| hs ==0x2b55|| hs ==0x2b1c|| hs ==0x2b1b|| hs ==0x2b50|| hs ==0x231a)
             {
                 returnValue =YES;
             }
         }
     }];
    return returnValue;
}
#pragma mark -- 限制第三方键盘（常用的是搜狗键盘）的表情
- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}
#pragma mark -- 判断当前是不是在使用九宫格输入
-(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}

#pragma mark ====== 获得任务名称 =======
- (NSString *)getTaskNameWithActionType:(NSInteger)actionType sumNum:(NSInteger)sumNum clickNum:(NSInteger)clickNum points:(NSInteger)points{
    NSString *taskNameStr;
    switch (actionType) {
        case 1:
        {
            taskNameStr = [NSString stringWithFormat:@"签到成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 2:
        {
            taskNameStr = [NSString stringWithFormat:@"完善资料成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 3:
        {
            taskNameStr = [NSString stringWithFormat:@"购买方案成功"];
        }break;
        case 4:
        {
            if (points == 50) {
                taskNameStr = [NSString stringWithFormat:@"首次使用糖士血糖仪"];
            }else{
                taskNameStr = [NSString stringWithFormat:@"血糖仪测量血糖（%ld/%ld）",clickNum,sumNum];
            }
        }break;
        case 5:
        {
            taskNameStr = [NSString stringWithFormat:@"血糖仪测量血糖成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 6:{
            taskNameStr = [NSString stringWithFormat:@"手动记录血糖成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 7:
        {
            taskNameStr = [NSString stringWithFormat:@"记录饮食成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 8:
        {
            taskNameStr = [NSString stringWithFormat:@"记录运动成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 9:
        {
            taskNameStr = [NSString stringWithFormat:@"记录血压成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 10:
        {
            taskNameStr = [NSString stringWithFormat:@"记录糖化血红蛋白成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 11:
        {
            taskNameStr = [NSString stringWithFormat:@"上传检查单成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 12:
        {
            taskNameStr = [NSString stringWithFormat:@"阅读文章成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 13:
        {
            taskNameStr = [NSString stringWithFormat:@"分享文章成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 14:
        {
            taskNameStr = [NSString stringWithFormat:@"添加亲友成功（%ld/%ld）",clickNum,sumNum];
        }break;
        case 15:
        {
            taskNameStr = [NSString stringWithFormat:@"提交意见反馈成功（%ld/%ld）",clickNum,sumNum];
        }break;
        default:
            break;
    }
    return taskNameStr;
}
#pragma mark -- 放大图片
- (UIImage *)changeImageSizeWithCIImage:(CIImage *)ciImage andSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *aImage=[UIImage imageWithCGImage:scaledImage];
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGImageRelease(scaledImage);
    
    return aImage;
}
#pragma mark -- 点击事件埋点
- (void)loginClick:(NSString *)target_id{
#if !DEBUG
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *phoneScreen = [NSString stringWithFormat:@"%.0f*%.0f",kScreenHeight*2,kScreenWidth*2];
    NSString *bodyclick = [NSString stringWithFormat:@"target_id=%@&sn=%@&phone_sn=%@&phone_version=iOS&phone_screen=%@",target_id,uuid,[UIDevice getSystemName],phoneScreen];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KUserClick body:bodyclick success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
#endif
}
#pragma mark -- 分享事件埋点
- (void)loginShare:(NSInteger)target_id index:(NSInteger)share_way shareType:(NSInteger)target_type target_name:(NSString *)target_name{
//#if !DEBUG
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *bodyclick = [NSString stringWithFormat:@"sn=%@&way=iPhone&request_platform=iOS&share_way=%ld&target_type=%ld&target_id=%ld&target_name=%@",uuid,share_way,target_type,(long)target_id,target_name];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KUserShare body:bodyclick success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
//#endif
}
#pragma mark -- 行为事件埋点
- (void)loginAction:(NSString *)target_id type:(NSInteger)type{
#if !DEBUG
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *bodyclick = [NSString stringWithFormat:@"target_id=%@&sn=%@&type=%ld",target_id,uuid,type];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KUserAction body:bodyclick success:^(id json) {
        MyLog(@"留存－－－－－－－－－－");

    } failure:^(NSString *errorStr) {
        
    }];
#endif
}

#pragma mark 登录保存数据
-(void)loginInForSaveData{
    
}

#pragma mark 退出清除数据
-(void)loginOutForClearData{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSecret];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kImUserName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNickName];
    
    [NSUserDefaultsInfos removeObjectForKey:kIMUsers];
    [NSUserDefaultsInfos removeObjectForKey:kIMOrderExperts];
    [NSUserDefaultsInfos removeObjectForKey:kImUserName];
    [NSUserDefaultsInfos removeObjectForKey:kImPassword];
    
    [NSUserDefaultsInfos putKey:@"targetDailyEnergy" andValue:@"0"];
    [NSUserDefaultsInfos putKey:@"kTargetStepCount" andValue:@"0"];
    
    
    [[EMClient sharedClient] logout:NO];   //退出环信
    
    [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
    [[TCLocialNotificationManager manager] cleanJPUSHLocationNotificationContent];// 清除推送消息提醒
}

#pragma mark
-(NSString *)tokenToAccountId:(NSString *)token{
    NSString *tempStr=[token base64Decoded];
    NSArray *arr = [tempStr componentsSeparatedByString:@"|"];
    return [arr objectAtIndex:0];
}
#pragma mark -- 浏览大图
-(void)scanBigImageWithImageView:(UIImageView *)currentImageview{
    //当前imageview的图片
    UIImage *image = currentImageview.image;
    //当前视图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

    oldframe = [currentImageview convertRect:currentImageview.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.3;
    //此时视图不会显示
    [backgroundView setAlpha:0];
    //将所展示的imageView重新绘制在Window中
    _imageView = [[UIImageView alloc] initWithFrame:oldframe];
    [_imageView setImage:image];
    [_imageView setTag:0];
    [backgroundView addSubview:_imageView];
    //将原始视图添加到背景视图中
    [window addSubview:backgroundView];
    
    
    //添加点击事件同样是类方法 -> 作用是再次点击回到初始大小
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [backgroundView addGestureRecognizer:tapGestureRecognizer];
    
    //动画放大所展示的ImageView
    
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat y,width,height;
        y = ([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width) * 0.5;
        //宽度为屏幕宽度
        width = [UIScreen mainScreen].bounds.size.width;
        //高度 根据图片宽高比设置
        height = image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width;
        [_imageView setFrame:CGRectMake(0, y, width, height)];
        //重要！ 将视图显示出来
        [backgroundView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  恢复imageView原始尺寸
 *
 *  @param tap 点击事件
 */
-(void)hideImageView:(UITapGestureRecognizer *)tap{
    UIView *backgroundView = tap.view;
    backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
    //原始imageview
    //恢复
    [UIView animateWithDuration:0.4 animations:^{
        [_imageView setFrame:oldframe];
    } completion:^(BOOL finished) {
        //完成后操作->将背景视图删掉
        [backgroundView removeFromSuperview];
    }];
}
/**
 *
 *  获取设备的唯一标示uuid
 */
- (NSString *)deviceUUID{

    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    return uuid;
}

@end
