//
//  TCDynamicImageCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//  发布动态图片

#import "TCDynamicImageCell.h"
#import "TCReleaseDynamicCell.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"



@interface TCDynamicImageCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate>
{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    CGFloat _itemWH ;
}
@property (strong, nonatomic) UICollectionView *mediaView;

@end

@implementation TCDynamicImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        _selectedAssets = [NSMutableArray array];
        _selectedPhotos = [NSMutableArray array];
        [self setupCollectionView];
    }
    return self;
}
#pragma mark ====== 布局 UI =======

- (void)setupCollectionView{
    
    _itemWH = (kScreenWidth - 40)/4;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);//上左下右
    
    self.mediaView = [[UICollectionView alloc]initWithFrame:CGRectMake(20, 16 , kScreenWidth - 40 ,[self updataCollectionViewHight]) collectionViewLayout:layout];
    self.mediaView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.mediaView.scrollEnabled = NO;
    self.mediaView.backgroundColor = [UIColor whiteColor];
    [self.mediaView registerClass:[TCReleaseDynamicCell class] forCellWithReuseIdentifier:@"TCReleaseDynamicCell"];
    self.mediaView.dataSource = self;
    self.mediaView.delegate = self;
    [self.contentView addSubview:self.mediaView];
}
#pragma mark ====== 更新CollectionView 高度 =======

- (CGFloat)updataCollectionViewHight{
    
    return  _selectedPhotos.count  / 4  * ( _itemWH ) + _itemWH + 16;
}
#pragma mark ====== UICollectionViewDelegate =======
#pragma mark ====== UICollectionViewDataSource =======

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_selectedPhotos.count == 9) {
        return _selectedPhotos.count;
    }else{
        return  _selectedPhotos.count + 1;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TCReleaseDynamicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TCReleaseDynamicCell" forIndexPath:indexPath];
    
    if (indexPath.row == _selectedPhotos.count && _selectedPhotos.count != 9) {
        cell.imageView.image = [UIImage imageNamed:@"ic_frame_add"];
        cell.deleteBtn.hidden = YES;
    } else {
        UIImage *photoImg = _selectedPhotos[indexPath.row];
        cell.imageView.image = [photoImg imageCompressForSize:photoImg targetSize:CGSizeMake(_itemWH, _itemWH)];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        if ([self.delegate respondsToSelector:@selector(didSelectImgeAction:indexRow:)]) {
            [_delegate didSelectImgeAction:1000 indexRow:indexPath.row];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(didSelectImgeAction:indexRow:)]) {
            [_delegate didSelectImgeAction:1001 indexRow:indexPath.row];
        }
    }
}
#pragma mark --- 删除图片 ---
- (void)deleteBtnClik:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(reloadTableViewWithRemovePhotoArrayIndex:)]) {
        [_delegate reloadTableViewWithRemovePhotoArrayIndex:sender.tag];
    }
}
#pragma mark ====== 赋值图片 =======

- (void)cellWithImageArray:(NSMutableArray *)imageArray selectedAssets:(NSMutableArray *)selectedAssets{
    _selectedPhotos = imageArray;
    _selectedAssets = selectedAssets;
    self.mediaView.frame = CGRectMake(20, 8, kScreenWidth - 40 ,[self updataCollectionViewHight]);
    [_mediaView reloadData];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
