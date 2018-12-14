//
//  MyFlowLayout.m
//  瀑布流实现Demo
//
//  Created by guojunwei on 2018/11/29.
//  Copyright © 2018年 guojunwei. All rights reserved.
//

#import "YTWaterFlowLayout.h"

static CGFloat kColumnMargin = 10.0f;
static CGFloat kRowMargin = 10.0f;

@interface YTWaterFlowLayout ()
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes*> *layoutAttributeArray;

/** 列的高度 */
@property (nonatomic, assign) CGFloat maxColumnHeight;
@property (nonatomic, strong) NSMutableArray <NSNumber*> *columnHeightArray;
@property (nonatomic, strong) NSMutableArray <NSNumber*> *rowWidthArray;

/** 协议相关 */
@property (nonatomic, assign, readonly) NSInteger columnCount;
@property (nonatomic, assign, readonly) NSInteger rowCount;
@property (nonatomic, assign, readonly) CGFloat columnMargin;
@property (nonatomic, assign, readonly) CGFloat rowMargin;
@property (nonatomic, assign, readonly) UIEdgeInsets edgeInset;

@end

@implementation YTWaterFlowLayout
#pragma mark 代理相关
- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInFlowLayout:)]) {
        return [self.delegate columnMarginInFlowLayout:self];
    }
    return kColumnMargin;
}
- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInFlowLayout:)]) {
        return [self.delegate rowMarginInFlowLayout:self];
    }
    return kRowMargin;
}
- (NSInteger)columnCount {
    if ([self.delegate respondsToSelector:@selector(columnCountInFlowLayout:)]) {
        return [self.delegate columnCountInFlowLayout:self];
    }
    return 2;
}
- (NSInteger)rowCount {
    if ([self.delegate respondsToSelector:@selector(rowCountInFlowLayout:)]) {
        return [self.delegate rowCountInFlowLayout:self];
    }
    return 1;
}

- (UIEdgeInsets)edgeInset {
    if ([self.delegate respondsToSelector:@selector(edgeInsetInFlowLayout:)]) {
        return [self.delegate edgeInsetInFlowLayout:self];
    }
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
#pragma mark 系统方法
- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}
- (void)prepareLayout {
    [super prepareLayout];
    
    [self.layoutAttributeArray removeAllObjects];
    
    // 初始化列高集合
    NSMutableArray *columnHeightArray = @[].mutableCopy;
    for (NSInteger i = 0; i < self.columnCount; i ++) {
        [columnHeightArray addObject:@(self.edgeInset.top)];
    }
    self.columnHeightArray = columnHeightArray;
    
    // 初始化行宽集合
    NSMutableArray *rowWidthArray = @[].mutableCopy;
    for (NSInteger i = 0; i < self.rowCount; i ++) {
        [rowWidthArray addObject:@(self.edgeInset.left)];
    }
    self.rowWidthArray = rowWidthArray;
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        NSInteger rowCount = [self.collectionView numberOfItemsInSection:section];
        
        // 添加Header
        NSIndexPath *indexPath_h = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *attribute_h = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath_h];
        if (attribute_h) {
            [self.layoutAttributeArray addObject:attribute_h];
        }
        
        // 获取每条 Cell
        for (NSInteger row = 0; row < rowCount; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.layoutAttributeArray addObject:attribute];
        }
        
        // 添加Footer
        NSIndexPath *indexPath_f = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *attribute_f = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath_f];
        if (attribute_f) {
            [self.layoutAttributeArray addObject:attribute_f];
        }
        
    }
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.frame = [self itemFrameWithIndexPath:indexPath];
    return attribute;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    CGRect frame = CGRectZero;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        frame = [self headerFrameWithIndexPath:indexPath];
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        frame = [self footerFrameWithIndexPath:indexPath];
    }
    // 纵向滑动时 高度小于0.1 不显示
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical && frame.size.height <= 0.1) {
        return nil;
    }
    // 横向滑动时 宽度小于0.1 不显示
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && frame.size.width <= 0.1) {
        return nil;
    }
    
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attribute.frame = frame;
    return attribute;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributeArray;
}
- (CGSize)collectionViewContentSize {
    
    // 竖向滑动
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat maxHeight = 0;
        for (NSNumber *column in self.columnHeightArray) {
            CGFloat columnHeight =  [column doubleValue];
            maxHeight = MAX(columnHeight, maxHeight);
        }
        
        return CGSizeMake(0, maxHeight - self.edgeInset.top);
    }
    
    // 横向滑动
    else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat maxWidth = 0;
        for (NSNumber *row in self.rowWidthArray) {
            CGFloat rowWidth =  [row doubleValue];
            maxWidth = MAX(rowWidth, maxWidth);
        }
        return CGSizeMake(maxWidth - self.edgeInset.left, 0);
    }
    
    
    return CGSizeZero;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}
- (BOOL)flipsHorizontallyInOppositeLayoutDirection {
    return YES;
}

