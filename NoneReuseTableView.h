//
//  NoneReuseTableView.h
//
//  Created by MacBook on 15/9/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface NoneReuseTableViewSection : NSObject

@property (nonatomic, readonly) UIView *sectionHeaderView;
@property (nonatomic, readonly) BOOL shouldSectionHeaderFloating;
@property (nonatomic, readonly) CGFloat sectionHeaderHeight;
@property (nonatomic, readonly) UIView *cellView;
@property (nonatomic, readonly) CGFloat cellViewHeight;

@end





/**
 *  无须重用的TabelView,对于一些无须重用cell的列表视图,适合使用该View,可以避免在didSelectRowAtIndexPath中写大量的 if else 来跳转,便于管理.也避免了UITableView复杂的使用步骤,例如注册cell重用,实现代理等.
 */

@interface NoneReuseTableView : UIView

@property (nonatomic, assign) CGFloat sectionHeight;//默认section头高度

@property (nonatomic, assign) CGFloat cellHeight;//默认cell高度


@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) NSArray <NoneReuseTableViewSection *> *allSections;

/**
 *  向视图中添加单元,每个单元可以包含一个单元头视图'sectionHeaderView'和一个单元内容视图'cellView'
 *
 *  @param sectionHeaderView           单元头视图,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param sectionHeight               单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 */
- (void)addSectionHeaderView:(UIView *)sectionHeaderView
               sectionHeight:(CGFloat)sectionHeight
 shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                    cellView:(UIView *)cellView
                  cellHeight:(CGFloat)cellHeight;
/**
 *  向视图中的指定位置插入单元
 *
 *  @param sectionHeaderView           单元头视图,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param section                     指定的位置
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                      atSection:(NSInteger)section
                       animated:(BOOL)animated;

/**
 *  将指定位置的单元移除
 *
 *  @param section  指定的位置
 *  @param animated 是否动画
 */
- (void)removeSectionAtIndex:(NSInteger)sectionIndex animated:(BOOL)animated;

/**
 *  移除全部单元
 *
 *  @param animated 是否动画
 */
- (void)removeAllSectionsAnimated:(BOOL)animated;

@end

@interface NoneReuseTableView (ViewFind)

/**
 *  查找sectionHeaderView在tableView中的位置
 *
 *  @param sectionHeaderView 单元头
 *
 *  @return 位置,未找到时返回NSNotFound
 */
- (NSInteger)indexOfSectionHeaderView:(UIView *)sectionHeaderView;

/**
 *  查找cellView在tableView中的位置
 *
 *  @param cellView 单元格
 *
 *  @return 位置,未找到时返回NSNotFound
 */
- (NSInteger)indexOfCellView:(UIView *)cellView;

/**
 *  查找指定位置的单元格
 *
 *  @param section 位置
 *
 *  @return 目标单元格,超出范围返回nil
 */
- (UIView *)cellViewAtSection:(NSInteger)section;

/**
 *  查找指定位置的单元头
 *
 *  @param section 位置
 *
 *  @return 目标单元头,超出范围返回nil
 */
- (UIView *)sectionHeaderViewAtSection:(NSInteger)section;

@end

@interface NoneReuseTableView (ConvenientAddView)

/**
 * 向视图中添加单元头
 * 由于单元头具有可以浮动的属性,因此添加单元头但不浮动的行为与添加cell没有区别,因此不提供shouldSectionHeaderFloating参数,使用此方法添加的sectionHeader一律可以浮动
 *
 *  @param sectionHeaderView 单元头视图
 *  @param sectionHeight     单元头高度
 */
- (void)addSectionHeaderView:(UIView *)sectionHeaderView
               sectionHeight:(CGFloat)sectionHeight;

/**
 *  向视图中添加单元头
 *
 *  @param sectionHeaderView 单元头视图,高度将使用默认高度,默认高度在sectionHeight修改
 */
- (void)addSectionHeaderView:(UIView *)sectionHeaderView;

/**
 *  向视图中添加不含单元头的单元格
 *
 *  @param cellView   单元格视图
 *  @param cellHeight 单元格高度
 */
- (void)addCellView:(UIView *)cellView
         cellHeight:(CGFloat)cellHeight;

/**
 *  向视图中添加不含单元头的单元格
 *
 *  @param cellView 单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 */
- (void)addCellView:(UIView *)cellView;

@end

@interface NoneReuseTableView (ResetHeight)

/**
 *  重设指定位置的单元头的高度
 *
 *  @param height   新高度
 *  @param section  位置
 *  @param animated 是否动画
 *
 *  @return 执行结果,成功则返回YES
 */
- (BOOL)resetSectionHeaderHeight:(CGFloat)height atSection:(NSInteger)section animated:(BOOL)animated;

/**
 *  重设指定位置的单元格的高度
 *
 *  @param height         新高度
 *  @param section        位置
 *  @param animated       是否动画
 *  @param scrollPosition 滚动位置
 *
 *  @return 执行结果,成功则返回YES
 */
