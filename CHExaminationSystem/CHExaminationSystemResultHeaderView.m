

//
//  CHExaminationSystemResultHeaderView.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/23.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemResultHeaderView.h"

@implementation CHExaminationSystemResultHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"CHExaminationSystemResultHeaderView" owner:nil options:nil] lastObject];
    }
    return self;
}


@end
