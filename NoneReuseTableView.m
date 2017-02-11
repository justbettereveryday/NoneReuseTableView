//
//  NoneReuseTableView.m
//
//  Created by MacBook on 15/9/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import "NoneReuseTableView.h"
#import <Masonry.h>

@interface NoneReuseTableViewSection ()

@property (nonatomic, strong, readwrite) UIView *sectionHeaderView;
@property (nonatomic, assign, readwrite) BOOL shouldSectionHeaderFloating;
@property (nonatomic, strong, readwrite) UIView *sectionHeightLayoutGuide;
@property (nonatomic, strong, readwrite) MASConstraint *sectionHeightConstraint;
@property (nonatomic, assign, readwrite) CGFloat sectionHeaderHeight;
@property (nonatomic, strong, readwrite) UIView *cellView;
@property (nonatomic, strong, readwrite) MASConstraint *cellHeightConstraint;
@property (nonatomic, assign, readwrite) CGFloat cellViewHeight;

- (void)removeFromSuperview;

@end

@implementation NoneReuseTableViewSection

- (void)removeFromSuperview{
    [self.sectionHeaderView removeFromSuperview];
    [self.cellView removeFromSuperview];
    [self.sectionHeightLayoutGuide removeFromSuperview];
}

@end

static NSTimeInterval const animationDuration = 0.3;

@interface NoneReuseTableView ()

@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIView *contentView;

@property (nonatomic, strong) NSMutableArray <NoneReuseTableViewSection *> *sections;

@property (nonatomic, strong) MASConstraint *scrollViewBottomConstraint;

@end

@implementation NoneReuseTableView


- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sectionHeight = 44;
        self.cellHeight = 44;
        [self setupView];
    }
    return self;
}

- (void)setupView{
    
    UIScrollView *scrollView = [UIScrollView new];
    self.scrollView = scrollView;
    scrollView.clipsToBounds = YES;
    scrollView.alwaysBounceVertical = YES;
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView.superview);
    }];
    
    UIView *contentView = [UIView new];
    self.contentView = contentView;
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(contentView.superview);
    }];
    
}

#pragma mark - Public Method

