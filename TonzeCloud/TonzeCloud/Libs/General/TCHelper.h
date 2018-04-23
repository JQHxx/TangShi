//
//  TCHelper.h
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCHelper : NSObject

singleton_interface(TCHelper);

@property (nonatomic,strong)NSNumber  *stepCount;           //步数
@property (nonatomic,strong)NSNumber  *kilometer;           //公里数

@property (nonatomic,assign)NSInteger  expert_id;           //专家ID
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic, assign)NSInteger  dynamicTextNumber;  //动态限制字数

@property (nonatomic,assign)BOOL      isBloodReload;        //是否更新血糖数据
@property (nonatomic,assign)BOOL      isDietReload;         //是否更新饮食数据
@property (nonatomic,assign)BOOL      isHomeDietReload;     //是否更新首页饮食数据
@property (nonatomic,assign)BOOL      isSportsReload;       //是否更新运动数据
@property (nonatomic,assign)BOOL      isHomeSportsReload;   //是否更新首页运动数据
@property (nonatomic,assign)BOOL      isManagerRecordReload; //是否更新糖记录页面
@property (nonatomic,assign)BOOL      isRecordsReload;      //是否更新记录
@property (nonatomic,assign)BOOL      isSetDietTarget;      //设置目标摄入
@property (nonatomic,assign)BOOL      isLogin;              //登录或注册成功
@property (nonatomic,assign)BOOL      isHomeReload;         //是否更新首页
@property (nonatomic,assign)BOOL      isUserReload;         //是否更新用户信息
@property (nonatomic,assign)BOOL      isAddFood;            //添加食物
@property (nonatomic,assign)BOOL      isCancleCare;         //取消关注
@property (nonatomic,assign)BOOL      isHistoryDiet;        //是否从历史纪录页面进入
@property (nonatomic,assign)BOOL      isReloadMyService;    //是否更新我的服务
@property (nonatomic,assign)BOOL      isReloadMyServiceDetail;   //是否更新我的服务详情
@property (nonatomic,assign)BOOL      isBindingFriend;      //是否更新亲友列表
@property (nonatomic,assign)BOOL      isLoadStep;           //是否更新步数
@property (nonatomic,assign)BOOL      isLoadGlycosylated;   //是否更新糖化记录
@property (nonatomic,assign)BOOL      isIngralGoodsReload;  //是否刷新商品详情
@property (nonatomic,assign)BOOL      isRemindersLisReload; //是否刷新定时提醒列表
@property (nonatomic,assign)BOOL      isLoadBloodRecord;    //是否更新血压纪录
@property (nonatomic,assign)BOOL      isExaminationRecord;  //是否更新检查单纪录
@property (nonatomic,assign)BOOL      isFriendResquest;     //是否更新亲友列表
@property (nonatomic,assign)BOOL      isTaskListRecord;     // 是否更新积分任务列表
@property (nonatomic,assign)BOOL      isPersonalTaskListRecord; // 个人中心任务列表更新
@property (nonatomic,assign)BOOL      isIntegralMallRecord;   // 是否更新积分商城列表
@property (nonatomic,assign)BOOL      isNewDynamicRecord;    // 是否更新动态内容列表
@property (nonatomic,assign)BOOL      isSugarDetailBack;         // 是否血糖详情返回
@property (nonatomic, assign)BOOL     isFocusOnDynamicListReload; // 是否刷新关注人动态列表
///
@property (nonatomic, assign) BOOL     isLoadGPRSGlucoseMeterList;  // 是否刷新GPRS血糖仪列表
@property (nonatomic,assign)NSInteger  selIndex;           // 选择营养服务

@property (nonatomic,assign)BOOL      isHealthScore;        // 是否更新健康问答
@property (nonatomic,strong)NSArray   *healthList;          //健康资讯题库
@property (nonatomic,strong)NSArray   *healthResult;        //健康咨询结果库

@property (nonatomic,assign)BOOL      isDeleteDynamic;       //删除动态刷新
@property (nonatomic,assign)BOOL      isMaxDynamicReload;    //动态回复刷新
@property (nonatomic,assign)BOOL      isSearchKeyboard;      //搜索键盘是否弹出