- (BOOL)resetCellHeight:(CGFloat)height atSection:(NSInteger)section animated:(BOOL)animated atScrollPosition:(UITableViewScrollPosition)scrollPosition;

/**
 *  重设指定单元头的高度
 *
 *  @param sectionHeaderView 单元头
 *  @param height            新高度
 *  @param animated          是否动画
 *
 *  @return 执行结果,成功则返回YES
 */
- (BOOL)resetHeightOfSectionHeaderView:(UIView *)sectionHeaderView withHeight:(CGFloat)height animated:(BOOL)animated;

/**
 *  重设指定单元格的高度
 *
 *  @param cellView       单元格
 *  @param height         新高度
 *  @param animated       是否动画
 *  @param scrollPosition 滚动位置
 *
 *  @return 执行结果,成功则返回YES
 */
- (BOOL)resetHeightOfCellView:(UIView *)cellView withHeight:(CGFloat)height animated:(BOOL)animated atScrollPosition:(UITableViewScrollPosition)scrollPosition;

@end

@interface NoneReuseTableView (ConvenientInsert)

/**
 *  向指定位置插入不含单元头的单元格
 *
 *  @param cellView 单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 *  @param section  指定位置
 */
- (void)insertCellView:(UIView *)cellView atSection:(NSInteger)section;

/**
 *  向指定位置插入单元头和单元格
 *
 *  @param sectionHeaderView           单元头,高度将使用默认高度,默认高度在sectionHeight修改
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 *  @param section                     指定的位置
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                      atSection:(NSInteger)section;
@end

@interface NoneReuseTableView (ConvinientInsertAfter)

/**
 *  通过指定的单元头,在该单元后插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 *  @param animated                    是否动画
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
         afterSectionHeaderView:(UIView *)referenceSectionHeaderView
                       animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 *  @param animated                    是否动画
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                  afterCellView:(UIView *)referenceCellView
                       animated:(BOOL)animated;

/**
 *  通过指定的单元头,在该单元后插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
         afterSectionHeaderView:(UIView *)referenceSectionHeaderView;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                  afterCellView:(UIView *)referenceCellView;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param cellView          单元格
 *  @param cellHeight        单元格高度
 *  @param referenceCellView 相关的单元格
 *  @param animated          是否动画
 */
- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
         afterCellView:(UIView *)referenceCellView
              animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param cellView          单元格
 *  @param cellHeight        单元格高度
 *  @param referenceCellView 相关的单元格
 */
- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
         afterCellView:(UIView *)referenceCellView;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param cellView          单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 *  @param referenceCellView 相关的单元格
 *  @param animated          是否动画
 */
- (void)insertcellView:(UIView *)cellView
         afterCellView:(UIView *)referenceCellView
              animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元后插入单元
 *
 *  @param cellView          单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 *  @param referenceCellView 相关的单元格
 */
- (void)insertcellView:(UIView *)cellView
         afterCellView:(UIView *)referenceCellView;

@end


@interface NoneReuseTableView (ConvinientInsertBefore)

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 *  @param animated                    是否动画
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
        beforeSectionHeaderView:(UIView *)referenceSectionHeaderView
                       animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 *  @param animated                    是否动画
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                 beforeCellView:(UIView *)referenceCellView
                       animated:(BOOL)animated;

/**
 *  通过指定的单元头,在该单元前插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
        beforeSectionHeaderView:(UIView *)referenceSectionHeaderView;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param sectionHeaderView           单元头
 *  @param headerHeight                单元头高度
 *  @param shouldSectionHeaderFloating 是否需要浮动,表现类似与UITableView的单元头
 *  @param cellView                    单元格,可以为nil,为nil时,高度无效,高度将被置为0
 *  @param cellHeight                  单元格高度
 *  @param referenceSectionHeaderView  相关的单元头
 */
- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                 beforeCellView:(UIView *)referenceCellView;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param cellView          单元格
 *  @param cellHeight        单元格高度
 *  @param referenceCellView 相关的单元格
 *  @param animated          是否动画
 */
- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
        beforeCellView:(UIView *)referenceCellView
              animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param cellView          单元格
 *  @param cellHeight        单元格高度
 *  @param referenceCellView 相关的单元格
 */

- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
        beforeCellView:(UIView *)referenceCellView;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param cellView          单元格
 *  @param referenceCellView 相关的单元格
 *  @param animated          是否动画
 */
- (void)insertcellView:(UIView *)cellView
        beforeCellView:(UIView *)referenceCellView
              animated:(BOOL)animated;

/**
 *  通过指定的单元格,在该单元前插入单元
 *
 *  @param cellView          单元格视图,高度将使用默认高度,默认高度在cellHeight修改
 *  @param referenceCellView 相关的单元格
 */
- (void)insertcellView:(UIView *)cellView
        beforeCellView:(UIView *)referenceCellView;
@end




