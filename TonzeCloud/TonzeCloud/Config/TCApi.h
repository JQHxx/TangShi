//
//  TCApi.h
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#ifndef TCApi_h
#define TCApi_h


#endif /*TCApi_h*/

/********************** app环境 ****************************/
#pragma mark - app环境，0开发或1发布


#define isTrueEnvironment 1
#if isTrueEnvironment
// 正式环境
#define kHostURL             @"http://api.360tj.com/%@"      //正式
#define kHostShopURL         @"http://www.360tj.com/%@"      //商城正式环境

#define kShareUrl            @"http://ht.360tj.com:8081"
#define kWebUrl              @"http://ht.360tj.com:8081/article/article.html"

#define kArticleWebUrl       @"http://api.360tj.com/article/"
#define kNewsWebUrl          @"http://ht.360tj.com:8081/System/system.html"

#else
// 测试环境
#define kHostURL             @"http://api-ts-t.360tj.com/%@"      //测试
#define kHostShopURL         @"http://m-t.360tj.com/%@"           //商城测试环境
//#define kHostURL           @"http://172.16.0.108:82/%@"         //程荣禄（测试）
//#define kHostURL           @"http://172.16.0.78/%@"             //叶剑武（测试）
#define kArticleWebUrl       @"http://api-ts-t.360tj.com/article/"
#define kShareUrl            @"http://wm-ts-t.360tj.com"
#define kWebUrl              @"http://wm-ts-t.360tj.com/article/article.html"
#define kNewsWebUrl          @"http://wm-ts-t.360tj.com/System/system.html"

#endif

/****外部链接地址***/
#define kSugarDeviceUrl     @"https://item.taobao.com/item.htm?spm=a1z10.5-c-s.w4002-17108875196.18.7df28661KgdtQW&id=552955754698"
#define kSugarPaperUrl      @"https://item.taobao.com/item.htm?spm=a1z10.5-c-s.w4002-17108875196.15.7df28661KgdtQW&id=553346493310"

#define kUploadAppInfo      @"webapp/Common/add"     //上传app设备数据

//用户模块
#define kLoginAPI           @"webapp/User/login"             //用户登录
#define kRegisterAPI        @"webapp/User/register"          //用户注册
#define kGetTokenAPI        @"webapp/User/getToken"          //刷新用户凭证
#define kSendSign           @"webapp/User/sendSms"           //发送手机验证码
#define kSendCaptchaAPI     @"user/sendCaptcha"
#define kUserSummaryAPI     @"user/summary"
#define kForgetPassword     @"webapp/User/forget"            //忘记密码
#define kUpdatePassword     @"webapp/User/reset"             //重设密码
#define kLoginOutAPI        @"webapp/User/loginOut"          //用户登出
#define kChangePassWord     @"webapp/User/setPassword"       //修改密码
#define KCheckCode          @"webapp/User/checkCode"         //修改密码验证码
#define kChangeNickName     @"webapp/User/setNickname"       //修改昵称
#define kAddMineInformation @"webapp/User/setUserinfo"       //获取／添加／修改个人信息
#define kChangeHeadImage    @"webapp/User/upPhoto"           //修改头像
#define kUserUploadPhoto    @"webapp/User/upPhoto"           //上传图像
#define kGetUserInfo        @"webapp/User/getUserinfo"       //更新用户信息
#define kRegisterInvite     @"webapp/Inviteindex/updateInviteRecord_new" //注册成功回调（糖友邀请）
#define kChannelCallBack    @"webapp/Common/channel_callback"        //51壁纸回调
#define kError_report       @"webapp/Common/error_report"            //错误上报

