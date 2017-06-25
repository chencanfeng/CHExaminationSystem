//
//  CHExaminationSystemMainController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemMainController.h"
#import "CHExaminationSystemNextViewController.h"
#import "CHExaminationSystemResultController.h"
#import "CHExaminationSystemMainCell.h"

#import "MJRefresh.h"

@interface CHExaminationSystemMainController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>
{
    MJRefreshHeaderView *_headerL;
    MJRefreshFooterView *_footerL;
    NSNumber *_leftTotal;
    int leftPageIndex;
    
}

@property (nonatomic, strong)UITableView *orderTableView;
@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation CHExaminationSystemMainController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _leftTotal = @0;
        leftPageIndex = 0;
        _dataSource = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNaviTitle:@"考试" leftButtonShow:YES rightButtom:nil];
    
    [self createSubview];
    

#if DEBUG
    [MTGlobalInfo sharedInstance].userID=@"37408";
#endif
    
    [self requestData];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [_orderTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshUI {
    
    
    
    [_headerL beginRefreshing];
    
    
}


- (void)requestData
{
    NSString *userid = [MTGlobalInfo sharedInstance].userID;
    NSDictionary *params = @{
                             @"userid":userid,
                             @"pageIndex":[NSString stringWithFormat:@"%d",leftPageIndex],
                             @"pageSize":@"20"
                             
                             };
    
    
    
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/exam/GetExamList.mt" params:params loadingHint:@"正在加载数据.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_headerL && _headerL.isRefreshing) {
                    [_headerL endRefreshing];
                    [_dataSource removeAllObjects];
                }
                if (_footerL&&_footerL.isRefreshing) {
                    [_footerL endRefreshing];
                }
                
                NSArray *datas = response[@"Datas"];
                int num = [response[@"total"] intValue];
                _leftTotal = @(num);
                
                if(![datas isKindOfClass:[NSNull class]] && datas && [datas count] > 0) {
                    for (NSDictionary *dic in datas) {
                        [_dataSource addObject:dic];
                    }
                    
                    
                    [_orderTableView reloadData];
                }
                
                
            });
        }
    }];
    
}

- (void)createSubview
{
    
    
    
    _orderTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _orderTableView.dataSource=self;
    _orderTableView.delegate=self;
    _orderTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self setExtraCellLineHidden:_orderTableView];
    _orderTableView.rowHeight = 44.f;
    _orderTableView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:_orderTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    
    _headerL = [MJRefreshHeaderView header];
    _footerL = [MJRefreshFooterView footer];
    _headerL.scrollView = self.orderTableView;
    _footerL.scrollView = self.orderTableView;
    _headerL.delegate = self;
    _footerL.delegate = self;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UITableView
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHExaminationSystemMainCell *cell = [CHExaminationSystemMainCell initCellWithTableView:tableView];
    NSDictionary *model = [_dataSource objectAtIndex:indexPath.row];
    cell.model = model;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0f;
    return height;
    
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHExaminationSystemMainCell *cell = [CHExaminationSystemMainCell initCellWithTableView:tableView];
    NSDictionary *model = [_dataSource objectAtIndex:indexPath.row];
    cell.model = model;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateStr = [NSDate stringFromDate:[NSDate date] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDictionary *dic = [_dataSource objectAtIndex:indexPath.row];
    
    NSString *finishTime = dic[@"finishTime"];
    if([finishTime isEqualToString:@""]) {
        CHExaminationSystemNextViewController *vc = [[CHExaminationSystemNextViewController alloc] init];
        vc.naviTitle = dic[@"title"];
        vc.paperId = [NSString stringWithFormat:@"%@",dic[@"paperId"]];
        vc.examId = dic[@"examId"];
        vc.beginAt = dateStr;
        vc.duration = [dic[@"duration"] integerValue];
        vc.parentVC = self;
        [self pushViewController:vc];
        
    }else {
        CHExaminationSystemResultController *vc = [[CHExaminationSystemResultController alloc] init];
        vc.examId = dic[@"examId"];
        vc.userId = [MTGlobalInfo sharedInstance].userID;
        vc.paperId = dic[@"paperId"];
        [self pushViewController:vc];
        
    }
    
    
    
    
}


//代理方法：进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_headerL == refreshView) {
        leftPageIndex = 0;
        [self requestData];
    }
    if (_footerL == refreshView) {
        
        if (_leftTotal.integerValue > [_dataSource count]) {
            leftPageIndex += 1;
            [self requestData];
        }
        else{
            [_footerL endRefreshing];
        }
    }
    
    
}

//为了保证内部不泄露，最好在控制器的dealloc中释放占用的内存
- (void)dealloc {
    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_headerL free];
    [_footerL free];
    
    
}


@end
