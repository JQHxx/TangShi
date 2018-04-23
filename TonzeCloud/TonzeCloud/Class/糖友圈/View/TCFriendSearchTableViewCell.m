//
//  TCFriendSearchTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFriendSearchTableViewCell.h"

@implementation TCFriendSearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 14, 20, 20)];
        headImg.image = [UIImage imageNamed:@"pub_ic_lite_time"];
        [self.contentView addSubview:headImg];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, 14, kScreenWidth-headImg.right-70, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        [self.contentView addSubview:_nameLabel];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 9, 50, 30)];
        [deleteBtn setImage:[UIImage imageNamed:@"pub_friend_del"] forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}

- (void)deleteButton{
    
    if ([_deleteSearchDelegate respondsToSelector:@selector(deleteSerachHistory:)]) {
        [_deleteSearchDelegate deleteSerachHistory:_nameLabel.text];
    }
    
}
@end