//首页
#define kBannarStatistics      @"webapp/Statisticsclickcountindex/add"            //统计bannar
#define kAdIndexUrl            @"v2_2/Ad/index"                                   //运营位
#define kHomeIndex             @"v2_3/Index/index"                                //首页相关数据
#define kFoodCategory          @"webapp/Foodmaterialindex/lists_ingredientcat"    //食材库
#define kFoodList              @"webapp/Foodmaterialindex/lists_ingredient"       //食材分类列表
#define kFoodDetail            @"webapp/Foodmaterialindex/read"                   //食材详情
#define kArticleCategory       @"webapp/Articleclassificationindex/lists"         //文章分类
#define kArticleList           @"webapp/Articlemanagementindex/lists"             //文章列表
#define kRecommandArticleList  @"webapp/Articlemanagementindex/recArticle"        //推荐文章列表
#define kMyCommentList         @"webapp/articlemanagementindex/commentLists"      //我评论的列表
#define kCommentMineList       @"webapp/articlemanagementindex/commentedLists"    //评论我的列表
#define kDetailArticleList     @"webapp/Articlemanagementindex/rec_read"          //文章详情推荐文章
#define kArticleCommentList    @"webapp/articlemanagementindex/articleCommentLists"  //文章详情评论列表
#define kHotKeyword            @"webapp/Hotkeywordindex/read"                     //搜索热门关键词
#define kEverydayMenu          @"webapp/Cook/index"                               //每日菜谱
#define kGetHomeNews           @"webapp/Messageindex/getMessageIndex"             //最新系统消息和亲友血糖
#define kSystemNewsList        @"webapp/Messageindex/lists"                       //系统消息列表
#define kDeleteSystemNews      @"webapp/Messageindex/delete"                      //删除系统消息
#define kFamilyBloodNewsList   @"webapp/User/getFamilyRecordLists"                //亲友血糖消息
#define kDeleteFamilyNews      @"webapp/User/delFamilyRecordInfo"                 //删除亲友血糖消息
#define kFamilyNewsDetail      @"webapp/User/getFamilyRecordInfo"                 //亲友血糖消息详情
#define kMessageUnread         @"webapp/User/theRedPoi"                           //亲友数据／申请好友／首页
#define kAssessindexList       @"webapp/Assessindex/lists"                        //健康自测列表
#define kAssessindexRead       @"webapp/Assessindex/read"                         //健康自测答题详情
#define kAssessindexAdd_record    @"webapp/Assessindex/add_record"                //健康自测答题提交
#define kColumnDtailList       @"webapp/special_column/read"                      //专栏详情


#define articlemanagement      @"webapp/Articlemanagementindex/articlemanagement_collection"    //文章收藏／取消收藏
#define kArticleCollection     @"webapp/Articlemanagementindex/article_collect"                 //查看文章是否收藏
#define kArticleCollectionDel  @"webapp/Articlemanagementindex/articlemanagement_collections"   //批量删除文章收藏
#define kArticleCollectionList @"webapp/Articlemanagementindex/article_collect_list"            //文章收藏列表
//糖管理
//血糖记录
#define kSugarRecordList         @"v1_2/Bloodglucoserecordingindex/lists"       //血糖记录
#define kBloodSugarRecordAdd     @"webapp/Bloodglucoserecordingindex/add"       //添加血糖记录
#define kBloodSugarRecordUpdate  @"webapp/Bloodglucoserecordingindex/update"    //更新血糖记录
#define kBloodSugarRecordLists   @"webapp/Bloodglucoserecordingindex/lists"     //血糖记录列表
#define kBloodSugarRecordDelete  @"webapp/Bloodglucoserecordingindex/delete"    //血糖记录删除
#define kBloodSugarDeviceData    @"webapp/Bloodglucoserecordingindex/get_last"  //获取最新一条数据
#define kBloodSugarImportData    @"webapp/Bloodglucoserecordingindex/multi_add"  //血糖数据批量导入
#define kBloodSugarResult        @"webapp/Bloodglucoserecordingindex/read"       //血糖结果

//检查报告
#define kAddExaminationSheet     @"webapp/examination_sheet/add"                //添加检查报告
#define kExaminationSheetUpdata  @"webapp/examination_sheet/update"             //修改检查报告
#define kExaminationSheetDelete  @"webapp/examination_sheet/delete"             //删除检查报告
#define kExaminationSheetLists   @"webapp/examination_sheet/lists"              //查看检查报告

