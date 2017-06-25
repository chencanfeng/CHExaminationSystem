//
//  ViewController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "ViewController.h"

#import "CHExaminationSystemMainController.h"

#import "CHExaminationSystemTimeCountView.h"

#define kBarItemWidth 80.f

@interface ViewController ()

//@property (weak, nonatomic) IBOutlet UIButton *authCodeBtn;
@property (nonatomic, strong) UIButton *authCodeBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNaviTitle:@"考试系统上一级页面" leftButtonShow:YES rightButtom:nil];
    

//    int time = 3605;
//    
//    CHExaminationSystemTimeCountView *rView = [[CHExaminationSystemTimeCountView alloc] initWithFrame:CGRectMake(0, 0, kBarItemWidth, 44) count:time isShowSerial:NO];
//    rView.serialStr = @"11/50";
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rView];
//    self.navigationItem.rightBarButtonItem = item;
//    
//    [rView openCountdown];
    
    
}




#pragma mark - 开启定时器



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickedMoreBtn:(id)sender {
    CHExaminationSystemMainController *vc = [[CHExaminationSystemMainController alloc] init];
    [self pushViewController:vc];
    
}


@end
