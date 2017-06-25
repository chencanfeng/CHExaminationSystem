//
//  CHExaminationSystemContentViewController.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

@class CHExaminationSystemContentViewController;

@protocol CHExaminationSystemContentViewControllerProcotal <NSObject>

- (void)contentViewController:(CHExaminationSystemContentViewController *)vc didSelectRowByTimeIsOver:(BOOL)over;

@end

@interface CHExaminationSystemContentViewController : MTBaseViewController
@property (nonatomic, strong) Examination *content; //每题考题的内容

@property (nonatomic ,strong) NSPredicate  *predicate;

@property (nonatomic ,weak) id<CHExaminationSystemContentViewControllerProcotal> delegate;


@end