//血压记录
#define kAddBloodData            @"webapp/blood_pressure/pressureRecord"        //添加血压记录
#define kBloodUpdata             @"webapp/blood_pressure/update"                //修改血压记录
#define kBloodDelete             @"webapp/blood_pressure/delete"                //删除血压记录
#define kBloodLists              @"webapp/blood_pressure/lists"                 //查看血压记录

//糖化记录
#define kAddglycosylatedData     @"webapp/glycosylated_hemoglobin/add"          //添加糖化记录
#define kGlycosylatedUpdata      @"webapp/glycosylated_hemoglobin/update"       //修改糖化记录
#define kGlycosylatedDelete      @"webapp/glycosylated_hemoglobin/delete"       //删除糖化记录
#define kGlycosylatedLists       @"webapp/glycosylated_hemoglobin/lists"        //查看糖化记录

//饮食记录
#define kDietRecordAdd           @"webapp/Dietrecordindex/add"                  //添加饮食记录
#define kDietRecordUpdate        @"webapp/Dietrecordindex/update"               //跟新饮食记录
#define kDietRecordLists         @"webapp/Dietrecordindex/lists"                //饮食记录列表
#define kDietRecordDelete        @"webapp/Dietrecordindex/delete"               //删除饮食记录

//运动记录
#define kSportRecordAdd          @"webapp/Motionrecordindex/add"                //添加运动记录
#define kSportRecordUpdate       @"webapp/Motionrecordindex/update"             //更新运动记录
#define kSportRecordLists        @"webapp/Motionrecordindex/lists"              //运动记录列表
#define kSportRecordDelete       @"webapp/Motionrecordindex/delete"             //删除运动记录

//个人中心
#define kIdeaBack                @"webapp/Feedbackindex/add"                      //意见反馈
#define kAddHealthFiles          @"webapp/Healthrecordsindex/update"              //获取／添加／修改血糖档案
#define kAddFriendRelatives      @"webapp/User/setFamily"                         //添加亲友
#define kloadFriendlists         @"webapp/User/getFamilyList"                     //获取亲友列表
#define kloadFriendDetail        @"webapp/User/getFamilyInfo"                     //获取亲友详情
#define kUpdateFamilyCall        @"webapp/User/updateFamilyCall"                  //更新好友备注
#define kdeleteFriendRelatives   @"webapp/User/delFamily"                         //删除亲友
#define kFriendRequest           @"webapp/User/applyFamily"                       //好友申请
#define kFMyMessage              @"webapp/User/applyFamilyLists"                  //我的消息
#define kFAgreeAddFriend         @"webapp/User/applyFamilyResult"                 //同意／拒绝好友添加
#define kFDeleteFriend           @"webapp/User/deleteFamily"                      //删除亲友
#define kUpdateFamilyStart       @"webapp/User/updateFamilyStart"                 //更新好友短信启动/记录启动
#define kApplyFrienCount         @"webapp/User/applyFamilyCount"                  //当前好友申请数
#define kSyncXlinkUserID         @"webapp/User/setYZYUserId"                      //同步云智易用户id
#define kGetXlinkUserID          @"webapp/User/getYZYUserId"                      //获取云智易用户id
#define kGetTonzeUserID          @"webapp/Inviteindex/getInviteUserId"            //获取糖士用户id
#define kGetInviteLists          @"webapp/Inviteindex/inviteLists"                //邀请记录
#define KFeedbackLists          @"webapp/Feedbackindex/lists"                       // 意见反馈列表
#define KFeedbackDetail         @"webapp/Feedbackindex/info"                        // 意见反馈详情
#define KFeedbackNewMessage     @"webapp/Feedbackindex/redPoint"                    // 反馈红点
#define KGetInviteconfig        @"webapp/Inviteconfigindex/getInviteconfig"         // 糖友邀请配置

