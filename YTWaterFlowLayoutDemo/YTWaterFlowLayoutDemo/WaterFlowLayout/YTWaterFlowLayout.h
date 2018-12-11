//
//  MyFlowLayout.h
//  瀑布流实现Demo
//
//  Created by guojunwei on 2018/11/29.
//  Copyright © 2018年 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTWaterFlowLayout;
@protocol YTWaterFlowLayoutDelagate <NSObject>
/** item大小（注：UICollectionViewScrollDirectionHorizontal时，高无效；UICollectionViewScrollDirectionVertical时，宽无效） */
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForHeaderInSection:(NSInteger)section;
- (CGSize)flowLayout:(YTWaterFlowLayout *)flowLayout sizeForFooterInSection:(NSInteger)section;

/** 列数 */
- (NSInteger)columnCountInFlowLayout:(YTWaterFlowLayout *)flowLayout;
/** 行数 */
- (NSInteger)rowCountInFlowLayout:(YTWaterFlowLayout *)flowLayout;
/** 列间距 */
- (CGFloat)columnMarginInFlowLayout:(YTWaterFlowLayout *)flowLayout;
/** 行间距 */
- (CGFloat)rowMarginInFlowLayout:(YTWaterFlowLayout *)flowLayout;
/** 边缘间距 */
- (UIEdgeInsets)edgeInsetInFlowLayout:(YTWaterFlowLayout *)flowLayout;

@end



@interface YTWaterFlowLayout : UICollectionViewLayout
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, weak) id<YTWaterFlowLayoutDelagate> delegate;

@end
