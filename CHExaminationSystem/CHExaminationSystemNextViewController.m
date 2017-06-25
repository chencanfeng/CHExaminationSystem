//
//  CHExaminationSystemNextViewController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemNextViewController.h"

#import "CHExaminationSystemCellModel.h" //model

#import "CHExaminationSystemPageViewController.h"

#import "CHExaminationSystemTimeCountView.h"

#import "CHExaminationSystemDrawRectView.h"

#import "CHExaminationSystemResultController.h"

#define kBarItemWidth 80.f

@interface CHExaminationSystemNextViewController ()<UITableViewDataSource,UITableViewDelegate,CHExaminationSystemTimeCountViewProtocol,CHExaminationSystemPageViewControllerProtocol,CHExaminationSystemDrawRectViewProtocol,UIAlertViewDelegate> {
    

    
    NSUInteger _curPageIndex;
    NSPredicate *_predicate;
    
    BOOL _hasStarted;
    int _sectionHeight;
}
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *continueBottomView;

@property (nonatomic, strong) UITableView * orderTableView;




@property (nonatomic,strong) NSMutableArray * data; //所有section的data



@property (nonatomic, strong) CHExaminationSystemTimeCountView *rView;

@property (nonatomic, strong) UIButton *authCodeBtn;


@end

@implementation CHExaminationSystemNextViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
        _sectionHeight = 60.f;
        _hasStarted = NO;
        
        self.data = [NSMutableArray new];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.969 blue:0.969 alpha:1.00];
    
    [self setNaviTitle:_naviTitle leftButtonShow:YES rightButtom:nil];
    
    //是否显示定时器
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"examId == %@ AND paperId == %@",_examId,_paperId];
    _predicate = predicate;
    
    
    //创建subView
    [self createSubview];
    
    
    //获取数据源
    NSArray *examinations = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
    if(examinations && [examinations count] >0) {
        
        NSArray *datas = [examinations copy];
        [self processData:datas];
        
    }else {
        
       [self requestData];
    }
    
    
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    RecordExam *record = [RecordExam MR_findFirstWithPredicate:_predicate];
    if(record) {
        
        
 
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rView];
        self.navigationItem.rightBarButtonItem = item;
        [self.rView openCountdown];
    }
    
    
    if(record) {
        _hasStarted = YES;
        _startButton.hidden = YES;
        _continueBottomView.hidden = NO;
    }else {
        _hasStarted = NO;
        _startButton.hidden = NO;
        _continueBottomView.hidden = YES;
    }
    
    [_orderTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [_rView stopCountDown];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CHExaminationSystemTimeCountView *)rView {
    
    if(_rView == nil) {
        
        _rView = [[CHExaminationSystemTimeCountView alloc] initWithFrame:CGRectMake(0, 0, kBarItemWidth, 44) isShowSerial:NO];
        _rView.delegate = self;
        _rView.predicate = _predicate;
        
    }
    
    return _rView;
    
}


#pragma mark - 数据请求
- (void)requestData
{
    
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/exam/GetExamPaper.mt" params:@{@"paperId":_paperId} loadingHint:@"正在加载试题" doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                /*
                 
                 "question": "中国移动企业核心价值观的核心内涵是责任和( ）",
                 "type": "0",
                 "displayNum": 1,
                 "id": "t01",
                 "weight": 2,
                 "answer": {
                 "A": "A. 创新",
                 "B": "B. 尊重",
                 "C": "C. 卓越",
                 "D": "D. 发展"}
                 
                 */
                
                
               
                NSArray *datas = response[@"Datas"];
                
                
                if(![datas isKindOfClass:[NSNull class]] && datas && [datas count] > 0) {
                    NSInteger index = 0;
                    
                    for (NSDictionary *dic  in datas) {
                        Examination *ex = [Examination MR_createEntity];
                        ex.question = dic[@"question"];
                        ex.type = dic[@"type"];
                        ex.displayNum = [dic[@"displayNum"] intValue];
                        ex.t_id = dic[@"id"];
                        ex.identify = index ++;
                        ex.weight = [dic[@"weight"] intValue];
                        ex.answer = [dic[@"answer"] copy];
                        ex.result = @"";
                        ex.examId  = self.examId;
                        ex.paperId = self.paperId;
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    
                    NSArray *examinations = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
                    
                    [self processData:examinations];
                    
                }
            });
        }
    }];
    
}