//糖服务
#define kV1_2RecommendSrevice    @"v1_2/Recommend/recScheme"                      //v1_2推荐方案
#define kRecommendSrevicePlan    @"webapp/recommend/recScheme"                    //推荐方案
#define kServiceExpertClass      @"webapp/service/classLists"                     //专家分类
#define kServiceExpertConsult    @"webapp/service/expertAdvice"                   //专家咨询
#define kMineExpert              @"webapp/service/mineExpert"                     //我的专家
#define kMineService             @"webapp/service/mineService"                    //我的服务
#define kServiceDetail           @"webapp/service/serviceDetail"                  //服务详情
#define kExpertDetail            @"webapp/service/expertDetail"                   //专家详情
#define kOrderDetail             @"webapp/service/expertByOrder"                  //订单详情
#define kWechatPayOrder          @"webapp/wx_app_pay/unifiedOrder"                //微信支付
#define kAlipayOrder             @"webapp/ali_pay/tradeOrder"                     //支付宝支付
#define kSyncAlipayStatus        @"webapp/ali_pay/syncOrderStatus"                //同步支付宝支付结果
#define kSyncWepayStatus         @"webapp/wx_app_pay/orderquery"                  //同步微信支付结果
#define kCancleCare              @"webapp/service/focus"                          //取消关注
#define kAllEvaluate             @"webapp/service/getCommentList"                 //全部评价
#define kV1_3SendMessage         @"webapp/User/sendFamilyMessage"                 //发送血糖信息提醒v_1.3
#define kAddServiceEvaluate      @"webapp/service/planComment"                    //添加服务评价
#define kIntelligentList         @"v1_2/Consult/lists"                            //智能咨询问题列表
#define kV2_0RecommendList       @"v1_2/Recommend/picScheme"                      //图文咨询推荐列表v_2.0
#define kGetServiceExperts       @"webapp/service/serviceExperts"                 //获取环信用户信息
#define kResearchDetail           @"v2_3/Research/detail"                         //调查表详情
#define kResearchAdd              @"v2_3/Research/add"                            //调查表保存
//聊天管理
#define kSendPushMsg              @"webapp/Groupchat/relation"                   //购买服务后建立环信关系并发送推送
#define kAddChatMessage           @"webapp/Groupchat/add"                        //保存聊天记录
#define kChatMessageList          @"webapp/Groupchat/lists"                      //获取聊天记录
#define kDeleteChatMessage        @"webapp/Groupchat/delete"                      //删除聊天记录


//
#define kGetExpertsForUser       @"webapp/User/getExperts"                       //获取用户的专家列表

// 积分商城
#define KGoodsList              @"webapp/Goodsindex/lists"                         // 积分商品列表
#define KGoodDetail             @"webapp/Goodsindex/read"                          // 商品详情
#define KIntegralList           @"webapp/task/lists"                               // 积分列表
#define kIntegralDetail         @"webapp/task/read"                                // 积分详情
#define KIntegralTaskList       @"webapp/task/taskList"                            // 积分任务列表
#define kExchangeRecordsList    @"webapp/Orderindex/lists"                         // 兑换记录列表
#define KExchangeRecordsDetail  @"webapp/Orderindex/read"                          // 兑换记录详情
#define kAddConsignee           @"webapp/Consigneeindex/add_consignee"             // 用户收货地址信息
#define KExchangeGoods          @"webapp/Orderindex/add"                           // 兑换积分商品
#define KIntegralTask           @"webapp/task/task"                                // 每日任务
#define KSignCount              @"webapp/task/signCount"                           // 签到数据
// 定时提醒
#define KReminderList           @"webapp/time_reminder/lists"                      // 提醒列表
#define KReminderDelete         @"webapp/time_reminder/delete"                     // 提醒删除
#define KReminderAdd            @"webapp/time_reminder/add"                        // 提醒添加
#define KReminderUpdate         @"webapp/time_reminder/update"                     // 提醒编辑