#pragma mark Helper
- (CGRect)itemFrameWithIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat collectionW = self.collectionView.frame.size.width;
    CGFloat collectionH = self.collectionView.frame.size.height;
    
    CGSize itemSize = [self.delegate flowLayout:self sizeForItemAtIndexPath:indexPath];
    CGFloat itemW = itemSize.width;
    CGFloat itemH = itemSize.height;
    
    // 内边距
    UIEdgeInsets edgeInset = self.edgeInset;
    
    //
    CGFloat itemX = edgeInset.left;
    CGFloat itemY = edgeInset.top;
    
    CGRect frame = CGRectZero;
    
    // 竖向滑动
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        itemW = (collectionW-edgeInset.left-edgeInset.right-(self.columnCount-1)*self.columnMargin)/self.columnCount;
        
        // 获取最低列的位置
        CGFloat minColumnHeight = [self.columnHeightArray.firstObject doubleValue];
        NSInteger minColumn = 0;
        for (NSInteger i = 0; i < self.columnHeightArray.count; i++) {
            CGFloat columnHeight = [self.columnHeightArray[i] doubleValue];
            if (minColumnHeight > columnHeight) {
                minColumnHeight = columnHeight;
                minColumn = i;
            }
        }
        
        // 设置item位置
        itemX = edgeInset.left + minColumn * (itemW + self.columnMargin);
        itemY = minColumnHeight;
        
        frame = CGRectMake(itemX, itemY, itemW, itemH);
        
        // 更新最低高度的
        self.columnHeightArray[minColumn] = @(CGRectGetMaxY(frame) + self.rowMargin);
        
    }
    // 横向滑动
    else {
        itemH = (collectionH-edgeInset.top-edgeInset.bottom-(self.rowCount-1)*self.rowMargin)/self.rowCount;
    
        // 获取最低列的位置
        CGFloat minRowWidth = [self.rowWidthArray.firstObject doubleValue];
        NSInteger minRow = 0;
        for (NSInteger i = 0; i < self.rowWidthArray.count; i++) {
            CGFloat rowWidth = [self.rowWidthArray[i] doubleValue];
            if (minRowWidth > rowWidth) {
                minRowWidth = rowWidth;
                minRow = i;
            }
        }
        
        // 设置item位置
        itemX = minRowWidth;
        itemY = edgeInset.top + minRow * (itemH + self.rowMargin);
        
        frame = CGRectMake(itemX, itemY, itemW, itemH);
        
        // 更新最低宽度的位置
        self.rowWidthArray[minRow] = @(CGRectGetMaxX(frame) + self.columnMargin);
    
    }
    
    return frame;
}

- (CGRect)headerFrameWithIndexPath:(NSIndexPath *)indexPath {
    
    CGSize headerSize = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(flowLayout:sizeForHeaderInSection:)]) {
        headerSize = [self.delegate flowLayout:self sizeForHeaderInSection:indexPath.section];
    }
    
    CGFloat headX = 0;
    CGFloat headY = 0;
    CGFloat headW = headerSize.width;
    CGFloat headH = headerSize.height;
    
    CGRect headFrame = CGRectZero;
    
    // 竖向滑动
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        headW = CGRectGetWidth(self.collectionView.frame);
        
        if (indexPath.section == 0) {
            headY = self.edgeInset.top;
        } else {
            for (NSInteger i = 0; i < self.columnHeightArray.count; i++) {
                CGFloat columnHeight = [self.columnHeightArray[i] doubleValue];
                headY = MAX(headY, columnHeight);
            }
        }
        
        headFrame = CGRectMake(headX, headY, headW, headH);
        for (NSInteger i = 0; i < self.columnHeightArray.count; i++) {
            self.columnHeightArray[i] = @(CGRectGetMaxY(headFrame));
        }
        
    }
    // 横向滑动
    else {
        
        headH = CGRectGetHeight(self.collectionView.frame);
        
        if (indexPath.section == 0) {
            headX = self.edgeInset.left;
        } else {
            for (NSInteger i = 0; i < self.rowWidthArray.count; i++) {
                CGFloat rowWidth = [self.rowWidthArray[i] doubleValue];
                headX = MAX(headX, rowWidth);
            }
        }
        
        headFrame = CGRectMake(headX, headY, headW, headH);
        for (NSInteger i = 0; i < self.rowWidthArray.count; i++) {
            self.rowWidthArray[i] = @(CGRectGetMaxX(headFrame));
        }
        
    }
    
    return headFrame;
    
}

- (CGRect)footerFrameWithIndexPath:(NSIndexPath *)indexPath {
    CGSize footSize = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(flowLayout:sizeForFooterInSection:)]) {
        footSize = [self.delegate flowLayout:self sizeForFooterInSection:indexPath.section];
    }
    
    CGFloat footX = 0;
    CGFloat footY = 0;
    CGFloat footW = footSize.width;
    CGFloat footH = footSize.height;
    
    CGRect footFrame = CGRectZero;
    
    // 竖向滑动
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        
        footW = CGRectGetWidth(self.collectionView.frame);
        
        for (NSInteger i = 0; i < self.columnHeightArray.count; i++) {
            CGFloat columnHeight = [self.columnHeightArray[i] doubleValue];
            footY = MAX(footY, columnHeight);
        }
        
        footY = footY - self.rowMargin;
        
        footFrame = CGRectMake(footX, footY, footW, footH);
        
        for (NSInteger i = 0; i < self.columnHeightArray.count; i++) {
            self.columnHeightArray[i] = @(CGRectGetMaxY(footFrame) + self.edgeInset.top + self.edgeInset.bottom);
        }
        
    }
    // 横向滑动
    else {
        
        footH = CGRectGetHeight(self.collectionView.frame);
        
        for (NSInteger i = 0; i < self.rowWidthArray.count; i++) {
            CGFloat rowWidth = [self.rowWidthArray[i] doubleValue];
            footX = MAX(footX, rowWidth);
        }
        
        footX = footX - self.columnMargin;
        
        footFrame = CGRectMake(footX, footY, footW, footH);
        
        for (NSInteger i = 0; i < self.rowWidthArray.count; i++) {
            self.rowWidthArray[i] = @(CGRectGetMaxX(footFrame) + self.edgeInset.left + self.edgeInset.right);
        }
        
    }
    
    
    return footFrame;
}

#pragma mark lazy
- (NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributeArray {
    if (!_layoutAttributeArray) {
        _layoutAttributeArray = @[].mutableCopy;
    }
    return _layoutAttributeArray;
}

@end
