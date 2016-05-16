
#import "GYDWaterLayout.h"

@interface GYDWaterLayout ()

//指定有多少列
@property(nonatomic)NSInteger columNumber;
//指定item之间的间隙
@property(nonatomic)CGFloat   interSpaceing;
//指定每一个段的内边距
@property(nonatomic)UIEdgeInsets sectionInset;
//记录上个区的区尾的height
@property (nonatomic) CGFloat sectionHeight;
//上一个区的区尾或者最后一个item的最大y；
@property (nonatomic, assign) CGFloat lastSectionHeight;


//该数组中，包含的是每一列当前布局到的位置
@property(nonatomic)NSMutableArray *columHeightArray;
//一个区包含的位置信息
@property(nonatomic)NSMutableArray *attributesArray;
//每个区的区头位置信息
@property(nonatomic)NSMutableArray *attributesHeaderArray;
//每个区的区尾位置信息
@property(nonatomic)NSMutableArray *attributesfooterArray;
//包含每个区的位置信息
@property(nonatomic)NSMutableArray *attributesSectionArray;





@end

@implementation GYDWaterLayout

- (instancetype)init {
    if (self = [super init]) {
        self.attributesSectionArray = [NSMutableArray array];
        self.attributesArray  = [NSMutableArray array];
        self.attributesHeaderArray = [NSMutableArray array];
        self.attributesfooterArray = [NSMutableArray array];
        self.interSpaceing = 0;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}


//重新布局item
- (void)prepareLayout{
    
    NSInteger number = [self.collectionView numberOfSections];
    if (number == 0) {
        return;
    }
    //准备布局，该函数中需要把每个cell的位置信息计算出来
    [super prepareLayout];
    
    //在布局之前先清理原有的布局数据。
    [self clearAttributes];
    
    for (int section = 0; section < number; section++) {
        
        //根据代理方法初始化布局数据
        [self initDateWithDelegate:section];
        
        //先记录区头的位置信息
        [self setUpSectionHeader:section];
        
        //初始化当前区的第一行的top
        [self initColumHeightArray:section];
        
        //计算当前区的items的位置信息
        [self setUpSectionItems:section];
        
        //记录区尾的信息
        [self setUpSectionFooter:section];
        //清空上个区的item信息
        self.attributesArray = nil;
        self.attributesArray = [NSMutableArray array];
    }
}
- (void)clearAttributes {
    [self.attributesSectionArray removeAllObjects];
    [self.attributesArray removeAllObjects] ;
    [self.attributesHeaderArray removeAllObjects];
    [self.attributesfooterArray removeAllObjects];
    self.sectionHeight = 0.f;
}

- (void)initDateWithDelegate:(NSInteger) section {
    //获取列数
    self.columNumber = [self.waterLayoutDelegate waterLayoutColumNumberInSection:section];
    //初始化记录当前区每一个布局情况
    self.columHeightArray = [NSMutableArray arrayWithCapacity:self.columNumber];
    //初始化当前区的内边距
    self.sectionInset = [self.waterLayoutDelegate waterLayoutSectionInsetInSection:section];
    //初始化当前区的item间隙
    self.interSpaceing = [self.waterLayoutDelegate waterLayoutInterSpaceingInSection:section];
}

//初始化当前区的第一行的top
- (void)initColumHeightArray:(NSInteger)section {
    self.sectionHeight += self.sectionInset.top;
    for(int index = 0; index < self.columNumber;index++){
        self.columHeightArray[index] = @(self.sectionHeight);
    }
}
- (void)setUpSectionItems:(NSInteger)section {
    CGFloat itemWith = [self.waterLayoutDelegate waterLayoutItemWidthInSection:section];
    //得到section中有多少个item
    NSInteger totalItems = [self.collectionView numberOfItemsInSection:section];
    for (int index = 0; index < totalItems; index++) {
        //找到当前最短的哪一列
        NSInteger currentColumn = [self shortestColumHeight];
        //x坐标 = 当前区的内边距 + 内边距
        CGFloat xPos = self.sectionInset.left + (itemWith+self.interSpaceing)*currentColumn;
        CGFloat yPos = [self.columHeightArray[currentColumn] floatValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
        CGFloat itemHeight = [self.waterLayoutDelegate waterLayoutItemHeightInIndexPath:indexPath];
        CGRect frame = CGRectMake(xPos, yPos, itemWith, itemHeight);
        
        //UICollectionView使用UICollectionViewLayoutAttributes 记录位置信息
        UICollectionViewLayoutAttributes *atrributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        //把计算出来的frame 值进行保存
        atrributes.frame = frame;
        [self.attributesArray  addObject:atrributes];
        
        //更新当前列的y坐标
        CGFloat updateYPos = [self.columHeightArray[currentColumn] floatValue] + itemHeight+self.interSpaceing;
        self.columHeightArray[currentColumn] = @(updateYPos);
    }
    //记录上一个区的最后的位置
    NSInteger longColumn = [self longestColumnIndx];
    self.sectionHeight = [self.columHeightArray[longColumn] floatValue];
    [self.attributesSectionArray addObjectsFromArray:[self.attributesArray copy]];
}


//记录区头的信息
- (void)setUpSectionHeader:(NSInteger)section {
    if (self.waterLayoutDelegate != nil &&[self.waterLayoutDelegate respondsToSelector:@selector(waterLayoutHeaderSizeForSection:)]) {
        CGSize headSize = [self.waterLayoutDelegate waterLayoutHeaderSizeForSection:section];
        if (headSize.height == 0) {
            return;
        }
        CGRect hesderFrame = CGRectMake(0, 0 + self.sectionHeight, headSize.width, headSize.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *atrributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:GYDMyWaterLayoutKindSectionHeader withIndexPath:indexPath];
        atrributes.frame = hesderFrame;
        [self.attributesHeaderArray addObject:atrributes];
        self.sectionHeight += headSize.height;
        for (int i = 0; i < self.columNumber; i++) {
            self.columHeightArray[i] = @(self.sectionHeight);
        }
    }
}
//记录区尾的信息
- (void)setUpSectionFooter:(NSInteger)section {
    CGFloat footHeight;
    if (self.waterLayoutDelegate != nil &&[self.waterLayoutDelegate respondsToSelector:@selector(waterLayoutFooterSizeForSection:)]) {
        CGSize footSize = [self.waterLayoutDelegate waterLayoutFooterSizeForSection:section];
        if (footSize.height == 0) {
            return;
        }
        footHeight = footSize.height;
        CGRect footFrame = CGRectMake(0, self.sectionHeight, footSize.width, footSize.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *atrributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind: GYDMyWaterLayoutKindSectionFooter withIndexPath:indexPath];
        atrributes.frame = footFrame;
        [self.attributesfooterArray addObject:atrributes];
    }
    self.sectionHeight += footHeight + self.sectionInset.bottom;
}


//系统传递过来一个区域rect，我们需要返回在该区域中的item的位置信息
//返回的是一个数组，数组中包含UICollectionViewLayoutAttributes 对象
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *restulArray = [NSMutableArray array];
    
    if (self.attributesHeaderArray != nil) {
        for (UICollectionViewLayoutAttributes *attributes in self.attributesHeaderArray) {
            CGRect frame = attributes.frame;
            if (CGRectIntersectsRect(frame, rect)) {
                [restulArray addObject:attributes];
            }
        }
    }
    if (self.attributesfooterArray != nil) {
        for (UICollectionViewLayoutAttributes *attributes in self.attributesfooterArray) {
            CGRect frame = attributes.frame;
            if (CGRectIntersectsRect(frame, rect)) {
                [restulArray addObject:attributes];
            }
        }
    }
    for (UICollectionViewLayoutAttributes *attributes in self.attributesSectionArray) {
        CGRect frame = attributes.frame;
        if (CGRectIntersectsRect(frame, rect)) {
            [restulArray addObject:attributes];
        }
    }
    
    
    return restulArray;
}


//由于UICollectionVeiw继承自UIScrollView，所以需要重写该函数，告诉contentSize大小
- (CGSize)collectionViewContentSize
{
    CGFloat contentWidth = self.collectionView.bounds.size.width;
    return CGSizeMake(contentWidth, self.sectionHeight);
}
//最小的height
- (NSInteger)shortestColumHeight
{
    if (self.columHeightArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    __block CGFloat   shortestHeight = MAXFLOAT;
    
    [self.columHeightArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat heightInArray = [obj floatValue];
        if (heightInArray < shortestHeight) {
            shortestHeight = heightInArray;
            index = idx;
        }
    }];
    
    return index;
}
//最大的height
- (NSInteger)longestColumnIndx
{
    if (self.columHeightArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    __block CGFloat   longestHeight = 0;
    [self.columHeightArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat heightInArray = [obj floatValue];
        if (heightInArray > longestHeight) {
            longestHeight = heightInArray;
            index = idx;
        }
    }];
    return index;
}



@end
