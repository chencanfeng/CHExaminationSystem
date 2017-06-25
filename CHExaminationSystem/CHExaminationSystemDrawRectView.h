//
//  CHExaminationSystemDrawRectView.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>



//考试状态
typedef NS_ENUM(NSInteger,ExamState){
    started = 1,
    continued,
    finished
};

@class CHExaminationSystemDrawRectView;
@protocol CHExaminationSystemDrawRectViewProtocol <NSObject>

- (void)drawRectView:(CHExaminationSystemDrawRectView *)drawView didClickedExamItem:(Examination *)ex;

@end


@interface CHExaminationSystemDrawRectView : UIView



@property (nonatomic ,strong) NSPredicate  *predicate; //用于筛选MagicalRecord的谓词

@property (nonatomic ,assign) ExamState examState;


@property (nonatomic ,strong) NSArray  *model; //单个section的题目
@property (nonatomic ,weak) id<CHExaminationSystemDrawRectViewProtocol> delegate;

- (CGFloat)getDrawRectHeight;



@end
