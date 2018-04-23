//
//  TCCollectionViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/13.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCCollectionViewController.h"
#import "TCClickViewGroup.h"
#import "GoodsFavoriteModel.h"
#import "TCCollectionTableViewCell.h"
#import "ShopDetailViewController.h"
#import "TCBasewebViewController.h"
#import "TCArticleTableViewCell.h"
#import "TCArticleModel.h"

@interface TCCollectionViewController ()<TCClickViewGroupDelegate,UITableViewDelegate,UITableViewDataSource>{


    NSMutableArray    *myShopCollectionArray;     //我的商品收藏
    NSMutableArray    *myArticleCollectionArray;     //我的文章收藏
    NSMutableArray    *shopDeteleArray;
    NSMutableArray    *articleDeteleArray;
    
    TCBlankView       *blankView;
    NSInteger          shopPage;
    NSInteger          articlePage;
    NSInteger          selectIndex;
    
    BOOL               isShopCollectionReload;
    BOOL               isarticleCollectionReload;
    
    UIButton          *allSelectBtn;      //全选
    UIButton          *deleteBtn;         //删除
}

@property (nonatomic,strong)TCClickViewGroup    *myCollectionMenu;

@property (nonatomic,strong)UITableView         *myCollectionTableView;

@property (nonatomic,strong)UIView           *bottomView;

@property (nonatomic,strong)UIView           *backGroudView;

@end

