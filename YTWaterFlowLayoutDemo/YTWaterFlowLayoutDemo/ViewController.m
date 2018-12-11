//
//  ViewController.m
//  YTWaterFlowLayoutDemo
//
//  Created by guojunwei on 2018/12/11.
//  Copyright © 2018年 guojunwei. All rights reserved.
//

#import "ViewController.h"
#import "YTWaterFlowLayoutViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"纵向瀑布流" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnVClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 100, 80, 80);
    [button sizeToFit];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor redColor];
    button2.titleLabel.font = [UIFont systemFontOfSize:16];
    [button2 setTitle:@"横向瀑布流" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(btnHClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(100, 200, 80, 80);
    [button2 sizeToFit];
    
}
- (void)btnVClick {
    YTWaterFlowLayoutViewController *waterVC = [YTWaterFlowLayoutViewController new];
    waterVC.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.navigationController pushViewController:waterVC animated:YES];
}
- (void)btnHClick {
    YTWaterFlowLayoutViewController *waterVC = [YTWaterFlowLayoutViewController new];
    waterVC.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.navigationController pushViewController:waterVC animated:YES];
}

@end
