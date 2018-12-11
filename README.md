## iOS瀑布流的实现

#### 背景

近期公司启动了Pad项目，项目中大部分的功能实现都是基于CollectionView实现的，并且cell的高是动态变化的，因此对瀑布流的实现做了些研究。

#### 原理

看了下 UICollectionViewLayout 布局的方法列表，发现最终还是对其中的四个分类方法进行重写

```
// 1.CollectionView的所有布局
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;

// 2.每个Item的布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

// 3.每个Section的头和尾布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

// 4.整个CollectionView的ContentSize
- (CGSize)collectionViewContentSize;
```

#### 实现步骤

1、系统方法实现

```
#pragma mark 系统方法
- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        // 布局的数组
        self.layoutAttributeArray = @[].mutableCopy;
    }
    return self;
}
- (void)prepareLayout {
    [super prepareLayout];
    
    [self.layoutAttributeArray removeAllObjects];
    
    // 初始化列高集合(记录纵向滑动的最下侧位置)
    NSMutableArray *columnHeightArray = @[].mutableCopy;
    for (NSInteger i = 0; i < self.columnCount; i ++) {
        [columnHeightArray addObject:@(self.edgeInset.top)];
    }
    self.columnHeightArray = columnHeightArray;
    
    // 初始化行宽集合(记录横向滑动的最右侧位置)
    NSMutableArray *rowWidthArray = @[].mutableCopy;
    for (NSInteger i = 0; i < self.rowCount; i ++) {
        [rowWidthArray addObject:@(self.edgeInset.left)];
    }
    self.rowWidthArray = rowWidthArray;
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        // 添加Header
        if ([self.delegate respondsToSelector:@selector(flowLayout:sizeForHeaderInSection:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            if (attribute) {
                [self.layoutAttributeArray addObject:attribute];
            }
        }
        
        NSInteger rowCount = [self.collectionView numberOfItemsInSection:section];
        // 获取每条 Cell
        for (NSInteger row = 0; row < rowCount; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.layoutAttributeArray addObject:attribute];
        }
        
        // 添加Footer
        if ([self.delegate respondsToSelector:@selector(flowLayout:sizeForFooterInSection:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
            if (attribute) {
                [self.layoutAttributeArray addObject:attribute];
            }
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
```


2、布局方法实现

```
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
```

3、协议方法实现

```
- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInFlowLayout:)]) {
        return [self.delegate columnMarginInFlowLayout:self];
    }
    return 10.0f; // 默认列间距
}
- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInFlowLayout:)]) {
        return [self.delegate rowMarginInFlowLayout:self];
    }
    return 10.0f; // 默认行间距
}
- (NSInteger)columnCount {
    if ([self.delegate respondsToSelector:@selector(columnCountInFlowLayout:)]) {
        return [self.delegate columnCountInFlowLayout:self];
    }
    return 2; // 默认列数 
}
- (NSInteger)rowCount {
    if ([self.delegate respondsToSelector:@selector(rowCountInFlowLayout:)]) {
        return [self.delegate rowCountInFlowLayout:self];
    }
    return 1; // 默认行数
}

- (UIEdgeInsets)edgeInset {
    if ([self.delegate respondsToSelector:@selector(edgeInsetInFlowLayout:)]) {
        return [self.delegate edgeInsetInFlowLayout:self];
    }
    return UIEdgeInsetsMake(10, 10, 10, 10); // 默认内边距
}
```

#### 总结
以上就是我对于瀑布流做的一个简单的实现，具体实现见[Demo](https://github.com/SoftBoys/YTWaterFlowLayoutDemo)，支持横向滑动和纵向滑动两种布局方式，有兴趣的朋友欢迎留言讨论，大家一起学习
