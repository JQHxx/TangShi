//
//  QuestionnarieDetailViewController.m
//  TangShiService
//
//  Created by vision on 17/12/13.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "QuestionnarieDetailViewController.h"
#import "QuestionnarieDetailTableViewCell.h"

@interface QuestionnarieDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>{
    
    NSInteger ChooseIndex;
    NSInteger chooseRow;
    NSString  *porpmtStr;
    
    NSInteger backIndex;
    
    NSInteger rs_id;
    NSInteger ra_id;
    
    UILabel  *titleLabel;
}

@property (nonatomic,strong)UITableView *detailTableView;

@property (nonatomic,strong)NSMutableArray *dataArray;

@end


@implementation QuestionnarieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=self.titleStr;
    ChooseIndex = 1000;
    backIndex = 0;
    
    [self.view addSubview:self.detailTableView];
    [self requestQusetionnarieData];
    MyLog(@"调查表详情－－－－id:%ld",self.id);
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = self.dataArray[section];
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    NSArray *dataArr = [dict objectForKey:@"option"];
    if (type==4) {
        return dataArr.count*2;
    }if (type==3||type==5) {
        return 1;
    }
    return dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataArray[indexPath.section];
    
    static NSString *identfy = @"QuestionnarieDetailTableViewCell";
    QuestionnarieDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfy];
    if (cell==nil) {
        cell = [[QuestionnarieDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfy];
    }
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    if (type==1||type==2) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    } else {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, kScreenWidth, 0, 0)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textField.delegate = self;
    cell.textView.delegate = self;
    [cell questionnarieDetailData:dict indexPath:indexPath.row section:indexPath.section];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSMutableDictionary *dataOption = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    NSArray *Array = [dict objectForKey:@"option"];
    
    if (ChooseIndex>=0&&ChooseIndex<1000) {
        if (ChooseIndex==indexPath.section) {
            ChooseIndex= 1000;
        }
    }
    if (type==1) {   ///单选
        backIndex = 1;
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        for (int i=0; i<Array.count; i++) {
            if (i==indexPath.row) {
                NSDictionary *dict = Array[i];
                NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dataDict setObject:@"1" forKey:@"val"];
                [dataArr addObject:dataDict];
            } else {
                NSDictionary *dict = Array[i];
                NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dataDict setObject:@"0" forKey:@"val"];
                [dataArr addObject:dataDict];
            }
        }
        [dataOption setObject:dataArr forKey:@"option"];
        NSMutableArray *optionArray = [NSMutableArray arrayWithArray:self.dataArray];
        [optionArray replaceObjectAtIndex:indexPath.section withObject:dataOption];
        self.dataArray = optionArray;
    }else if (type==2){ ///多选
        backIndex = 1;
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        for (int i=0; i<Array.count; i++) {
            if (i==indexPath.row) {
                NSDictionary *dict = Array[i];
                NSInteger seleteInt = [[dict objectForKey:@"val"] integerValue];
                NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dataDict setObject:seleteInt==0?@"1":@"0" forKey:@"val"];
                [dataArr addObject:dataDict];
            } else {
                NSDictionary *dict =Array[i];
                [dataArr addObject:dict];
            }
        }
        [dataOption setObject:dataArr forKey:@"option"];
        NSMutableArray *optionArray = [NSMutableArray arrayWithArray:self.dataArray];
        [optionArray replaceObjectAtIndex:indexPath.section withObject:dataOption];
        self.dataArray = optionArray;
    }
    
    [_detailTableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = self.dataArray[indexPath.section];
    if ([[dict objectForKey:@"type"] integerValue]==5) {
        return 138;
    }else if ([[dict objectForKey:@"type"] integerValue]==1||[[dict objectForKey:@"type"] integerValue]==2){
    
        NSArray *dataArr = [dict objectForKey:@"option"];
        NSDictionary *dataDict =dataArr[indexPath.row];
        NSString *titleStr = [dataDict objectForKey:@"key"];
        CGSize size = [titleStr sizeWithLabelWidth:kScreenWidth-68 font:[UIFont systemFontOfSize:15]];
        return size.height+28;
    }else if ([[dict objectForKey:@"type"] integerValue]==4){
        if (indexPath.row%2==0) {
            return 30;
        }
        return 50;
    }
    return 48;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSDictionary *dict = self.dataArray[section];
    NSString *labStr=[NSString stringWithFormat:@"%ld.%@",section+1,[dict objectForKey:@"title"]];
    CGFloat height = 0.0;
    if ([[dict objectForKey:@"must"] integerValue]==1) {
        NSString *str = [NSString stringWithFormat:@"%@*",labStr];
        height = [str sizeWithLabelWidth:kScreenWidth-56 font:[UIFont systemFontOfSize:18]].height;
    }else{
        NSString *str = labStr;
        height = [str sizeWithLabelWidth:kScreenWidth-56 font:[UIFont systemFontOfSize:18]].height;
    }
    
    if (ChooseIndex==section) {
        return height+23+30;
    }
    return height+23;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSDictionary *dict = self.dataArray[section];
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 48)];
    headView.backgroundColor=[UIColor whiteColor];
    
    CGFloat height = 0.0;
    if (ChooseIndex==section) {
        height = 30;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"0xf65c5c"];
        [headView addSubview:bgView];
        
        UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (30-15)/2, kScreenWidth-40, 15)];
        porpmtLabel.text = porpmtStr;
        porpmtLabel.font = [UIFont systemFontOfSize:13];
        porpmtLabel.textColor = [UIColor colorWithHexString:@"0xffffff"];
        [bgView addSubview:porpmtLabel];
    }
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 2, 48)];
    bgView.backgroundColor = kbgBtnColor;
    [headView addSubview:bgView];
    
    UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12+height, 20, 20)];
    headImgView.image = [UIImage imageNamed:@"chat_ic_q"];
    [headView addSubview:headImgView];
    
    UILabel *lab=[[UILabel alloc] initWithFrame:CGRectZero];
    lab.numberOfLines = 0;
    NSString *labStr=[NSString stringWithFormat:@"%ld.%@",section+1,[dict objectForKey:@"title"]];
    lab.textColor = [UIColor colorWithHexString:@"0x313131"];
    if ([[dict objectForKey:@"must"] integerValue]==1) {
        labStr = [NSString stringWithFormat:@"%@*",labStr];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:labStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(labStr.length-1, 1)];
        lab.attributedText=attributeStr;
    }else{
        lab.text = labStr;
    }
    lab.font=[UIFont systemFontOfSize:18.0f];
    CGSize size = [labStr sizeWithLabelWidth:kScreenWidth-headImgView.right-16 font:[UIFont systemFontOfSize:18]];
    lab.frame = CGRectMake(headImgView.right+6, height+11,kScreenWidth-56, size.height);
    [headView addSubview:lab];
    
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footView.backgroundColor = [UIColor bgColor_Gray];
    return footView;
}
#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}
#pragma mark -- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSInteger section = textField.tag/1000;
    NSInteger row = (textField.tag-section*1000)/10;
    NSInteger type = textField.tag-section*1000-row*10;
    
    if (ChooseIndex>=0&&ChooseIndex<1000&&ChooseIndex==section) {
        if ([porpmtStr isEqualToString:@"*不能提交空白信息*"]) {
            if (type==3) {
                if ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]!=0||textField.text.length==0){
                    backIndex = 1;
                    ChooseIndex= 1000;
                    chooseRow= 0;
                }
            } else {
                if (chooseRow==row/2) {
                    if ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]!=0||textField.text.length==0){
                        backIndex = 1;
                        ChooseIndex= 1000;
                        chooseRow= 0;
                    }
                }
            }
        }
    }
    
    if (ChooseIndex>=0&&ChooseIndex<1000) {
        if (type==3) {
            if (textField.text.length>0&&ChooseIndex==section) {
                backIndex = 1;
                ChooseIndex= 1000;
                chooseRow= 0;
            }
        } else {
            if (textField.text.length>0&&ChooseIndex==section&&chooseRow==row/2) {
                backIndex = 1;
                ChooseIndex= 1000;
                chooseRow= 0;
            }
        }
    }
    
    if (type==3) {  ///单行填空
        NSDictionary *dictArr = self.dataArray[section];
        NSMutableDictionary *dataOption = [NSMutableDictionary dictionaryWithDictionary:dictArr];
        
        NSDictionary *dict = [dictArr objectForKey:@"option"][0];
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dataDict setObject:textField.text forKey:@"val"];
        
        NSMutableArray *dataDictArr = [[NSMutableArray alloc] init];
        [dataDictArr addObject:dataDict];
        [dataOption setObject:dataDictArr forKey:@"option"];
        NSMutableArray *optionArray = [NSMutableArray arrayWithArray:self.dataArray];
        [optionArray replaceObjectAtIndex:section withObject:dataOption];
        self.dataArray = optionArray;
    } else {   ///多行填空
        NSDictionary *dictArr = self.dataArray[section];
        NSMutableDictionary *dataOption = [NSMutableDictionary dictionaryWithDictionary:dictArr];
        
        NSArray *dataArr = [dictArr objectForKey:@"option"];
        NSMutableArray *DataArray = [NSMutableArray arrayWithArray:dataArr];
        NSDictionary *dict = DataArray[row/2];
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dataDict setObject:textField.text forKey:@"val"];
        [DataArray replaceObjectAtIndex:row/2 withObject:dataDict];
        [dataOption setObject:DataArray forKey:@"option"];
        
        NSMutableArray *optionArray = [NSMutableArray arrayWithArray:self.dataArray];
        [optionArray replaceObjectAtIndex:section withObject:dataOption];
        self.dataArray = optionArray;
    }
    [self.detailTableView reloadData];
}
#pragma mark -- UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView{  ///问答
    
    NSInteger section = textView.tag/100;
    if (ChooseIndex>=0&&ChooseIndex<1000&&ChooseIndex==section) {
        if ([porpmtStr isEqualToString:@"*不能提交空白信息*"]) {
            if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]!=0||textView.text.length==0){
                backIndex = 1;
                ChooseIndex= 1000;
                chooseRow= 0;
            }
        }
    }
    
    if (ChooseIndex>=0&&ChooseIndex<1000) {
        if (ChooseIndex==section&&textView.text.length>0) {
            backIndex = 1;
            ChooseIndex= 1000;
            chooseRow= 0;
        }
    }
    NSDictionary *dictArr = self.dataArray[section];
    NSMutableDictionary *dataOption = [NSMutableDictionary dictionaryWithDictionary:dictArr];
    
    NSDictionary *dict = [dictArr objectForKey:@"option"][0];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dataDict setObject:textView.text forKey:@"val"];
    NSMutableArray *dataDictArr = [[NSMutableArray alloc] init];
    [dataDictArr addObject:dataDict];
    [dataOption setObject:dataDictArr forKey:@"option"];
    
    NSMutableArray *optionArray = [NSMutableArray arrayWithArray:self.dataArray];
    [optionArray replaceObjectAtIndex:section withObject:dataOption];
    self.dataArray = optionArray;
    [self.detailTableView reloadData];
}
#pragma mark -- Private Methods
- (UIView *)tableViewHeader{
    UIView *headrView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    headrView.backgroundColor = [UIColor whiteColor];

    for (int i=0; i<2; i++) {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+i*(kScreenWidth/2+10), 29/2, (kScreenWidth-100)/2, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headrView addSubview:lineLabel];
    }
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, 5, 60, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithHexString:@"0x939393"];
    [headrView addSubview:titleLabel];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 10)];
    bgView.backgroundColor = [UIColor bgColor_Gray];
    [headrView addSubview:bgView];
    
    return headrView;
}
- (UIView *)tableViewFooter{
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    footView.backgroundColor = [UIColor whiteColor];

    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, 30, 120, 40)];
    saveButton.backgroundColor = kbgBtnColor;
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    saveButton.layer.cornerRadius = 5;
    [saveButton addTarget:self action:@selector(saveButton) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:saveButton];
    
    return footView;
}
- (void)saveButton{
    [self.view endEditing:YES];
    for (int i=0; i<self.dataArray.count; i++) {
        NSDictionary *dict = self.dataArray[i];
        if ([[dict objectForKey:@"must"] integerValue]==1) {
            if ([[dict objectForKey:@"type"] integerValue]==1||[[dict objectForKey:@"type"] integerValue]==2) {
                NSArray *dataArr = [dict objectForKey:@"option"];
                NSInteger num = 0;
                for (NSDictionary *dictArr in dataArr) {
                    num = num + [[dictArr objectForKey:@"val"] integerValue];
                }
                if (num==0) {
                    ChooseIndex = i;
                    porpmtStr = [[dict objectForKey:@"type"] integerValue]==1?@"*请选择一个选项*":@"*请选择选项*";
                    [_detailTableView reloadData];
                    [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
            } else if([[dict objectForKey:@"type"] integerValue]==3||[[dict objectForKey:@"type"] integerValue]==5){
                
                NSDictionary *dictArr = [dict objectForKey:@"option"][0];
                NSString *dataStr = [dictArr objectForKey:@"val"];
                if ([[dataStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
                    chooseRow = 0;
                    ChooseIndex = i;
                    porpmtStr =@"*请填写内容*";
                    [_detailTableView reloadData];
                     [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
            }else if ([[dict objectForKey:@"type"] integerValue]==4){
                NSArray *dataArr = [dict objectForKey:@"option"];
                
                for (int j=0; j<dataArr.count; j++) {
                    NSDictionary *dictArr = dataArr[j];
                    NSString *dataStr = [dictArr objectForKey:@"val"];
                    if ([[dataStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
                        chooseRow = j;
                        ChooseIndex = i;
                        porpmtStr = @"*请填写内容*";
                        [_detailTableView reloadData];
                        [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        return;
                    }
                }
            }
        }else{
            
            if([[dict objectForKey:@"type"] integerValue]==3||[[dict objectForKey:@"type"] integerValue]==5){
                
                NSDictionary *dictArr = [dict objectForKey:@"option"][0];
                NSString *dataStr = [dictArr objectForKey:@"val"];
                if ([[dataStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0&&dataStr.length!=0) {
                    chooseRow = 0;
                    ChooseIndex = i;
                    porpmtStr =@"*不能提交空白信息*";
                    [_detailTableView reloadData];
                    [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
            }else if ([[dict objectForKey:@"type"] integerValue]==4){
                NSArray *dataArr = [dict objectForKey:@"option"];
                
                for (int j=0; j<dataArr.count; j++) {
                    NSDictionary *dictArr = dataArr[j];
                    NSString *dataStr = [dictArr objectForKey:@"val"];
                    if ([[dataStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0&&dataStr.length!=0) {
                        chooseRow = j;
                        ChooseIndex = i;
                        porpmtStr = @"*不能提交空白信息*";
                        [_detailTableView reloadData];
                        [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        return;
                    }
                }
            }

        
        }
    }
    NSString *dataStr = [[TCHttpRequest sharedTCHttpRequest] getValueWithParams:self.dataArray];
    NSString *body = [NSString stringWithFormat:@"rs_id=%ld&ra_id=%ld&jsonList=%@",rs_id,ra_id,dataStr];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kResearchAdd body:body success:^(id json) {
        weakSelf.saveBlock(weakSelf.titleStr);
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)leftButtonAction{

    if (backIndex==1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定要放弃此次编辑吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }


}
#pragma mark -- 获取调查表详情
- (void)requestQusetionnarieData{
    kSelfWeak;
//    NSInteger userID=[[NSUserDefaultsInfos getValueforKey:kUserID] integerValue];
    NSString *body = [NSString stringWithFormat:@"rs_id=%ld",self.id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kResearchDetail body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            _detailTableView.tableHeaderView = [self tableViewHeader];
            _detailTableView.tableFooterView = [self tableViewFooter];
            rs_id = [[result objectForKey:@"rs_id"] integerValue];
            ra_id = [[result objectForKey:@"ra_id"] integerValue];
            self.dataArray = [result objectForKey:@"jsonList"];
            titleLabel.text = [NSString stringWithFormat:@"共%ld题",self.dataArray.count];
        }else{
            _detailTableView.tableHeaderView = [[UIView alloc] init];
            _detailTableView.tableFooterView = [[UIView alloc] init];
            self.dataArray =[[NSMutableArray alloc] init];
            titleLabel.text = @"";
        }
        [self.detailTableView reloadData];
    } failure:^(NSString *errorStr) {

        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark －－ Gettsers and Setters
#pragma mark 数据
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray=[[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark 调查表列表视图
-(UITableView *)detailTableView{
    if (!_detailTableView) {
        _detailTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _detailTableView.backgroundColor=[UIColor bgColor_Gray];
        _detailTableView.dataSource=self;
        _detailTableView.delegate=self;
        _detailTableView.showsVerticalScrollIndicator = NO;
        _detailTableView.tableFooterView = [[UIView alloc] init];
    }
    return _detailTableView;
}

@end

