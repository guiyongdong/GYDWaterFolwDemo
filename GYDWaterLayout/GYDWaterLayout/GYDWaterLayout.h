
#import <UIKit/UIKit.h>



#define GYDMyWaterLayoutKindSectionHeader @"MyWaterLayoutKindSectionHeader"
#define GYDMyWaterLayoutKindSectionFooter @"MyWaterLayoutKindSectionFooter"


@class GYDWaterLayout;
@protocol  GYDWaterLayoutDelegate<NSObject>

/**
 *  代理方法计算指定每个区有多少列
 */
- (NSInteger)waterLayoutColumNumberInSection:(NSInteger)section;

/**
 *  代理方法计算每一个item的高度
 */
- (CGFloat)waterLayoutItemHeightInIndexPath:(NSIndexPath*)indexPath;
/**
 *  代理方法计算每一个item的宽度
 */
- (CGFloat)waterLayoutItemWidthInSection:(NSInteger )section;


@optional
/**
 *  每个区的区头的大小
 *
 */
- (CGSize)waterLayoutHeaderSizeForSection:(NSInteger)section;

/**
 *  每个区的区尾的大小
 *
 */
- (CGSize)waterLayoutFooterSizeForSection:(NSInteger)section;


/**
 *  代理方法计算每个区item之间的间隙
 */
- (CGFloat)waterLayoutInterSpaceingInSection:(NSInteger)section;
/**
 *  代理方法计算每个区内边距
 */
- (UIEdgeInsets)waterLayoutSectionInsetInSection:(NSInteger)section;


@end


@interface GYDWaterLayout : UICollectionViewLayout

@property(nonatomic)id<GYDWaterLayoutDelegate> waterLayoutDelegate;


@end
