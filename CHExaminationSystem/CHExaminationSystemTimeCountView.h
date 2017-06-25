//
//  CHExaminationSystemTimeCountView.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/22.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHExaminationSystemTimeCountView;
@protocol CHExaminationSystemTimeCountViewProtocol <NSObject>

- (void)timeCountView:(CHExaminationSystemTimeCountView *)countView timeToSubmitData:(NSString *)str;

@end

@interface CHExaminationSystemTimeCountView : UIView

@property (nonatomic ,strong) NSPredicate  *predicate;

@property (nonatomic ,strong) NSString  *serialStr; //页号



@property (nonatomic ,weak) id<CHExaminationSystemTimeCountViewProtocol>  delegate;

- (instancetype)initWithFrame:(CGRect)frame isShowSerial:(BOOL)isShowSerial;
-(void)openCountdown;
- (void)stopCountDown;
- (BOOL)checkTimeIsOver;
@end
