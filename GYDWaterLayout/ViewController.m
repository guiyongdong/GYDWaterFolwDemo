//
//  ViewController.m
//  GYDWaterLayout
//
//  Created by 贵永冬 on 16/5/13.
//  Copyright © 2016年 贵永冬. All rights reserved.
//

#import "ViewController.h"
#import "GYDWaterLayout.h"
#import "YYFPSLabel.h"

@interface ViewController ()<GYDWaterLayoutDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSoure;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    
    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(10, 200, 80, 80)];
    [self.view addSubview:label];
    
    
}

- (NSMutableArray *)dataSoure {
    if (!_dataSoure) {
        _dataSoure = [NSMutableArray array];
        for (int i = 0 ; i < 30; i++) {
            int y = (arc4random() % 151) + 50;
            [_dataSoure addObject:@(y)];
        }
    }
    return _dataSoure;
}



/**
 *  瀑布流
 */
- (void)setupCollectionView {
    
    GYDWaterLayout *layout   = [[GYDWaterLayout alloc] init];
    layout.waterLayoutDelegate = self;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:GYDMyWaterLayoutKindSectionHeader withReuseIdentifier:@"headerId"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:GYDMyWaterLayoutKindSectionFooter withReuseIdentifier:@"footerId"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSoure.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:GYDMyWaterLayoutKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerId" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor redColor];
        return headerView;
    }
    if ([kind isEqualToString:GYDMyWaterLayoutKindSectionFooter]) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerId" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor yellowColor];
        return footerView;
    }
    
    return nil;
}


#pragma mark - GYDWaterLayoutDelegate


/**
 *  代理方法计算有几个区
 */
- (NSInteger)waterLayoutSectionNumber {
    return 3;
}
/**
 *  代理方法计算每个区有几个
 */
- (NSInteger)waterLayoutItemNumberInSection:(NSInteger)section {
    return self.dataSoure.count;
}
/**
 *  代理方法计算指定每个区有多少列
 */
- (NSInteger)waterLayoutColumNumberInSection:(NSInteger)section {
    return section+1;
}

/**
 *  代理方法计算每个区item之间的间隙
 */
- (CGFloat)waterLayoutInterSpaceingInSection:(NSInteger)section {
    return 10;
}
/**
 *  代理方法计算每个区内边距
 */
- (UIEdgeInsets)waterLayoutSectionInsetInSection:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}


/**
 *  代理方法计算每一个item的高度
 */
- (CGFloat)waterLayoutItemHeightInIndexPath:(NSIndexPath*)indexPath {
    return [self.dataSoure[indexPath.row] doubleValue];
}
/**
 *  代理方法计算每一个item的宽度
 */
- (CGFloat)waterLayoutItemWidthInSection:(NSInteger )section {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    return (width - (section +2)*10)/(section +1);
}



/**
 *  每个区的区头的大小
 *
 */
- (CGSize)waterLayoutHeaderSizeForSection:(NSInteger)section {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(width, 50*section);
}

/**
 *  每个区的区尾的大小
 *
 */
- (CGSize)waterLayoutFooterSizeForSection:(NSInteger)section {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(width, 50*section);
}





@end