@implementation TCCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的收藏";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    myShopCollectionArray = [[NSMutableArray alloc] init];
    myArticleCollectionArray = [[NSMutableArray alloc] init];
    shopDeteleArray = [[NSMutableArray alloc] init];
    articleDeteleArray = [[NSMutableArray alloc] init];
    shopPage = 1;
    articlePage = 1;
    selectIndex = 0;
    
    [self initCollectionView];
    [self requestMyCollectionData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"003-19" type:1];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"003-19" type:2];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    isShopCollectionReload = isarticleCollectionReload = NO;
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (selectIndex==0) {
        return myShopCollectionArray.count;
    }
    return myArticleCollectionArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectIndex==0) {
        static NSString *ordersGoodsCellIdentifier = @"TCCollectionTableViewCell";
        TCCollectionTableViewCell  *ordersGoodsCell = [tableView dequeueReusableCellWithIdentifier:ordersGoodsCellIdentifier];
        if (!ordersGoodsCell) {
            ordersGoodsCell = [[TCCollectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ordersGoodsCellIdentifier];
        }
        GoodsFavoriteModel *goodsModel = myShopCollectionArray[indexPath.row];
        [ordersGoodsCell initWithShopCollectionModel:goodsModel];
        ordersGoodsCell.selectedBackgroundView = _backGroudView;
        return ordersGoodsCell;
    } else {
        static NSString *cellIdentifier=@"TCArticleTableViewCell";
        TCArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        TCArticleModel *article=myArticleCollectionArray[indexPath.row];
        [cell cellDisplayWithModel:article searchText:@""];
        return cell;
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.myCollectionTableView.editing==YES) {
        if (selectIndex==0) {
            [shopDeteleArray addObject:[myShopCollectionArray objectAtIndex:indexPath.row]];
            if (shopDeteleArray.count==myShopCollectionArray.count) {
                allSelectBtn.selected = YES;
            }
        } else {
            [articleDeteleArray addObject:[myArticleCollectionArray objectAtIndex:indexPath.row]];
            if (articleDeteleArray.count==myArticleCollectionArray.count) {
                allSelectBtn.selected = YES;
            }
        }
    }else{
        NSArray *subviews = [[tableView cellForRowAtIndexPath:indexPath] subviews];
        for (id obj in subviews) {
            if ([obj isKindOfClass:[UIControl class]]) {
                for (id subview in [obj subviews]) {
                    if ([subview isKindOfClass:[UIImageView class]]) {
                        [subview setValue:[UIColor whiteColor] forKey:@"tintColor"];
                        break;
                    }
                }
            }  
        }
        if (selectIndex==0) {
            if (myShopCollectionArray.count>0) {
                [[TCHelper sharedTCHelper] loginClick:@"003-19-02"];
                [MobClick event:@"104_002065"];
                GoodsFavoriteModel *goodsModel = myShopCollectionArray[indexPath.row];
                // 商品详情
                if ([goodsModel.is_del integerValue]==1) {
                    [self.view makeToast:@"该货品已不存在" duration:1.0 position:CSToastPositionCenter];
                } else {
                    ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
                    shopDetailVC.product_id =  goodsModel.product_id;
                    [self.navigationController pushViewController:shopDetailVC animated:YES];
                }
            }
        } else {
            if (myArticleCollectionArray.count>0) {
                [[TCHelper sharedTCHelper] loginClick:@"003-19-03"];
                [MobClick event:@"104_002066"];
                TCArticleModel *articleModel = myArticleCollectionArray[indexPath.row];
                NSString *urlString = [NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)articleModel.id];
                TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
                webVC.type=BaseWebViewTypeArticle;
                webVC.titleText=@"糖士-糖百科";
                webVC.shareTitle = articleModel.title;
                webVC.image_url = articleModel.image_url;
                webVC.urlStr=urlString;
                webVC.articleID = articleModel.id;
                kSelfWeak;
                webVC.backBlock=^(){
                    for (TCArticleModel *model in myArticleCollectionArray) {
                        if (model.id==articleModel.id) {
                            model.reading_number+=1;
                        }
                    }
                    [weakSelf.myCollectionTableView reloadData];
                };
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (selectIndex==0) {
        [shopDeteleArray removeObject:[myShopCollectionArray objectAtIndex:indexPath.row]];
        allSelectBtn.selected = NO;
    } else {
        [articleDeteleArray removeObject:[myArticleCollectionArray objectAtIndex:indexPath.row]];
        allSelectBtn.selected = NO;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectIndex == 0) {
        return 100;
    }
    return 100;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
    
}
//侧滑允许编辑cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//执行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectIndex==0) {
        [[TCHelper sharedTCHelper] loginClick:@"003-19-04"];
        [MobClick event:@"104_002067"];
        GoodsFavoriteModel *goodsModel = myShopCollectionArray[indexPath.row];
        NSString *user_id = [NSUserDefaultsInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&gid=%ld",user_id,(long)goodsModel.gnotify_id];
        [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithURL:KShopDelFavorite body:body success:^(id json) {
            NSMutableArray *shopArray = [[NSMutableArray alloc] init];
            for ( GoodsFavoriteModel *Model in myShopCollectionArray) {
                if (Model.gnotify_id != goodsModel.gnotify_id) {
                    [shopArray addObject:Model];
                }
            }
            myShopCollectionArray = shopArray;
            blankView.hidden = myShopCollectionArray.count>0;
            self.rigthTitleName = myShopCollectionArray.count>0?@"编辑":@"";
            [self.myCollectionTableView reloadData];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    } else {
        [[TCHelper sharedTCHelper] loginClick:@"003-19-05"];
        [MobClick event:@"104_002068"];
        TCArticleModel *articleModel = myArticleCollectionArray[indexPath.row];
        NSMutableArray *idArr = [[NSMutableArray alloc] init];
        [idArr addObject:[NSString stringWithFormat:@"%ld",articleModel.id]];
        NSString *body = [NSString stringWithFormat:@"id=%@",[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:idArr]];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCollectionDel body:body success:^(id json) {
            NSMutableArray *articleArr = [[NSMutableArray alloc] init];
            for ( TCArticleModel *Model in myArticleCollectionArray) {
                if (Model.id != articleModel.id) {
                    [articleArr addObject:Model];
                }
            }
            myArticleCollectionArray = articleArr;
            blankView.hidden = myArticleCollectionArray.count>0;
            self.rigthTitleName = myArticleCollectionArray.count>0?@"编辑":@"";
            [self.myCollectionTableView reloadData];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
//侧滑出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}
#pragma mark ClickViewGroupDelegate
-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index{
    [MobClick event:@"104_002064"];
    [[TCHelper sharedTCHelper] loginClick:@"003-19-01"];
    self.myCollectionTableView.editing = NO;
    self.bottomView.hidden = YES;
    self.myCollectionTableView.frame =CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41);
    allSelectBtn.selected = NO;
    [shopDeteleArray removeAllObjects];
    [articleDeteleArray removeAllObjects];

    selectIndex=index;
    [self requestMyCollectionData];
}

#pragma mark -- Event Response
#pragma mark -- 加载收藏列表
- (void)requestMyCollectionData{
    
    if (selectIndex==0) {
        if (isShopCollectionReload==NO) {
            NSString *user_id = [NSUserDefaultsInfos getValueforKey:USER_ID];
            NSString *body = [NSString stringWithFormat:@"member_id=%@&page_num=%ld&page_size=20&platform=ts",user_id,shopPage];
            __weak typeof(self) weakSelf=self;
            [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithURL:KShopFavoriteList body:body success:^(id json) {
                NSArray *result = [[json objectForKey:@"result"] objectForKey:@"aProduct"];
                NSInteger total = 0;
                NSDictionary *pager =[[json objectForKey:@"result"] objectForKey:@"pager"];
                if (kIsDictionary(pager)) {
                    total= [[pager objectForKey:@"total"] integerValue];
                }
                if (kIsArray(result)&&result.count>0) {
                    NSMutableArray *goodsArr = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in result) {
                        GoodsFavoriteModel *model = [[GoodsFavoriteModel alloc] init];
                        [model setValues:dict];
                        [goodsArr addObject:model];
                    }
                    blankView.hidden = goodsArr.count>0;
                    if (shopPage==1) {
                        myShopCollectionArray = goodsArr;
                    } else {
                        [myShopCollectionArray addObjectsFromArray:goodsArr];
                    }
                    weakSelf.myCollectionTableView.mj_footer.hidden=(total -shopPage*20)<=0;
                }else{
                    blankView.hidden=NO;
                    weakSelf.myCollectionTableView.mj_footer.hidden = YES;
                    myShopCollectionArray = [[NSMutableArray alloc] init];
                }
                self.rigthTitleName = myShopCollectionArray.count>0?@"编辑":@"";
                isShopCollectionReload = YES;
                [weakSelf.myCollectionTableView reloadData];
                [weakSelf.myCollectionTableView.mj_header endRefreshing];
                [weakSelf.myCollectionTableView.mj_footer endRefreshing];
            } failure:^(NSString *errorStr) {
                [self.myCollectionTableView reloadData];
                [weakSelf.myCollectionTableView.mj_header endRefreshing];
                [weakSelf.myCollectionTableView.mj_footer endRefreshing];
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];

        } else {
            blankView.hidden=myShopCollectionArray.count>0;
            self.rigthTitleName = myShopCollectionArray.count>0?@"编辑":@"";
            self.myCollectionTableView.mj_footer.hidden=myShopCollectionArray.count%20<20;
            [self.myCollectionTableView reloadData];
        }
    } else {
        if (isarticleCollectionReload==NO) {
            NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",articlePage];
            __weak typeof(self) weakSelf=self;
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCollectionList body:body success:^(id json) {
                NSArray *result = [json objectForKey:@"result"];
                NSInteger total = 0;
                NSDictionary *pager =[json objectForKey:@"pager"];
                if (kIsDictionary(pager)) {
                    total= [[pager objectForKey:@"total"] integerValue];
                }
                if (kIsArray(result)&&result.count>0) {
                    NSMutableArray *articleArr = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in result) {
                        TCArticleModel *model = [[TCArticleModel alloc] init];
                        [model setValues:dict];
                        [articleArr addObject:model];
                    }
                    blankView.hidden = articleArr.count>0;
                    if (articlePage==1) {
                        myArticleCollectionArray = articleArr;
                    } else {
                        [myArticleCollectionArray addObjectsFromArray:articleArr];
                    }
                    weakSelf.myCollectionTableView.mj_footer.hidden=(total -shopPage*20)<=0;
                }else{
                    blankView.hidden=NO;
                    myArticleCollectionArray = [[NSMutableArray alloc] init];
                    weakSelf.myCollectionTableView.mj_footer.hidden = YES;
                }
                self.rigthTitleName = myArticleCollectionArray.count>0?@"编辑":@"";
                isarticleCollectionReload = YES;
                [weakSelf.myCollectionTableView reloadData];
                [weakSelf.myCollectionTableView.mj_header endRefreshing];
                [weakSelf.myCollectionTableView.mj_footer endRefreshing];
            } failure:^(NSString *errorStr) {
                [self.myCollectionTableView reloadData];
                [weakSelf.myCollectionTableView.mj_header endRefreshing];
                [weakSelf.myCollectionTableView.mj_footer endRefreshing];
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
            
            
        } else {
            blankView.hidden=myArticleCollectionArray.count>0;
            self.rigthTitleName = myArticleCollectionArray.count>0?@"编辑":@"";
            self.myCollectionTableView.mj_footer.hidden=myArticleCollectionArray.count%20<20;
            [self.myCollectionTableView reloadData];
        }
    }

}
#pragma mark --Event Response
#pragma mark 编辑
-(void)rightButtonAction{
  
    if (selectIndex==0) {
        if (myShopCollectionArray.count==0) {
            return;
        }
    } else {
        if (myArticleCollectionArray.count==0) {
            return;
        }
    }
    
    self.myCollectionTableView.editing = !self.myCollectionTableView.editing;
    self.rigthTitleName=self.myCollectionTableView.editing?@"取消":@"编辑";
    
    if (self.myCollectionTableView.editing) {
        self.myCollectionTableView.frame =CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41-50);
        self.bottomView.hidden = NO;
    }else{
        self.myCollectionTableView.frame =CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41);
        self.bottomView.hidden = YES;
        allSelectBtn.selected = NO;
        if (selectIndex==0) {
            [shopDeteleArray removeAllObjects];
        } else {
            [articleDeteleArray removeAllObjects];
        }
    }
}
#pragma mark -- 删除收藏
- (void)deleteCollection:(UIButton *)button{
    if (selectIndex==0) {
        if (shopDeteleArray.count>0) {
            [self alertPorpmtContent];
        }else{
            [self.view makeToast:@"请选择要删除的商品内容" duration:1.0 position:CSToastPositionCenter];
        }
    }else{
        if (articleDeteleArray.count>0) {
            [self alertPorpmtContent];
        }else{
            [self.view makeToast:@"请选择要删除的文章内容" duration:1.0 position:CSToastPositionCenter];
        }
    }
}
- (void)alertPorpmtContent{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除所选收藏吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        if (selectIndex==0) {
            [[TCHelper sharedTCHelper] loginClick:@"003-19-04"];
            [MobClick event:@"104_002067"];
            NSString *body = nil;
            if (shopDeteleArray.count>1) {
                NSMutableArray *shopIDArr = [[NSMutableArray alloc] init];
                for (GoodsFavoriteModel *model in shopDeteleArray) {
                    [shopIDArr addObject:[NSString stringWithFormat:@"%ld",model.gnotify_id]];
                }
                NSString *user_id = [NSUserDefaultsInfos getValueforKey:USER_ID];
                body = [NSString stringWithFormat:@"member_id=%@&gid=%@",user_id,[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:shopIDArr]];
            } else {
                GoodsFavoriteModel *model = shopDeteleArray[0];
                NSString *user_id = [NSUserDefaultsInfos getValueforKey:USER_ID];
                body = [NSString stringWithFormat:@"member_id=%@&gid=%ld",user_id,(long)model.gnotify_id];
            }
            [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithURL:KShopDelFavorite body:body success:^(id json) {

                for (GoodsFavoriteModel *deleteModel in shopDeteleArray) {
                    for (int i=0; i<myShopCollectionArray.count; i++) {
                        GoodsFavoriteModel *shopModel = myShopCollectionArray[i];
                        if (shopModel.gnotify_id==deleteModel.gnotify_id) {
                            [myShopCollectionArray removeObjectAtIndex:i];
                        }
                    }
                }
                blankView.hidden = myShopCollectionArray.count>0;
                if (myShopCollectionArray.count==0) {
                    self.myCollectionTableView.editing = NO;
                    self.rigthTitleName = @"";
                    self.bottomView.hidden = YES;
                    self.myCollectionTableView.frame =CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41);
                    allSelectBtn.selected = NO;
                }
                [self.myCollectionTableView reloadData];
                [self.view makeToast:@"所选收藏已删除" duration:1.0 position:CSToastPositionCenter];
            } failure:^(NSString *errorStr) {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        } else {
            [[TCHelper sharedTCHelper] loginClick:@"003-19-05"];
            [MobClick event:@"104_002068"];
            NSMutableArray *idArr = [[NSMutableArray alloc] init];
            for (TCArticleModel *model in articleDeteleArray) {
                [idArr addObject:[NSString stringWithFormat:@"%ld",model.id]];
            }
            NSString *body = [NSString stringWithFormat:@"id=%@",[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:idArr]];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCollectionDel body:body success:^(id json) {

                for (TCArticleModel *deleteModel in articleDeteleArray) {
                    for (int i=0; i<myArticleCollectionArray.count; i++) {
                        TCArticleModel *articleModel = myArticleCollectionArray[i];
                        if (articleModel.id==deleteModel.id) {
                            [myArticleCollectionArray removeObjectAtIndex:i];
                        }
                    }
                }
                blankView.hidden = myArticleCollectionArray.count>0;
                if (myArticleCollectionArray.count==0) {
                    self.myCollectionTableView.editing = NO;
                    self.rigthTitleName = @"";
                    self.bottomView.hidden = YES;
                    self.myCollectionTableView.frame =CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41);
                    allSelectBtn.selected = NO;
                }
                [self.myCollectionTableView reloadData];
                [self.view makeToast:@"所选收藏已删除" duration:1.0 position:CSToastPositionCenter];
            } failure:^(NSString *errorStr) {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }

    }];
    [deleteAction setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alert addAction:deleteAction];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        
    }];
    [cancleAction setValue:kSystemColor forKey:@"_titleTextColor"];
    [alert addAction:cancleAction];
    [self presentViewController:alert animated:true completion:nil];


}

