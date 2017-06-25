//
//  CHExaminationSystemNextViewController.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemMainController.h"

@interface CHExaminationSystemNextViewController : MTBaseViewController

@property (nonatomic ,strong) NSString  *paperId; //试卷id
@property (nonatomic ,strong) NSString  *examId;
@property (nonatomic ,strong) NSString  *beginAt;

@property (nonatomic ,assign) NSInteger duration; //考试时长

@property (nonatomic, assign) int time;

@property (nonatomic ,strong) NSString * naviTitle;

@property (nonatomic ,strong) CHExaminationSystemMainController *parentVC;

@end