//数据埋点
#define KUserClick              @"center/Index/click"                              // 用户点击事件
#define KUserShare              @"center/Index/share"                              // 用户分享事件
#define KUserAction             @"center/Index/action"                             // 用户行为事件


//糖友圈
#define KLoadFoucsOnList        @"friend/Newsattindex/follow_lists"                // 获取关注人列表
#define KLoadotherFoucsOnList   @"friend/Newsattindex/other_follow_lists"          // 获取其他人关注人列表
#define KLoadBeFoucsOnList      @"friend/Newsattindex/followed_lists"              // 获取被关注人列表
#define KLoadotherBeFoucsOnList @"friend/Newsattindex/other_followed_lists"        // 获取被其他人关注人列表
#define KLoadNewFriendList      @"friend/Newsattindex/new_followed_lists"          // 获取新好友列表
#define KLoadDynamicDetail      @"friend/dynamics/read"                            // 获取动态详情
#define KLoadPraiseList         @"friend/dynamics/praiseList"                      // 获取动态点赞列表
#define KLoadCommentsList       @"friend/dynamics/commentList"                     // 获取动态评论列表
#define KReleaseDynamic         @"friend/dynamics/release"                         // 发布动态
#define KLoadMyCommentsList     @"friend/Newsattindex/comment_lists"               // 获取我的评论列表
#define KLoadCommentsMyList     @"friend/Newsattindex/commented_lists"             // 获取评论我的列表
#define KLoadAtedList           @"friend/Newsattindex/ated_lists"                  // 获取@我的列表
#define KLoadMySugarFriendInfo  @"friend/Newsattindex/info_index"                  // 获取我的糖友圈首页
#define KfriendGroupList        @"friend/lists/list"                               // 获取糖友圈动态
#define KDynamicDoComment       @"friend/dynamics/doComment"                       // 评论动态／回复评论
#define KDynamicDoLike          @"friend/dynamics/doLike"                          // 点赞动态／评论
#define KDynamicMoreComment     @"friend/dynamics/moreComment"                     // 获取更多回复
#define kFocusFriend            @"friend/dynamics/focus"                           // 关注／取消关注
#define kLoadLikeList           @"friend/Newsattindex/like_lists"                  // 我赞的列表
#define kLoadLikedList          @"friend/Newsattindex/liked_lists"                 // 赞我的列表
#define kattr_setUpdate         @"friend/Newsattindex/attr_set"                    // 提醒查看／更新
#define KLoadFriendUserInfo     @"friend/user/info"                                // 获取糖友圈个人信息
#define KDynamicDelete          @"friend/dynamics/delete"                          // 动态删除
#define KCommentsDelete         @"friend/dynamics/deleteComment"                   // 评论删除
#define KTopicLists             @"friend/topic/lists"                              // 话题列表
#define KTopicDetail            @"friend/topic/detail"                             // 话题详情
#define KSugarFriendSerarch     @"friend/friend_search/lists"                      // 糖友圈搜索
#define KSearchMoreFriend       @"friend/friend_search/moreFriends"                // 更多好友
#define KUserGagRemind          @"webapp/gag/lists"                                // 禁言提醒
#define KDeleteCommentOfArticle @"webapp/articlemanagementindex/deleteCommentOfArticle"   // 删除评论
#define KCommentOfArticle       @"webapp/articlemanagementindex/commentOfArticle"         // 评论文章
#define KRankLists              @"friend/dynamics/rankLists"                              // 排行榜
#define KFriendHotKeyWords      @"friend/friend_search/hotKeyWords"                       // 糖友圈热门关键字


//设备
#define kCloudMenuList          @"webapp/Cookindex/index"                           //菜谱列表
#define kCloudMenuDetail        @"webapp/Cookindex/detail"                          //菜谱详情
// GPRS 血糖仪
#define KunbindSn               @"webapp/glucose_meter/unbindSn"                    // 解绑GPRS血糖仪
#define KbindSn                 @"webapp/glucose_meter/bindSn"                      // 绑定GPRS血糖仪
#define KGlucoseMeterlist       @"webapp/glucose_meter/lists"                       // 血糖仪列表
#define KsingleHistory          @"webapp/glucose_meter/singleHistory"              // 单个血糖仪历史记录
#define KRename                 @"webapp/glucose_meter/rename"                     // 修改GPRS血糖仪名


