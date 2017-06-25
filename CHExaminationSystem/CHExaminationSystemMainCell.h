//
//  CHExaminationSystemMainCell.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHExaminationSystemMainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label1; //title
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewWidth;

@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet UILabel *finishTime;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (weak, nonatomic) IBOutlet UILabel *label4;

@property (nonatomic ,strong) NSDictionary * model;

+ (instancetype)initCellWithTableView:(UITableView *)tableView;

@end
