//
//  ImageViewController.m
//  PushImageTest
//
//  Created by Eva on 17/4/10.
//  Copyright © 2017年 Eva. All rights reserved.
//

#import "ImageViewController.h"
#import "ETapScrollView.h"

@interface ImageViewController ()<ETapScrollViewDelegate>
@property (nonatomic,strong)ETapScrollView * bigImageView;

@end

@implementation ImageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.bigImageView];
    [_bigImageView setTapViewWithImage:_imageArray isUrlImage:_imageArray index:self.index];
}
#pragma mark - ETapScrollViewDelegate
- (void)disMissController {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark - setter && getter
- (ETapScrollView *)bigImageView {
    if (!_bigImageView) {
        _bigImageView = [[ETapScrollView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height )];
        _bigImageView.center = self.view.center;
        _bigImageView.backgroundColor = [UIColor blackColor];
        _bigImageView.ETapDelegate = self;
    }
    return _bigImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
