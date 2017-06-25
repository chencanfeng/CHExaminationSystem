//
//  CHExaminationSystemResultController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemResultController.h"


#import "CHExaminationSystemCellModel.h"
#import "CHExaminationSystemResultHeaderView.h"
#import "CHExaminationSystemDrawRectView.h"

@interface CHExaminationSystemResultController ()<UITableViewDataSource,UITableViewDelegate> {
    BOOL _isFirst;
    BOOL _hasStarted;
    int _sectionHeight;
    
    
}
@property (nonatomic, strong) UITableView * orderTableView;
@property (nonatomic, strong) CHExaminationSystemResultHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation CHExaminationSystemResultController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _isFirst = YES;
        _sectionHeight = 50.f;
        _hasStarted = NO;
        
        self.data = [NSMutableArray new];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNaviTitle:@"评分" leftButtonShow:YES rightButtom:nil];
    
    [self createSubview];
    
    //获取数据源
    if(self.response == nil) {
        
       [self requestData];
    }else {
        NSDictionary *datas = self.response[@"Datas"];
        [self processData:datas];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData
{
    NSDictionary *params = @{
                             @"examId":_examId,
                             @"userid":_userId
                             
                             };
    
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/exam/GetMyExamResult.mt" params:params loadingHint:@"" doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *datas = response[@"Datas"];
                
                [self processData:datas];
                
            });
        }
    }];
    
}

- (void)processData:(NSDictionary *)datas {
    
    NSArray *checked = datas[@"checked"];
    
    if(checked && [checked count]>0) {
        
        
        NSMutableArray *arrM = [NSMutableArray new];
        NSMutableArray *arrM1 = [NSMutableArray new];
        NSMutableArray *arrM2 = [NSMutableArray new];
        NSMutableArray *arrM3 = [NSMutableArray new];
        for (NSDictionary *ex in checked) {
            if([ex[@"type"] isEqualToString:@"0"]) {
                [arrM1 addObject:ex];
            }else if([ex[@"type"] isEqualToString:@"1"]) {
                [arrM2 addObject:ex];
            }else if([ex[@"type"] isEqualToString:@"2"]) {
                [arrM3 addObject:ex];
            }
        }
        [arrM addObjectsFromArray:@[arrM1,arrM2,arrM3]];
        
        
        for (NSArray *array in arrM) {
            if([array count]>0) {
                NSDictionary *ex = array[0];
                CHExaminationSystemCellModel *cellModel = [[CHExaminationSystemCellModel alloc] init];
                if([ex[@"type"] isEqualToString:@"0"]) {
                    
                    cellModel.title = @"单选题";
                    
                }else if([ex[@"type"] isEqualToString:@"1"]) {
                    
                    cellModel.title = @"多选题";
                    
                }else if([ex[@"type"] isEqualToString:@"2"]) {
                    
                    cellModel.title = @"判断题";
                    
                }
                cellModel.sectionData = array;
                
                [self.data addObject:cellModel];
            }
        }
        
        [_orderTableView reloadData];
    }
    
    NSString *score = [NSString stringWithFormat:@"%@",datas[@"score"]];
    NSString *spend = datas[@"spend"];
    NSString *finishAt = datas[@"finishAt"];
    _headerView.label1.text = score;
    _headerView.label2.text = spend;
    _headerView.label3.text = finishAt;
    
}



- (void)createSubview
{
    
    
    _headerView = [[CHExaminationSystemResultHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    
    
    
    //tableView
    _orderTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _orderTableView.dataSource=self;
    _orderTableView.delegate=self;
    _orderTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self setExtraCellLineHidden:_orderTableView];
    _orderTableView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:_orderTableView];
    
    _orderTableView.tableHeaderView = _headerView;
    
    [_orderTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}





- (void)backAction {
    
    if(self.response == nil) {
        
        [super backAction];
    }else {
        
        
        [self popToViewController:@"CHExaminationSystemMainController"];
        
    }
    
}

- (void)popToViewController:(NSString *)viewController {
    UINavigationController *nav = self.navigationController;
    NSMutableArray *viewControllers = [NSMutableArray new];
    for (UIViewController * vc in [nav viewControllers]) {
        [viewControllers addObject:vc];
        if([vc isKindOfClass:NSClassFromString(viewController)]) {
            break;
        }
    }
    [nav setViewControllers:viewControllers animated:YES];
}


#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    
    return 1.f;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeight;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CHExaminationSystemCellModel *model = self.data[section];
    
    NSInteger weight = [UIScreen mainScreen].bounds.size.width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weight, _sectionHeight)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = 100 + section;
    
    
    //line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 14, 4, 22)];
    lineView.backgroundColor = [UIColor blackColor];
    [view addSubview:lineView];
    
    
    //label1
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 14, weight-30, 22)];
    label1.text = model.title;
    label1.font = [UIFont systemFontOfSize:16];
    [view addSubview:label1];
    
    return view;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHExaminationSystemCellModel *cellModel = self.data[indexPath.section];
    CHExaminationSystemDrawRectView *drawView = [[CHExaminationSystemDrawRectView alloc] init];
    drawView.model = cellModel.sectionData;
    
    return [drawView getDrawRectHeight];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    CHExaminationSystemCellModel *cellModel = self.data[indexPath.section];
    
    
    
    CHExaminationSystemDrawRectView *drawView = [[CHExaminationSystemDrawRectView alloc] init];
    drawView.model = cellModel.sectionData;
    drawView.examState = finished;
    
    CGFloat height = [drawView getDrawRectHeight];
    drawView.frame = CGRectMake(0, 0, kScreenWidth, height);
    [cell.contentView addSubview:drawView];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

@end