- (void)processData:(NSArray *)datas {
    
    NSMutableArray *arrM = [NSMutableArray new];
    NSMutableArray *arrM1 = [NSMutableArray new];
    NSMutableArray *arrM2 = [NSMutableArray new];
    NSMutableArray *arrM3 = [NSMutableArray new];
    for (Examination *ex in datas) {
        if([ex.type isEqualToString:@"0"]) {
            [arrM1 addObject:ex];
        }else if([ex.type isEqualToString:@"1"]) {
            [arrM2 addObject:ex];
        }else if([ex.type isEqualToString:@"2"]) {
            [arrM3 addObject:ex];
        }
    }
    [arrM addObjectsFromArray:@[arrM1,arrM2,arrM3]];
    
    for (NSArray *array in arrM) {
        if([array count]>0) {
            Examination *ex = array[0];
            CHExaminationSystemCellModel *cellModel = [[CHExaminationSystemCellModel alloc] init];
            if([ex.type isEqualToString:@"0"]) {
                
                cellModel.title = @"单选题";
                
            }else if([ex.type isEqualToString:@"1"]) {
                
                cellModel.title = @"多选题";
            }else if([ex.type isEqualToString:@"2"]) {
                
                cellModel.title = @"判断题";
            }
            
            NSInteger num = [array count];
            NSInteger weight = ex.weight;
            NSInteger total = num * weight;
            NSString *subTitle = [NSString stringWithFormat:@"共%ld题，%ld分，每题%ld分",num,total,weight];
            
            cellModel.subTitle = subTitle;
            
            cellModel.isOpen = YES;
            
            cellModel.sectionData = array;
            
            [self.data addObject:cellModel];
        }
    }
    
    [_orderTableView reloadData];
    
}

#pragma mark - Create UI
- (void)createSubview
{
    
    
    CGFloat h = 50.f;
    
    //tableView
    _orderTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _orderTableView.dataSource=self;
    _orderTableView.delegate=self;
    _orderTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self setExtraCellLineHidden:_orderTableView];
    _orderTableView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:_orderTableView];
    
    [_orderTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if ([self.orderTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.orderTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.orderTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.orderTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_orderTableView]-m-|" options:0 metrics:@{@"m":@(h)} views:NSDictionaryOfVariableBindings(_orderTableView)]];
    
    //底部按钮
    for (int i = 101; i <= 103; i ++) {
        UIButton *button = [self.view viewWithTag:i];
        button.layer.cornerRadius = 8.f;
        button.layer.masksToBounds = YES;
    }
    
    [self.view bringSubviewToFront:_startButton];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}




-(void)click:(UIControl *)sender
{
    CHExaminationSystemCellModel *sec = self.data[sender.tag - 100];
    sec.isOpen = !sec.isOpen;
    
    [_orderTableView reloadData];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CHExaminationSystemCellModel *sec = self.data[section];
    
    if(sec.isOpen==NO)
    {
        return 0;
    }
    return 1.f;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeight;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger weight = [UIScreen mainScreen].bounds.size.width;
    
    UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, weight, _sectionHeight)];
    
    view.tag = 100 + section;
    
    [view addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    CHExaminationSystemCellModel *sec = self.data[section];
    
    //label1
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, weight-60, 20)];
    label1.text = sec.title;
    label1.font = [UIFont systemFontOfSize:16];
    [view addSubview:label1];
    
    //label2
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 31, weight-60, 20)];
    label2.text = sec.subTitle;
    label2.font = [UIFont systemFontOfSize:14];
    label2.textColor = [UIColor colorWithRed:0.361 green:0.361 blue:0.361 alpha:1.00];
    [view addSubview:label2];
    
    
    
    UIImageView * mgv = [[UIImageView alloc]initWithFrame:CGRectMake(weight-40, 15, 20, 20)];
    
    if(!sec.isOpen){
        mgv.image = [UIImage imageNamed:@"arrow-right-32"];
        
    }else{
        mgv.image = [UIImage imageNamed:@"arrow-down-32"];
        
    }
    [view addSubview:mgv];
    
   
    
    view.backgroundColor = [UIColor whiteColor];
    return view;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHExaminationSystemCellModel *sec = self.data[indexPath.section];
    
    CHExaminationSystemDrawRectView *drawView = [[CHExaminationSystemDrawRectView alloc] init];
    drawView.model = sec.sectionData;
    
    return [drawView getDrawRectHeight];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHExaminationSystemCellModel *sec = self.data[indexPath.section];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    CHExaminationSystemDrawRectView *drawView = [[CHExaminationSystemDrawRectView alloc] init];
    
    drawView.predicate = _predicate;
    drawView.model = sec.sectionData;
    drawView.examState = _hasStarted ? continued : started;
    drawView.delegate = self;
    
    CGFloat height = [drawView getDrawRectHeight];
    drawView.frame = CGRectMake(0, 0, kScreenWidth, height);
    [cell.contentView addSubview:drawView];

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