@property (nonatomic,strong)NSArray   *sugarPeriodArr;      //血糖记录时间段
@property (nonatomic,strong)NSArray   *sugarPeriodEnArr;    //血糖记录时间段英文名
@property (nonatomic,strong)NSArray   *laborInstensityArr;  //劳动强度
@property (nonatomic,strong)NSArray   *relationshipArr;     //亲友关系
@property (nonatomic ,strong) NSArray *reminderTypeArr;     //定时提醒类型

@property (nonatomic,assign)BOOL      isShowAnnouce;        //是否显示公告

@property (nonatomic,assign)BOOL      isAddressManagerReload;//刷新地址列表
@property (nonatomic,assign)BOOL      isOrderListReload;     //刷新订单列表
@property (nonatomic,assign)BOOL      isAddressSelectedReload;  //选择收货地址地址刷新
@property (nonatomic,assign)BOOL      isOrderAddressReload;     //确认订单收货地址刷新

@property (nonatomic,assign)BOOL      isCartListReload;     //刷新购物车
@property (nonatomic,assign)BOOL      isPayOrderBack;       //支付订单返回

/*
 * @brief 不同时间段血糖值正常范围
 */
-(NSDictionary *)getNormalValueDictWithPeriodString:(NSString *)periodStr;

/*
 * @brief 不同血糖值范围内显示颜色
 */
-(UIColor *)getTextColorWithSugarValue:(double)value period:(NSString *)periodStr;

/*
* @bref 不同血糖值范围内显示背景图
*/
-(NSString *)getBgImageNameWithSugarValue:(double)value period:(NSString *)periodStr;

/**
 * @brief  血糖
 * 判断当前时间是在哪个时间段（返回时间段名称）
 */
-(NSString *)getInPeriodOfCurrentTime;

/**
 * @brief  血糖
 * 判断某一时间在哪个时间段 (血糖)
 */
-(NSString *)getInPeriodOfHour:(NSInteger )hour minute:(NSInteger)minute;

/**
 * @brief  血糖
 * 时间段（返回时间段英文名称）
 */
-(NSString *)getPeriodEnNameForPeriod:(NSString *)period;

/**
 * @brief  血糖
 * 时间段（返回时间段中文名称）
 */
-(NSString *)getPeriodChNameForPeriodEn:(NSString *)period;

/**
 * @brief  饮食
 * 判断当前时间是在哪个时间段（返回时间段名称）
 */
-(NSString *)getDietPeriodOfCurrentTime;

/**
 * @brief  饮食
 * 饮食时间段 中文转英文
 */
-(NSString *)getDietPeriodEnNameWithPeriod:(NSString *)period;

/**
 * @brief  饮食
 * 饮食时间段 英文转中文
 */
-(NSString *)getDietPeriodChNameWithPeriod:(NSString *)period;

/**
 * @brief  饮食
 * 饮食时间段 英文转中文  带时间
 */
-(NSString *)getDietPeriodChTimeNameWithPeriod:(NSString *)period;

/**
  @brief 今天往前一段时间 如一周 days＝7，一个月days＝30  三个月 days＝90
 */
-(NSMutableArray *)getDateFromTodayWithDays:(NSInteger)days;

/**
 @brief 某一时间段
 */
-(NSMutableArray *)getDateFromStartDate:(NSString *)startDate toEndDate:(NSString *)endDate format:(NSString *)format;

/**
 * @brief 获取最近一周的日期（月/日）（返回时间数组，如@[@"2/10",@"2/11",@"2/12",@"2/13",@"2/14",@"2/15",@"2/16"]）
 */
-(NSMutableArray *)getDateOfCurrentWeek;

/**
 *@bref 获取当前时间（年月日时分秒）
 */
-(NSString *)getCurrentDateTimeSecond;

/**
 *@bref 获取当前时间（年月日时分）
 */
