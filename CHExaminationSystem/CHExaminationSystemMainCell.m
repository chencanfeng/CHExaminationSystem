//
//  CHExaminationSystemMainCell.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemMainCell.h"

@implementation CHExaminationSystemMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _label1Width.constant = kScreenWidth - (320 - 271);
    
}

- (void)layoutSubviews {
    
    
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    _label1.preferredMaxLayoutWidth = kScreenWidth - (320- 279);
    _label4.preferredMaxLayoutWidth = kScreenWidth - (320- 252);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)initCellWithTableView:(UITableView *)tableView
{
    //可重用标示符ID
    static NSString *cellID=@"CHExaminationSystemMainCell";
    CHExaminationSystemMainCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        // 从.xib中加载视图
        cell=[[[NSBundle mainBundle] loadNibNamed:@"CHExaminationSystemMainCell" owner:nil options:nil] lastObject];
        [cell setValue:cellID forKey:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)setModel:(NSDictionary *)model {
    _model = model;
    
    _label1.text = model[@"title"];
    _label2.text = [NSString stringWithFormat:@"%@题/%@分钟",model[@"questionCount"],model[@"duration"]];
    
    if([model[@"finishTime"] isEqualToString:@""]) {
        _finishTime.text = @"有效日期:";
        _label3.text = model[@"activeTime"];
        
    }else {
        _finishTime.text = @"交卷时间:";
        _label3.text = model[@"finishTime"];
    }
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"examId == %@ AND paperId == %@",model[@"examId"],model[@"paperId"]];
    RecordExam *record = [RecordExam MR_findFirstWithPredicate:predicate];

    
    if(record) {
        
        
        NSDateComponents *comps = [self getDifferenceByDate:record.beginAt==nil?@"":record.beginAt];
        
        NSInteger total = comps.hour * 60 + comps.minute;
        
        NSInteger duration = [model[@"duration"] integerValue];
        NSInteger difference = duration - total;
        
        if(difference <= 0) {
            _imgViewHeight.constant = 0;
            _imgViewWidth.constant = 0;
           _label4.text = [NSString stringWithFormat:@"考试时间已用完，您不能继续答题，请交卷！"];
        }else {
            _imgViewHeight.constant = 17;
            _imgViewWidth.constant = 17;
           _label4.text = [NSString stringWithFormat:@"考试中，已用时%d分钟，剩余%d分钟！",(int)comps.minute,(int)difference];
        }
        
        
        
        
    }else {
        
        _imgViewHeight.constant = 0;
        _label4.text = @"";
    }
    
    
    
    
}

- (NSDateComponents *)getDifferenceByDate:(NSString *)date {
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *oldDate = [dateFormatter dateFromString:date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate  toDate:now  options:0];
    return comps;
}



@end
