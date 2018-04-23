//
//  TCMyQRCodeViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyQRCodeViewController.h"
#import "QLCoreTextManager.h"

@interface TCMyQRCodeViewController (){

    UIImageView   *QRCodeImg;
    UILabel       *titleLabel;
}
@end

@implementation TCMyQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的二维码";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initMyQRCodeView];
    [self loadQRCodeData];
}
#pragma mark -- 生成二维码
- (void)loadQRCodeData{

    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据
    
    NSString *dataString = [NSUserDefaultsInfos getValueforKey:kPhoneNumber];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // 4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    QRCodeImg.image = [[TCHelper sharedTCHelper] changeImageSizeWithCIImage:outputImage andSize:200];
}

#pragma mark -- 初始化界面
- (void)initMyQRCodeView{

    QRCodeImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-370/2 * kScreenWidth/375)/2,(kNewNavHeight + 50) * kScreenWidth/375, 370/2 * kScreenWidth/375 , 370/2 * kScreenWidth/375)];
    QRCodeImg.layer.borderWidth = 1;
    QRCodeImg.layer.borderColor = UIColorFromRGB(0xdadbdb).CGColor;
    [self.view addSubview:QRCodeImg];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, QRCodeImg.bottom+20, kScreenWidth-80, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.numberOfLines = 0;
    [self.view addSubview:titleLabel];
    NSString *tipStr = @"将二维码展示给您的亲友，\n让ta关注我的血糖数据";
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:tipStr];
    [QLCoreTextManager setAttributedValue:att artlcleText:@"血糖数据" font:[UIFont systemFontOfSize:15] color:kSystemColor];
    titleLabel.attributedText = att;
    
    CGSize size = [titleLabel.text sizeWithLabelWidth:kScreenWidth-80 font:[UIFont systemFontOfSize:15]];
    titleLabel.frame = CGRectMake(40, QRCodeImg.bottom+20, kScreenWidth-80, size.height);
}
@end
