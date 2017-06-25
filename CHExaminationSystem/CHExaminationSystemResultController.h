//
//  CHExaminationSystemResultController.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

//#import <MTControls/MTControls.h>

@interface CHExaminationSystemResultController : MTBaseViewController

@property (nonatomic ,strong) NSString  *examId;
@property (nonatomic ,strong) NSString  *paperId;
@property (nonatomic ,strong) NSString  *userId;

@property (nonatomic ,strong) NSDictionary  *response;

@end