- (void)addSectionHeaderView:(UIView *)sectionHeaderView
               sectionHeight:(CGFloat)sectionHeight
 shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                    cellView:(UIView *)cellView
                  cellHeight:(CGFloat)cellHeight{
    
    NSInteger lastIndex = self.sections.count;
    [self insertSectionHeaderView:sectionHeaderView headerHeight:sectionHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight atSection:lastIndex  animated:NO];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                      atSection:(NSInteger)sectionIndex
                       animated:(BOOL)animated{
    
    //不能都为空
    if (!sectionHeaderView && !cellView) {
        return;
    }
    
    //已经在tableView中的单元头不能在被插入
    if ([self indexOfSectionHeaderView:sectionHeaderView] != NSNotFound) {
        return;
    }
    //已经在tableView中的单元格不能在被插入
    if ([self indexOfCellView:cellView] != NSNotFound) {
        return;
    }
    //高度不能小于0
    headerHeight = headerHeight<0?0:headerHeight;
    cellHeight = cellHeight<0?0:cellHeight;
    
    //单元头为空时,构造placeHolder
    if (!sectionHeaderView) {
        sectionHeaderView = [UIView new];
        sectionHeaderView.hidden = YES;
        headerHeight = 0;
    }
    
    //单元格为空时,构造placeHolder
    if (!cellView) {
        cellView = [UIView new];
        cellView.hidden = YES;
        cellHeight = 0;
    }
    
    UIView *contentView = self.contentView;
    
    NSMutableArray *sections = self.sections;
    
    if (sectionIndex > -1 && sectionIndex <= sections.count) {
        
        CGFloat sectionHeaderViewAlpha = sectionHeaderView.alpha;
        CGFloat cellViewAlpha = cellView.alpha;
        if (animated) {
            sectionHeaderView.alpha = 0;
            cellView.alpha = 0;
        }
        
        NSInteger previousSectionIndex = sectionIndex - 1;
        NSInteger nextSectionIndex = sectionIndex + 1;
        
        NoneReuseTableViewSection *targetSection = [NoneReuseTableViewSection new];
        targetSection.sectionHeaderView = sectionHeaderView;
        targetSection.sectionHeaderHeight = headerHeight;
        targetSection.shouldSectionHeaderFloating = shouldSectionHeaderFloating;
        targetSection.cellView = cellView;
        targetSection.cellViewHeight = cellHeight;
        [sections insertObject:targetSection atIndex:sectionIndex];
        
        NoneReuseTableViewSection *previousSection = previousSectionIndex > -1?sections[previousSectionIndex]:nil;
        
        NoneReuseTableViewSection *nextSection = nextSectionIndex < sections.count?sections[nextSectionIndex]:nil;
        
        UIView *sectionHeightLayoutGuide = [UIView new];
        sectionHeightLayoutGuide.hidden = YES;
        targetSection.sectionHeightLayoutGuide = sectionHeightLayoutGuide;
        [contentView addSubview:sectionHeightLayoutGuide];
        [sectionHeightLayoutGuide mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(previousSection?previousSection.cellView.mas_bottom:contentView);
            make.left.equalTo(contentView);
            make.width.equalTo(@0);
            targetSection.sectionHeightConstraint = make.height.equalTo(@(headerHeight));
        }];
        
        [contentView addSubview:cellView];
        [cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(contentView);
            targetSection.cellHeightConstraint = make.height.equalTo(@(cellHeight));
            make.top.equalTo(sectionHeightLayoutGuide.mas_bottom);
            if (!nextSection) {
                [self resetScrollViewBottom:make];
            }
        }];
        
        [contentView addSubview:sectionHeaderView];
        [sectionHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(sectionHeightLayoutGuide);
            make.left.right.equalTo(contentView);
            make.top.equalTo(sectionHeightLayoutGuide).priority(996);
            make.top.greaterThanOrEqualTo(previousSection?sectionHeightLayoutGuide:contentView).priority(998);
            make.bottom.lessThanOrEqualTo(cellView).priority(999);
            if (shouldSectionHeaderFloating) {
                [self makeHeaderViewFloatingConstrait:make];
            }
        }];
        
        [self layoutIfNeeded];
        
        [nextSection.sectionHeightLayoutGuide mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cellView.mas_bottom);
            make.left.equalTo(contentView);
            make.width.equalTo(@0);
            nextSection.sectionHeightConstraint = make.height.equalTo(@(nextSection.sectionHeaderHeight));
        }];
        
        [nextSection.sectionHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(nextSection.sectionHeightLayoutGuide);
            make.left.right.equalTo(contentView);
            make.top.equalTo(nextSection.sectionHeightLayoutGuide).priority(996);
            make.top.greaterThanOrEqualTo(nextSection.sectionHeightLayoutGuide).priority(998);
            make.bottom.lessThanOrEqualTo(nextSection.cellView).priority(999);
            if (nextSection.shouldSectionHeaderFloating) {
                [self makeHeaderViewFloatingConstrait:make];
            }
        }];
        
        if (animated) {
            [UIView animateWithDuration:animationDuration animations:^{
                sectionHeaderView.alpha = sectionHeaderViewAlpha;
                cellView.alpha = cellViewAlpha;
                [self layoutIfNeeded];
            }];
        }
    }
}