-(NSString *)getCurrentDateTime;
/*
 *  @bref 获取当前时间多少分钟后（时分）
 *  minu  多少分钟后
*/
-(NSString *)getCurrentDateTimeMinutesLater:(NSUInteger)minu;
/**
 *@bref 获取当天日期（年月日）
 */
-(NSString *)getCurrentDate;
/**
 *@bref 将时间戳转换为 yyyy-MM-dd 格式
*   timeString  时间戳
 */
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString;
/**
 *@bref 获取days之前的日期(一周 6；20天 19)
 */
-(NSString *)getLastWeekDateWithDays:(NSInteger)days;

/**
 *@bref 将某个时间转化成 时间戳
 */
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format;

/**
 *@bref 将某个时间转化成 时间戳(毫秒)
 */
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime;

/**
 *@bref 订单倒计时
 */
- (NSTimeInterval)getOrderCountdownWithCreationTime:(NSString *)timeString;
/*
*   @bref 处理时间返回格式   (先将时间戳转换成所需要的格式)
*/
- (NSString *)dateToRequiredString:(NSString *)timeString;
/*
 *   @bref 处理禁言时间返回格式
 */
- (NSString *)dateGagtimeToRequiredString:(NSInteger)time;
/**
 *@bref 时间戳转化为时间
 */
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)format;

/**
 *@bref 时间戳转化为时间
 */
-(NSString *)timeSPToTime:(NSString *)sp;

/**
 *@bref 时间戳（毫秒）转化为时间
 */
-(NSString *)getDateTimeFromMilliSeconds:(long long) miliSeconds;


-(NSInteger)getTimeIntervalWithDate:(NSString *)aDateStr;

/*
 *@bref
 */
-(void)calculateTargetIntakeEnergyWithHeight:(NSInteger)height weight:(double)weight labor:(NSString *)laborIntensity;

/*
 *@bref 生成当天的某个点
 */
- (NSDate *)getCustomDate:(NSDate *)currentDate WithHour:(NSInteger)hour;
/***
 * @bref  比较两个日期的大小
 */
- (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate;
- (NSInteger)comSuderpareDate:(NSString*)aDate withDate:(NSString*)bDate;
/***
 * @bref  当前月份的开始和结束时间戳
 *  newDate  当前月份的某一天时间data
 */
- (NSString *)getMonthBeginAndEndWith:(NSDate *)newDate;
/***
 * @bref  获取年份时间
 */
-(NSString *)getLastYearDate:(NSInteger)page;
/***
 * @bref  限制emoji表情输入
 */
-(BOOL)strIsContainEmojiWithStr:(NSString*)str;
/***
 * @bref  限制第三方键盘（常用的是搜狗键盘）的表情
 */
- (BOOL)hasEmoji:(NSString*)string;
/***
 * @bref  判断当前是不是在使用九宫格输入
 */
-(BOOL)isNineKeyBoard:(NSString *)string;
/*
 * 获得积分任务名称
 */
- (NSString *)getTaskNameWithActionType:(NSInteger)actionType sumNum:(NSInteger)sumNum clickNum:(NSInteger)clickNum points:(NSInteger)points;
/*
 * 放大图片
 */
- (UIImage *)changeImageSizeWithCIImage:(CIImage *)ciImage andSize:(CGFloat)size;
/*
 * 点击事件埋点
 */
- (void)loginClick:(NSString *)target_id;
/*
 * 分享事件埋点
 */
- (void)loginShare:(NSInteger)target_id index:(NSInteger)share_way shareType:(NSInteger)target_type target_name:(NSString *)target_name;
/*
 * 行为事件埋点
 */
- (void)loginAction:(NSString *)target_id type:(NSInteger)type;

/*
 * 解析token
 */
-(NSString *)tokenToAccountId:(NSString *)token;

/*
 *登录保存数据
 */
-(void)loginInForSaveData;

/*
 *退出清除数据
 */
-(void)loginOutForClearData;
/*
 *浏览大图
 */
-(void)scanBigImageWithImageView:(UIImageView *)currentImageview;
/**
 *
 *  获取设备的唯一标示uuid
 */
- (NSString *)deviceUUID;
@end
