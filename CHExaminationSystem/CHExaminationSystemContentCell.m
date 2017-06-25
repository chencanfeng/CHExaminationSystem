

//
//  CHExaminationSystemContentCell.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemContentCell.h"

@implementation CHExaminationSystemContentCell {
    int _type;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)initCellWithTableView:(UITableView *)tableView
{
    //可重用标示符ID
    static NSString *cellID=@"CHExaminationSystemContentCell";
    CHExaminationSystemContentCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        // 从.xib中加载视图
        cell=[[[NSBundle mainBundle] loadNibNamed:@"CHExaminationSystemContentCell" owner:nil options:nil] lastObject];
        [cell setValue:cellID forKey:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


- (void)setModel:(Examination *)model {
    
    _model = model;
    
    _type = [_model.type intValue];
    
    
    if(_type == 0) {
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_radio_unsel"] forState:UIControlStateNormal];
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_radio_sel"] forState:UIControlStateSelected];
        
    }else if(_type == 1) {
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_radio_unsel"] forState:UIControlStateNormal];
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_multiple_sel"] forState:UIControlStateSelected];
    }else if(_type ==2) {
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_radio_unsel"] forState:UIControlStateNormal];
        [_iconBtn setImage:[UIImage imageNamed:@"bt_exam_radio_sel"] forState:UIControlStateSelected];
        
    }
    
    

}


@end
