

//
//  CHExaminationSystemTimeCountView.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/22.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemTimeCountView.h"


@interface CHExaminationSystemTimeCountView ()

@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UILabel *serialL;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) BOOL isShowSerial;
@property (nonatomic, assign) int time;
@end

@implementation CHExaminationSystemTimeCountView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame isShowSerial:(BOOL)isShowSerial
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UIView *rView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        UILabel *timeL = [[UILabel alloc] init]; //时间计时器
        UILabel *serialL = [[UILabel alloc] init]; //题目序号
        
        [rView addSubview:timeL];
        [rView addSubview:serialL];
        
        [self addSubview:rView];
        

        timeL.text = @"";
        timeL.textAlignment = NSTextAlignmentRight;
        timeL.textColor = [UIColor whiteColor];
        timeL.font = [UIFont systemFontOfSize:13.f];
        serialL.text = @"";
        serialL.textAlignment = NSTextAlignmentRight;
        serialL.textColor = [UIColor colorWithRed:0.698 green:0.906 blue:0.961 alpha:1.00];
        serialL.font = [UIFont systemFontOfSize:13.f];
        
        if(isShowSerial) {
            timeL.frame = CGRectMake(0, 1, frame.size.width, 20);
            serialL.frame = CGRectMake(0, 22, frame.size.width, 20);
            
        }else {
            timeL.frame = CGRectMake(0, 12, frame.size.width, 20);
            serialL.frame = CGRectZero;
        }
        
        _timeL = timeL;
        _serialL = serialL;
        _isShowSerial = isShowSerial;
        
        
        
    }
    return self;
}


- (void)setSerialStr:(NSString *)serialStr {
    if([serialStr containsString:@"/"]) {
        
        
        NSRange range = [serialStr rangeOfString:@"/"];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:serialStr];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,range.location)];
        
        _serialL.attributedText = str;
        
    }
    
    
}
//计算时间差
- (int)getDifferenceByDate {
    
    RecordExam *record = [RecordExam MR_findFirstWithPredicate:_predicate];
    NSInteger duration = record.duration;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *oldDate = [dateFormatter dateFromString:record.beginAt == nil?@"":record.beginAt];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate  toDate:now  options:0];
    
    NSInteger diff = duration - comps.hour * 60 - comps.minute; //时间差
    
    int time = (int)(diff * 60 - comps.second); //倒计时时间
    
    return time;
    
}

// 开启倒计时效果
-(void)openCountdown{
    
    
    
    
    __block int time = [self getDifferenceByDate]; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                _timeL.text = @"考试结束";
                _timeL.textColor = [UIColor redColor];
                
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(timeCountView:timeToSubmitData:)]) {
                    
                    [self.delegate timeCountView:self timeToSubmitData:nil];
                }
                
            });
            
        }else{
            
            int seconds = time % 60;
            
            int minutes = (time / 60) % 60;
            
            int hours = time / 3600;
            
            NSString *message1 = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
            NSString *message2 = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                _timeL.text = hours>0?message1:message2;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (void)stopCountDown {
    //取消定时器
    dispatch_source_cancel(_timer);
    
}

- (BOOL)checkTimeIsOver {
    
    int time = [self getDifferenceByDate];
    
    if(time <= 0) {
        
        return YES;
    }
    
    return NO;
    
    
}



@end
