//
//  CHExaminationSystemContentCell.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHExaminationSystemContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UILabel *label;


@property (nonatomic ,strong) NSString  *aResult; //该题目的答案

@property (nonatomic ,strong) Examination  *model;



+ (instancetype)initCellWithTableView:(UITableView *)tableView;

@end
