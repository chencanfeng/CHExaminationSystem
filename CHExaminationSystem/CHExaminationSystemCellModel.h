//
//  CHExaminationSystemCellModel.h
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHExaminationSystemCellModel : NSObject

@property (nonatomic) BOOL isOpen;  //打开的状态
@property (nonatomic,strong) NSArray *sectionData;
@property (nonatomic,copy) NSString *title;
@property (nonatomic ,strong) NSString  *subTitle;

@end