#pragma mark - 开始答题、继续答案、交卷

- (IBAction)clickedBottomButton:(UIButton *)sender {
    if(sender.tag == 101) {
        
        _curPageIndex = 0;
        _hasStarted = YES;
        
        NSString *dateStr = [NSDate stringFromDate:[NSDate date] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        RecordExam *record = [RecordExam MR_createEntity];
        record.examId = _examId;
        record.paperId = _paperId;
        record.beginAt = dateStr;
        record.duration = _duration;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        
        [self pushToPageViewController];
        
    }
    
    //开始答题、继续答题
    if(sender.tag == 102) {
        [self pushToPageViewController];
        
    }
    else if(sender.tag == 103) {
        //交卷
        [self submitData:@"请检查答题情况，您确认要交卷吗？"];
        
    }
    
    
}

- (void)pushToPageViewController {
    
    
    
    
    
    CHExaminationSystemPageViewController *vc = [[CHExaminationSystemPageViewController alloc] init];
    
    vc.naviTitle = _naviTitle;
    vc.predicate = _predicate;
    vc.curPageIndex = _curPageIndex;
    vc.delegate = self;
    [vc returnText:^(NSUInteger index) {
        _curPageIndex = index;
    }];
    [self pushViewController:vc];
    
    
}

- (void)pageViewController:(CHExaminationSystemPageViewController *)vc submitDataByTimeOver:(BOOL)over {
    if(over) {
        
        [self submitData:@"考试时间已用完，您不能继续答题，请交卷！"];
    }else {
        
        [self submitData:@"请检查答题情况，您确认要交卷吗？"];
    }
    
}

- (void)timeCountView:(CHExaminationSystemTimeCountView *)countView timeToSubmitData:(NSString *)str {
    
    
    [self submitData:@"考试时间已用完，您不能继续答题，请交卷！"];
    
    
}

- (void)drawRectView:(CHExaminationSystemDrawRectView *)drawView didClickedExamItem:(Examination *)ex {
    
    _curPageIndex = ex.identify;
    
    [self pushToPageViewController];
}

#pragma mark - 交卷
- (void)submitData:(NSString *)message {
    
    //交卷
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"交卷", nil];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        
        [self submit];
        
    }
    
}

-(void)submit {
    
    
    
    
    RecordExam *record = [RecordExam MR_findFirstWithPredicate:_predicate];
    NSArray *exams = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
    
    NSDictionary *dicM = [NSMutableDictionary new];
    for (Examination *ex in exams) {
        [dicM setValue:ex.result forKey:[NSString stringWithFormat:@"%d",(int)ex.identify]];
    }
    
    
    
    NSDictionary *params = @{
                             @"examId":record.examId,
                             @"userid":[MTGlobalInfo sharedInstance].userID,
                             @"beginAt":record.beginAt,
                             @"reqData":[dicM JSONString]
                             
                             };
    
    NSLog(@"dicM = %@ ,\nparams = %@",dicM,params);
    
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/exam/FinishExam.mt" params:params loadingHint:@"正在交卷.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [SVProgressHUD showSuccessWithStatus:@"提交成功"];
                
                //删除本地记录
                if(![RecordExam MR_deleteAllMatchingPredicate:_predicate]) {
                    NSLog(@"===  删除本地记录失败。 === ");
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    //刷新列表页
                    [self.parentVC refreshUI];
                    
                    //跳转到评分页面
                    CHExaminationSystemResultController  *vc = [[CHExaminationSystemResultController alloc] init];
                    vc.examId = record.examId;
                    vc.userId = [MTGlobalInfo sharedInstance].userID;
                    vc.paperId = record.paperId;
                    vc.response = [response copy];
                    if(self.parentVC) {
                        
                        [self.parentVC pushViewController:vc];
                    }
                });
                
                
                
            });
        }
    }];
    
}



@end
