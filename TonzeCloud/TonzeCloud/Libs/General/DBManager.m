//
//  DMManger.m
//  Newests
//
//  Created by AllenKwok on 15/9/8.
//  Copyright (c) 2015年 AllenKwok. All rights reserved.
//

#import "DBManager.h"


@interface DBManager ()
{
    FMDatabase *_database;
}
@end

@implementation DBManager

+(instancetype)shareManager{
    static DBManager *manger = nil;
    if (manger == nil) {
        manger = [[[self class] alloc]init];
    }
    return manger;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initDatabase];
    }
    return self;
}

-(void)initDatabase{
    //1.获取数据库文件app.db的路径
    NSString *filePath = [self getFileFullPathWithFileName:@"app.db"];
    _database = [[FMDatabase alloc] initWithPath:filePath];
    if (_database.open) {
        NSLog(@"打开数据库成功");
        //创建表 不存在 则创建
        [self creatMessageTable];
    }else{
        MyLog(@"打开数据库失败");
    }
}

#pragma mark  获取文件的全路径
//获取文件在沙盒中的 Documents中的路径
- (NSString *)getFileFullPathWithFileName:(NSString *)fileName {
    NSString *docPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:docPath]) {
        //文件的全路径
        return [docPath stringByAppendingFormat:@"/%@",fileName];
    }else {
        //如果不存在可以创建一个新的
        MyLog(@"Documents不存在");
        return nil;
    }
}

#pragma mark 创建消息表
- (void)creatMessageTable {
    NSString *sql = @"create table if not exists message(serial integer  Primary Key Autoincrement,userID Varchar(1024),deviceName Varchar(1024),state Varchar(1024),time Varchar(1024),deviceID Varchar(1024),deviceType Varchar(1024),workError Varchar(1024))";
    //创建表 如果不存在则创建新的表
    BOOL isSuccees = [_database executeUpdate:sql];
    if (!isSuccees) {
        MyLog(@"creatTable error:%@",_database.lastErrorMessage);
    }
}


#pragma mark 添加消息
-(void)insertMessage:(TCDeviceMessageModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"insert into message(userID,deviceName,state,time,deviceID,deviceType,workError) values (?,?,?,?,?,?,?)";
    BOOL isSuccess = [_database executeUpdate:sql,userID,model.deviceName,model.state,model.gen_date,@(model.device_id),model.deviceType,[NSString stringWithFormat:@"%@",[NSNumber numberWithBool: model.isWorkError]]];
    if (!isSuccess) {
        MyLog(@"insert error:%@",_database.lastErrorMessage);
    }
    
}

#pragma mark 判断数据是否存在
//根据指定的类型 返回 这条记录在数据库中是否存在
- (BOOL)isExistMessage:(TCDeviceMessageModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"select * from message where deviceID = ? and userID = ?";
    FMResultSet *rs = [_database executeQuery:sql,@(model.device_id),userID];
    if ([rs next]) {//查看是否存在 下条记录 如果存在 肯定 数据库中有记录
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 查询所有消息
- (NSArray *)readAllMessages{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"select * from message where userID = ?";
    FMResultSet * rs = [_database executeQuery:sql,userID];
    
    NSMutableArray *arr = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        TCDeviceMessageModel *model = [[TCDeviceMessageModel alloc]init];
        model.state=[rs stringForColumn:@"state"];
        model.deviceType=[rs stringForColumn:@"deviceType"];
        model.deviceName = [rs stringForColumn:@"deviceName"];
        model.device_id=[[rs stringForColumn:@"deviceID"] integerValue];
        model.gen_date = [rs stringForColumn:@"time"];
        model.deviceType=[rs stringForColumn:@"deviceType"];
        model.isWorkError=[[rs stringForColumn:@"workError"] boolValue];
        
        if (kIsEmptyString(model.deviceName)) {
            [self deleteMessage:model];
        }
        
        [arr addObject:model];
    }
    return arr;
}


#pragma mark 删除消息
- (void)deleteMessage:(TCDeviceMessageModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"delete from message where deviceID=? and userID = ?";
    BOOL isSuccess = [_database executeUpdate:sql,@(model.device_id),userID];
    if (!isSuccess) {
        MyLog(@"delete error:%@",_database.lastErrorMessage);
    }
}



@end
