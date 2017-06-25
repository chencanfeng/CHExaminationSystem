//
//  CHExaminationSystemPageViewController.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

//#import <MTControls/MTControls.h>

typedef void (^ReturnTextBlock)(NSUInteger index);


@class CHExaminationSystemPageViewController;

@protocol CHExaminationSystemPageViewControllerProtocol <NSObject>

- (void)pageViewController:(CHExaminationSystemPageViewController *)vc submitDataByTimeOver:(BOOL)over;

@end



@interface CHExaminationSystemPageViewController : MTBaseViewController

@property (nonatomic ,strong) NSString  *naviTitle;

@property (nonatomic ,strong) NSPredicate  *predicate;


@property (nonatomic ,weak) id<CHExaminationSystemPageViewControllerProtocol> delegate;

@property (nonatomic, assign) NSUInteger curPageIndex;

@property (nonatomic, copy) ReturnTextBlock returnTextBlock;

- (void)returnText:(ReturnTextBlock)block;

@end