//商城
#define KShopGoods          @"index.php/openapi/shop_goods/get_cat_list"               // 商品一级分类
#define KShopGoodsList      @"index.php/openapi/shop_goods/search_properties_goods"    // 商品分类列表
#define KShopDetail         @"index.php/openapi/shop_goods/get_goods_detail"           // 商品详情
#define KShopAddCart        @"index.php/openapi/shop_goods/add_cart"                   // 加入购物车
#define KShopCartNum        @"index.php/openapi/shop_goods/cart_num"                   // 购物车数
#define KShopCollection     @"index.php/openapi/shop_goods/addDel_fav"                 // 商品收藏
#define KShopFavoriteList   @"index.php/openapi/shop_user/favorite"                    // 商品收藏列表
#define KShopDelFavorite    @"index.php/openapi/shop_user/del_favorite"                // 商品删除收藏
#define kShopCartGoodsList  @"index.php/openapi/shop_cart/get_cart_info"               //购物车列表
#define kShopCartUpdate     @"openapi/shop_cart/update_cart"                           //更新购物车
#define kShopCartChangeNum  @"index.php/openapi/shop_cart/change_num"                  //修改购物车商品数量
#define kShopAddToFavorites @"index.php/openapi/shop_goods/add_fav"                    //移入收藏夹
#define kShopDeleteGoods    @"index.php/openapi/shop_cart/remove_cart"                 //删除商品
#define kShopOrderCreate    @"openapi/shop_cart/create"                                //提交订单
#define kGetShopPayInfo     @"openapi/shop_pay/payment"                                //获取支付信息
#define kOrderWxPayCallBack  @"openapi/ectools_payment/parse/ectools/ectools_payment_plugin_wxpayTsApp/callback/"        //微信支付回调
#define kOrderAliPayCallBack @"openapi/ectools_payment/parse/ectools/ectools_payment_plugin_alipayTsApp/callback/"       //支付宝支付回调
#define KShopOrderList      @"index.php/openapi/shop_user/get_order_list"              // 订单列表
#define KShopOrderDetail    @"index.php/openapi/shop_order/get_order_detail"           // 订单详情
#define kDeleaterOrder      @"index.php/openapi/shop_user/del_order"                   // 订单删除
#define KSaveAddress        @"index.php/openapi/shop_user/save_address"                // 添加和编辑收货地址
#define kShippingAddress    @"index.php/openapi/shop_user/get_address"                 // 收货地址列表
#define KGetAllRegions      @"index.php/openapi/shop_user/get_all_regions"             // 收货地址省市地区
#define KDeleateAddress     @"index.php/openapi/shop_user/del_address"                 // 收货地址删除
#define kShopCartSelected   @"index.php/openapi/shop_cart/option"                      // 购物车商品单/多选
#define kShopOrderNum       @"index.php/openapi/shop_order/get_order_count"            // 我的订单总数
#define KStatusUpdate       @"index.php/openapi/shop_order/status_update"              // 更新订单状态取消/确认收货
#define KBuyAgain           @"index.php/openapi/shop_user/re_add_cart"                 // 再次购买
#define kOrderReceive       @"index.php/openapi/shop_order/receive"                    // 确认收货
#define KShopHotKeyWords    @"index.php/openapi/shop_goods/get_keyword"                // 商城热门关键词
#define KOrderCount         @"index.php/openapi/shop_order/get_order_count"            // 订单数量
#define KShopQuickBuy       @"openapi/shop_cart/quickBuy"                              // 立即购买
#define KLogisticsInfo      @"index.php/openapi/shop_order/get_kdniao_logistics"       // 订单物流


