//
//  CHExaminationSystemManager.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/25.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemManager.h"

//#import "CHExaminationSystemResultController.h"

@implementation CHExaminationSystemManager 



//-(void)submitData {
//    
//    RecordExam *record = [RecordExam MR_findFirstWithPredicate:_predicate];
//    NSArray *exams = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
//    
//    NSDictionary *dicM = [NSMutableDictionary new];
//    for (Examination *ex in exams) {
//        [dicM setValue:ex.result forKey:[NSString stringWithFormat:@"%d",(int)ex.identify]];
//    }
//    
//    
//    
//    NSDictionary *params = @{
//                             @"examId":record.examId,
//                             @"userid":[MTGlobalInfo sharedInstance].userID,
//                             @"beginAt":record.beginAt,
//                             @"reqData":[dicM JSONString]
//                             
//                             };
//    
//    
//    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/exam/FinishExam.mt" params:params loadingHint:@"正在交卷.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
//        if (![response[@"success"]isEqual:@(1)]) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                //错误提示写这里
//                return ;
//            });
//        }else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CHExaminationSystemResultController  *vc = [[CHExaminationSystemResultController alloc] init];
//                vc.examId = record.examId;
//                vc.userId = [MTGlobalInfo sharedInstance].userID;
//                vc.paperId = record.paperId;
//                [self pushViewController:vc];
//            });
//        }
//    }];
//    
//}


@end