#pragma mark -- 全选
- (void)selectAllCollectionSender:(UIButton *)button{
    button.selected=!button.selected;
    if (button.selected==YES) {
        if (selectIndex==0) {
            [shopDeteleArray removeAllObjects];
            [shopDeteleArray addObjectsFromArray:myShopCollectionArray];
            for (int i = 0; i < myShopCollectionArray.count; i ++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.myCollectionTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        } else {
            [articleDeteleArray removeAllObjects];
            [articleDeteleArray addObjectsFromArray:myArticleCollectionArray];
            for (int i = 0; i < myArticleCollectionArray.count; i ++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.myCollectionTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else {
        if (selectIndex==0) {
            [shopDeteleArray removeAllObjects];
            for (int i = 0; i < myShopCollectionArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.myCollectionTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else {
            [articleDeteleArray removeAllObjects];
            for (int i = 0; i < myArticleCollectionArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.myCollectionTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
}
#pragma mark -- 加载最新数据
- (void)loadNewCollectionData{
    if (selectIndex==0) {
        isShopCollectionReload = NO;
        shopPage = 1;
    } else {
        isarticleCollectionReload = NO;
        articlePage = 1;
    }
    [self requestMyCollectionData];
}
#pragma mark -- 加载更多数据
- (void)loadMoreCollectionData{
    if (selectIndex==0) {
        isShopCollectionReload = NO;
        shopPage++;
    } else {
        isarticleCollectionReload = NO;
        articlePage++;
    }
    [self requestMyCollectionData];
}
#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initCollectionView{
    [self.view addSubview:self.myCollectionMenu];
    [self.view addSubview:self.myCollectionTableView];
    [self.view addSubview:self.bottomView];
}
#pragma mark -- Getters and Setters
#pragma mark  菜单栏
-(TCClickViewGroup *)myCollectionMenu{
    if (!_myCollectionMenu) {
        _myCollectionMenu=[[TCClickViewGroup alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 40) titles:@[@"商品",@"糖百科"] color:kSystemColor titleColor:kLineColor];
        _myCollectionMenu.viewDelegate=self;
    }
    return _myCollectionMenu;
}

-(UITableView *)myCollectionTableView{
    if (!_myCollectionTableView) {
        _myCollectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.myCollectionMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41) style:UITableViewStylePlain];
        _myCollectionTableView.backgroundColor = [UIColor clearColor];
        _myCollectionTableView.delegate = self;
        _myCollectionTableView.dataSource = self;
        _myCollectionTableView.showsVerticalScrollIndicator=NO;
        [_myCollectionTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _myCollectionTableView.allowsMultipleSelectionDuringEditing = YES;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCollectionData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myCollectionTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCollectionData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myCollectionTableView.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
        [_myCollectionTableView addSubview:blankView];
        blankView.hidden=YES;
    }
    return _myCollectionTableView;
}
#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        _bottomView.hidden = YES;
        
        allSelectBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
        [allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        [allSelectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [allSelectBtn setImage:[UIImage imageNamed:@"ic_pub_choose_nor"] forState:UIControlStateNormal];
        [allSelectBtn setImage:[UIImage imageNamed:@"ic_pub_choose_sel"] forState:UIControlStateSelected];
        allSelectBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
        [allSelectBtn addTarget:self action:@selector(selectAllCollectionSender:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:allSelectBtn];
        
        deleteBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 10, 80, 30)];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        deleteBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        deleteBtn.layer.borderWidth=1;
        deleteBtn.layer.cornerRadius=3;
        deleteBtn.layer.borderColor=[UIColor redColor].CGColor;
        deleteBtn.clipsToBounds=YES;
        [deleteBtn addTarget:self action:@selector(deleteCollection:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:deleteBtn];
    }
    return _bottomView;
}
- (UIView *)backGroudView{
    if (!_backGroudView) {
        _backGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        _backGroudView.backgroundColor = [UIColor whiteColor];
    }
    return _backGroudView;
}
@end