- (void)removeSectionAtIndex:(NSInteger)sectionIndex animated:(BOOL)animated{
    
    UIView *contentView = self.contentView;
    
    NSMutableArray *sections = self.sections;
    
    if (sectionIndex < sections.count && sectionIndex > -1) {
        //目标比总数小 可以执行删除
        NSInteger previousSectionIndex = sectionIndex - 1;
        NSInteger nextSectionIndex = sectionIndex + 1;
        
        NoneReuseTableViewSection *targetSection = sections[sectionIndex];
        NoneReuseTableViewSection *previousSection;
        NoneReuseTableViewSection *nextSection;
        
        if (previousSectionIndex > -1) {
            previousSection = sections[previousSectionIndex];
        }
        
        if (nextSectionIndex == sections.count){
            //删除的是最后一个,需要对前一个更新底边约束
            [previousSection.cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(contentView);
                previousSection.cellHeightConstraint = make.height.equalTo(@(previousSection.cellViewHeight));
                make.top.equalTo(previousSection.sectionHeightLayoutGuide.mas_bottom);
                [self resetScrollViewBottom:make];
            }];
        }
        else{
            //删除的是中间的,需要对前后进行拼接
            nextSection = sections[nextSectionIndex];
            [nextSection.sectionHeightLayoutGuide mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(previousSection?previousSection.cellView.mas_bottom:contentView);
                make.left.equalTo(contentView);
                make.width.equalTo(@0);
                nextSection.sectionHeightConstraint = make.height.equalTo(@(nextSection.sectionHeaderHeight));
            }];
            
            [nextSection.sectionHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(nextSection.sectionHeightLayoutGuide);
                make.left.right.equalTo(contentView);
                make.top.equalTo(nextSection.sectionHeightLayoutGuide).priority(996);
                make.top.greaterThanOrEqualTo(previousSection?previousSection.cellView.mas_bottom:contentView).priority(998);
                make.bottom.lessThanOrEqualTo(nextSection.cellView).priority(999);
                if (nextSection.shouldSectionHeaderFloating) {
                    [self makeHeaderViewFloatingConstrait:make];
                }
            }];
        }
        
        if (animated) {
            [contentView sendSubviewToBack:targetSection.sectionHeaderView];
            [contentView sendSubviewToBack:targetSection.cellView];
            
            CGFloat sectionHeaderViewAlpha = targetSection.sectionHeaderView.alpha;
            CGFloat cellViewAlpha = targetSection.cellView.alpha;
            
            [UIView animateWithDuration:animationDuration animations:^{
                targetSection.sectionHeaderView.alpha = 0;
                targetSection.cellView.alpha = 0;
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                targetSection.sectionHeaderView.alpha = sectionHeaderViewAlpha;
                targetSection.cellView.alpha = cellViewAlpha;
                [targetSection removeFromSuperview];
            }];
        }
        else{
            [targetSection removeFromSuperview];
        }
        
        [self.sections removeObject:targetSection];
    }
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    while (self.sections.count) {
        [self removeSectionAtIndex:0 animated:animated];
    }
}

- (NSArray <NoneReuseTableViewSection *> *)allSections{
    return [self.sections copy];
}

#pragma mark - Private Method

- (void)resetScrollViewBottom:(MASConstraintMaker *)make{
    [self.scrollViewBottomConstraint uninstall];
    self.scrollViewBottomConstraint = make.bottom.equalTo(self.contentView).priority(999);
}

- (void)makeHeaderViewFloatingConstrait:(MASConstraintMaker *)make{
    if (self.contentView.superview == self.scrollView) {
        make.top.equalTo(self).priority(997);
    }
}

#pragma mark - Lazy Property

- (NSMutableArray *)sections{
    return _sections?:({ _sections = [NSMutableArray new];});
}

#pragma mark - Debug

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}


@end

@implementation NoneReuseTableView (ViewFind)

- (NSInteger)indexOfSectionHeaderView:(UIView *)sectionHeaderView{
    for (NoneReuseTableViewSection *section in self.sections) {
        if (section.sectionHeaderView == sectionHeaderView) {
            return [self.sections indexOfObject:section];
        }
    }
    return NSNotFound;
}

