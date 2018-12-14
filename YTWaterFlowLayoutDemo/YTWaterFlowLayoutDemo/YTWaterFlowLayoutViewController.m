//
//  YTWaterFlowLayoutViewController.m
//  YTWaterFlowLayoutDemo
//
//  Created by guojunwei on 2018/12/11.
//  Copyright © 2018年 guojunwei. All rights reserved.
//

#import "YTWaterFlowLayoutViewController.h"
#import "YTWaterFlowLayout.h"

@interface YTWaterFlowLayoutViewController ()<UICollectionViewDataSource, YTWaterFlowLayoutDelagate>
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation YTWaterFlowLayoutViewController
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"frame:%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    [self.collectionView.collectionViewLayout prepareLayout];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headID"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footID"];
    
    YTWaterFlowLayout *layout = (YTWaterFlowLayout *)self.collectionView.collectionViewLayout;
    layout.delegate = self;
    layout.scrollDirection = self.scrollDirection;
    [self.collectionView reloadData];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}


#pragma mark YTWaterFlowLayoutDelagate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor orangeColor];
    UILabel *label = [cell viewWithTag:100];
    if (label == nil) {
        label = [UILabel new];
        label.frame = CGRectMake(10, 10, 200, 0);
        label.numberOfLines = 0;
        [cell.contentView addSubview:label];
        label.tag = 100;
    }
    NSString *text = [NSString  stringWithFormat:@"section:%@\nrow:%@", @(indexPath.section), @(indexPath.row)];
    label.text = text;
    [label sizeToFit];
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headID" forIndexPath:indexPath];
        UILabel *label = [headView viewWithTag:100];
        if (label == nil) {
            label = [UILabel new];
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor whiteColor];
            [headView addSubview:label];
            label.numberOfLines = 0;
            label.tag = 100;
        }
        
        NSString *text = [NSString stringWithFormat:@"header---section:%@", @(indexPath.section)];
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            text = [NSString stringWithFormat:@"header\nsection:%@", @(indexPath.section)];
        }
        label.text = text;
        [label sizeToFit];
        headView.backgroundColor = [UIColor redColor];
        return headView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footID" forIndexPath:indexPath];
        UILabel *label = [footView viewWithTag:100];
        if (label == nil) {
            label = [UILabel new];
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 0;
            [footView addSubview:label];
            label.tag = 100;
        }
        NSString *text = [NSString stringWithFormat:@"footer---section:%@", @(indexPath.section)];
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            text = [NSString stringWithFormat:@"footer\nsection:%@", @(indexPath.section)];
        }
        label.text = text;
        [label sizeToFit];
        footView.backgroundColor = [UIColor grayColor];
        return footView;
    }
    return nil;
}
#pragma mark YTWaterFlowLayoutDelagate
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    CGFloat itemW = 0;
    //    CGFloat itemH = 200 + (arc4random() % 100);
    
    CGFloat itemW = 200 + (arc4random() % 100);
    CGFloat itemH = 200 + (arc4random() % 100);
    
    return CGSizeMake(itemW, itemH);
}
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(60, 60);
}
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(60, 60);
}
- (UIEdgeInsets)edgeInsetInFlowLayout:(YTWaterFlowLayout *)flowLayout {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
- (NSInteger)rowCountInFlowLayout:(YTWaterFlowLayout *)flowLayout {
    return 3;
}
- (NSInteger)columnCountInFlowLayout:(YTWaterFlowLayout *)flowLayout {
    return 10;
}
#pragma mark lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        YTWaterFlowLayout *layout = [YTWaterFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}




@end
