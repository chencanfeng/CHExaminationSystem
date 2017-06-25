

//
//  CHExaminationSystemNextViewCellModel.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemCellModel.h"

@implementation CHExaminationSystemCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _sectionData = [[NSArray alloc] init];
        //默认等于YES
        _isOpen = YES;
        
    }
    return self;
}

@end