- (NSInteger)indexOfCellView:(UIView *)cellView{
    for (NoneReuseTableViewSection *section in self.sections) {
        if (section.cellView == cellView) {
            return [self.sections indexOfObject:section];
        }
    }
    return NSNotFound;
}

- (UIView *)cellViewAtSection:(NSInteger)section{
    if (section < self.sections.count) {
        return self.sections[section].cellView;
    }
    return nil;
}

- (UIView *)sectionHeaderViewAtSection:(NSInteger)section{
    if (section < self.sections.count) {
        return self.sections[section].sectionHeaderView;
    }
    return nil;
}

@end

@implementation NoneReuseTableView (ConvenientAddView)

- (void)addSectionHeaderView:(UIView *)sectionHeaderView
               sectionHeight:(CGFloat)sectionHeight{
    if (!sectionHeaderView) {
        return;
    }
    [self addSectionHeaderView:sectionHeaderView sectionHeight:sectionHeight shouldSectionHeaderFloating:YES cellView:nil cellHeight:0];
}

- (void)addSectionHeaderView:(UIView *)sectionHeaderView{
    [self addSectionHeaderView:sectionHeaderView sectionHeight:self.sectionHeight];
}

- (void)addCellView:(UIView *)cellView
         cellHeight:(CGFloat)cellHeight{
    if (!cellView) {
        return;
    }
    [self addSectionHeaderView:nil sectionHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:cellHeight];
}

- (void)addCellView:(UIView *)cellView{
    [self addCellView:cellView cellHeight:self.cellHeight];
}

@end











@implementation NoneReuseTableView (ResetHeight)

- (BOOL)resetHeightOfSectionHeaderView:(UIView *)sectionHeaderView withHeight:(CGFloat)height animated:(BOOL)animated{
    NSInteger index = [self indexOfSectionHeaderView:sectionHeaderView];
    if (index == NSNotFound) {
        //NSLog(@"sectionHeaderView未找到");
        return NO;
    }
    return [self resetSectionHeaderHeight:height atSection:index animated:animated];
}

- (BOOL)resetHeightOfCellView:(UIView *)cellView withHeight:(CGFloat)height animated:(BOOL)animated atScrollPosition:(UITableViewScrollPosition)scrollPosition{
    NSInteger index = [self indexOfCellView:cellView];
    if (index == NSNotFound) {
        //NSLog(@"cellView未找到");
        return NO;
    }
    return [self resetCellHeight:height atSection:index animated:animated atScrollPosition:scrollPosition];
}

- (BOOL)resetSectionHeaderHeight:(CGFloat)height atSection:(NSInteger)section animated:(BOOL)animated{
    
    if (section < 0 || section > self.sections.count) {
        return NO;
    }
    
    NoneReuseTableViewSection *sectionObj = self.sections[section];
    
    if (sectionObj.sectionHeaderHeight == height && !animated) {
        return YES;
    }
    
    id obj = sectionObj.sectionHeightConstraint;
    
    if ([obj isKindOfClass:[MASConstraint class]]) {
        MASConstraint *heightConstraint = (MASConstraint *)obj;
        heightConstraint.equalTo(@(height));
        sectionObj.sectionHeaderHeight = height;
        if (animated) {
            [UIView animateWithDuration:animationDuration animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                ;
            }];
        }
        return YES;
    }
    return NO;
}

