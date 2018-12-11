//
//  ViewController.m
//  YTWaterFlowLayoutDemo
//
//  Created by guojunwei on 2018/12/11.
//  Copyright © 2018年 guojunwei. All rights reserved.
//

#import "ViewController.h"

#import "YTWaterFlowLayout.h"

@interface ViewController () <UICollectionViewDataSource, YTWaterFlowLayoutDelagate>
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor orangeColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headID"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footID"];
    
    YTWaterFlowLayout *layout = (YTWaterFlowLayout *)self.collectionView.collectionViewLayout;
    layout.delegate = self;
    [self.collectionView reloadData];
    
}

#pragma mark YTWaterFlowLayoutDelagate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
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
        headView.backgroundColor = [UIColor redColor];
        return headView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footID" forIndexPath:indexPath];
        footView.backgroundColor = [UIColor blueColor];
        return footView;
    }
    return nil;
}
#pragma mark YTWaterFlowLayoutDelagate
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    CGFloat itemW = 0;
    //    CGFloat itemH = 200 + (arc4random() % 100);
    
    CGFloat itemW = 200 + (arc4random() % 100);
    CGFloat itemH = 0;
    
    return CGSizeMake(itemW, itemH);
}
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(20, 20);
}
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(20, 20);
}
- (UIEdgeInsets)edgeInsetInFlowLayout:(YTWaterFlowLayout *)flowLayout {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
- (NSInteger)rowCountInFlowLayout:(YTWaterFlowLayout *)flowLayout {
    return 2;
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