- (BOOL)resetCellHeight:(CGFloat)height atSection:(NSInteger)section animated:(BOOL)animated atScrollPosition:(UITableViewScrollPosition)scrollPosition{
    if (section < 0 || section > self.sections.count) {
        return NO;
    }
    
    NoneReuseTableViewSection *sectionObj = self.sections[section];
    
    if (sectionObj.cellViewHeight == height && !animated && scrollPosition == UITableViewScrollPositionNone) {
        return YES;
    }
    
    id obj = sectionObj.cellHeightConstraint;
    
    if ([obj isKindOfClass:[MASConstraint class]]) {
        MASConstraint *heightConstraint = (MASConstraint *)obj;
        
        UIScrollView *scrollView = self.scrollView;
        
        UIView *sectionView = sectionObj.sectionHeaderView;
        UIView *cellView = sectionObj.cellView;
        //视图高度
        CGFloat scrollViewHeight = scrollView.frame.size.height;
        //内容高度
        CGFloat contentHeight = scrollView.contentSize.height;
        //表头坐标
        CGRect sectionFrame = sectionView.frame;
        //表头高度
        CGFloat sectionHeight = sectionFrame.size.height;
        //原始Cell坐标
        CGRect cellFrame = cellView.frame;
        //原始cell高度
        CGFloat cellHeight = cellFrame.size.height;
        //原Cell的y点
        CGFloat Y = cellFrame.origin.y;
        //原Cell应在Y点(需要减去表头高度)
        CGFloat shouldY = Y - sectionHeight;
        //新内容长度
        CGFloat newContentHeight = contentHeight - cellHeight + height;
        //新旧cell高度差
        CGFloat cellHeightDiff = height - cellHeight;
        //新Cell距离底部距离
        CGFloat newCellToBottom = newContentHeight - shouldY;
        //新偏移
        CGPoint newOffset = scrollView.contentOffset;
        
        switch (scrollPosition) {
            case UITableViewScrollPositionMiddle:
            case UITableViewScrollPositionNone: {
                //内容偏移
                CGFloat contentViewOffsetY = scrollView.contentOffset.y;
                //原始cell底部
                CGFloat cellBottom = Y + cellHeight;
                //如果原始cell已滚出屏幕,为了不影响当前内容,新offset应为当前正在展示的offset
                if (cellBottom < contentViewOffsetY) {
                    newOffset = CGPointMake(0, contentViewOffsetY + cellHeightDiff);
                }
                
                break;
            }
            case UITableViewScrollPositionTop: {
                if (newCellToBottom > scrollViewHeight) {
                    newOffset = CGPointMake(0, shouldY);
                }
                else if (newContentHeight > scrollViewHeight){
                    newOffset = CGPointMake(0, newContentHeight - scrollViewHeight);
                }
                break;
            }
            case UITableViewScrollPositionBottom: {
                //表头bottom
                CGFloat sectionBottom = Y + sectionHeight;
                if (sectionBottom > scrollViewHeight) {
                    newOffset = CGPointMake(0, Y - scrollViewHeight);
                }
                break;
            }
        }
        
        if (animated) {
            heightConstraint.equalTo(@(height));
            [UIView animateWithDuration:animationDuration animations:^{
                scrollView.contentOffset = newOffset;
                [self layoutIfNeeded];
            } completion:NULL];
        }
        else{
            heightConstraint.equalTo(@(height));
            scrollView.contentOffset = newOffset;
        }
        sectionObj.cellViewHeight = height;
        return YES;
    }
    return NO;
}

@end










@implementation NoneReuseTableView (ConvenientInsert)

- (void)insertCellView:(UIView *)cellView atSection:(NSInteger)section{
    [self insertSectionHeaderView:nil shouldSectionHeaderFloating:NO cellView:cellView atSection:section];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating cellView:(UIView *)cellView atSection:(NSInteger)section{
    [self insertSectionHeaderView:sectionHeaderView headerHeight:self.sectionHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:self.cellHeight atSection:section animated:NO];
}

@end













@implementation NoneReuseTableView (ConvinientInsertAfter)

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
         afterSectionHeaderView:(UIView *)referenceSectionHeaderView
                       animated:(BOOL)animated{
    NSInteger referenceSectionHeaderViewSectionIndex = [self indexOfSectionHeaderView:referenceSectionHeaderView];
    if (referenceSectionHeaderViewSectionIndex == NSNotFound) {
        return;
    }
    NSInteger targetSectionIndex = referenceSectionHeaderViewSectionIndex + 1;
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight atSection:targetSectionIndex animated:animated];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                  afterCellView:(UIView *)referenceCellView
                       animated:(BOOL)animated{
    
    NSInteger referenceCellViewSectionIndex = [self indexOfCellView:referenceCellView];
    if (referenceCellViewSectionIndex == NSNotFound) {
        return;
    }
    NSInteger targetSectionIndex = referenceCellViewSectionIndex + 1;
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight atSection:targetSectionIndex animated:animated];
}


- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
         afterSectionHeaderView:(UIView *)referenceSectionHeaderView{
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight afterSectionHeaderView:referenceSectionHeaderView animated:NO];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                  afterCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight afterCellView:referenceCellView animated:NO];
}

- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
         afterCellView:(UIView *)referenceCellView
              animated:(BOOL)animated{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:cellHeight afterCellView:referenceCellView animated:animated];
}

- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
         afterCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:cellHeight afterCellView:referenceCellView animated:NO];
}


- (void)insertcellView:(UIView *)cellView
         afterCellView:(UIView *)referenceCellView
              animated:(BOOL)animated{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:self.cellHeight afterCellView:referenceCellView animated:animated];
}


- (void)insertcellView:(UIView *)cellView
         afterCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:self.cellHeight afterCellView:referenceCellView animated:NO];
}

@end











@implementation NoneReuseTableView (ConvinientInsertBefore)

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
        beforeSectionHeaderView:(UIView *)referenceSectionHeaderView
                       animated:(BOOL)animated{
    NSInteger referenceSectionHeaderViewSectionIndex = [self indexOfSectionHeaderView:referenceSectionHeaderView];
    if (referenceSectionHeaderViewSectionIndex == NSNotFound) {
        return;
    }
    NSInteger targetSectionIndex = referenceSectionHeaderViewSectionIndex;
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight atSection:targetSectionIndex animated:animated];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                 beforeCellView:(UIView *)referenceCellView
                       animated:(BOOL)animated{
    
    NSInteger referenceCellViewSectionIndex = [self indexOfCellView:referenceCellView];
    if (referenceCellViewSectionIndex == NSNotFound) {
        return;
    }
    NSInteger targetSectionIndex = referenceCellViewSectionIndex;
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight atSection:targetSectionIndex animated:animated];
}

- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
        beforeSectionHeaderView:(UIView *)referenceSectionHeaderView{
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight beforeSectionHeaderView:referenceSectionHeaderView animated:NO];
}



- (void)insertSectionHeaderView:(UIView *)sectionHeaderView
                   headerHeight:(CGFloat)headerHeight
    shouldSectionHeaderFloating:(BOOL)shouldSectionHeaderFloating
                       cellView:(UIView *)cellView
                     cellHeight:(CGFloat)cellHeight
                 beforeCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:sectionHeaderView headerHeight:headerHeight shouldSectionHeaderFloating:shouldSectionHeaderFloating cellView:cellView cellHeight:cellHeight beforeCellView:referenceCellView animated:NO];
}


- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
        beforeCellView:(UIView *)referenceCellView
              animated:(BOOL)animated{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:cellHeight beforeCellView:referenceCellView animated:animated];
}

- (void)insertcellView:(UIView *)cellView
            cellHeight:(CGFloat)cellHeight
        beforeCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:cellHeight beforeCellView:referenceCellView animated:NO];
}

- (void)insertcellView:(UIView *)cellView
        beforeCellView:(UIView *)referenceCellView
              animated:(BOOL)animated{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:self.cellHeight beforeCellView:referenceCellView animated:animated];
    
}

- (void)insertcellView:(UIView *)cellView
        beforeCellView:(UIView *)referenceCellView{
    [self insertSectionHeaderView:nil headerHeight:0 shouldSectionHeaderFloating:NO cellView:cellView cellHeight:self.cellHeight beforeCellView:referenceCellView animated:NO];
}

@end



