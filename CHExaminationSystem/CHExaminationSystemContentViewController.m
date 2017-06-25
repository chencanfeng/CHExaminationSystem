

//
//  CHExaminationSystemContentViewController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemContentViewController.h"


#import "CHExaminationSystemContentCell.h"

#import "CHExaminationSystemTimeCountView.h"

@interface CHExaminationSystemContentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *orderTableView;

@property (nonatomic, strong) NSArray *topTips;
@property (nonatomic, strong) NSArray *opts1; //选项Abcd..
@property (nonatomic, strong) NSArray *opts2; //选项y or n
@property (nonatomic ,strong) NSDictionary *answer;

@property (nonatomic ,strong) NSMutableDictionary *markRecord;




@end

@implementation CHExaminationSystemContentViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
        _topTips = @[
                     @"单选题（有且仅有一个正确答案，每题2分）",
                     @"多选题（有多个正确答案，每题2分）",
                     @"判断题（选择是或不是，每题2分）"
                     ];
        
        _opts1 = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G"];
        _opts2 = @[@"Y",@"N"];
        
        
        
        _markRecord = [NSMutableDictionary new];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNaviTitle:@"名通内部第一次考试" leftButtonShow:YES rightButtom:nil];
    
    [self processData];
    
    [self createSubview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)processData {
    _answer = [_content.answer copy];
}


- (void)createSubview
{
    
    
    
    int type = [_content.type intValue];
    
    //topView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    topView.backgroundColor = [UIColor colorWithRed:0.902 green:0.949 blue:0.961 alpha:1.00];
    [self.view addSubview:topView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, kScreenWidth - 2 * 20, 22)];
    label.text = _topTips[type];
    label.textColor = [UIColor colorWithRed:0.400 green:0.400 blue:0.400 alpha:1.00];
    label.font = [UIFont systemFontOfSize:14.f];
    [topView addSubview:label];
    

    //tableView
    _orderTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _orderTableView.dataSource=self;
    _orderTableView.delegate=self;
    _orderTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self setExtraCellLineHidden:_orderTableView];
    _orderTableView.rowHeight = 60.f;
    _orderTableView.translatesAutoresizingMaskIntoConstraints=NO;
    _orderTableView.bounces = NO;
    [self.view addSubview:_orderTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_orderTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_orderTableView)]];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_answer count];
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger weight = [UIScreen mainScreen].bounds.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weight, 60.f)];
    
    NSString *str = [NSString stringWithFormat:@"%d.%@",(int)_content.displayNum,_content.question];
    
    //label1
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, weight-16, 60.f)];
    label1.text = str;
    label1.numberOfLines = 0;
//    label1.font = [UIFont systemFontOfSize:18];
    [view addSubview:label1];
    
    
    label1.adjustsFontSizeToFitWidth = YES;
    
    return view;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *answer = [_content.answer copy];
    NSString *optIndex = [_content.type isEqualToString:@"2"]? _opts2[indexPath.row]:_opts1[indexPath.row];
    NSString *optStr = [answer objectForKey:optIndex];
    
    NSString *aResult = _content.result;
    
    
    
    CHExaminationSystemContentCell *cell = [CHExaminationSystemContentCell initCellWithTableView:tableView];
    cell.label.text = optStr;
    cell.label.adjustsFontSizeToFitWidth = YES;

    cell.model = _content;
    
    if([aResult containsString:optIndex]) {
        cell.iconBtn.selected = YES;
    }else {
        cell.iconBtn.selected = NO;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //如果考试时间已用完，继续答题则提示交卷
    CHExaminationSystemTimeCountView *rView = [[CHExaminationSystemTimeCountView alloc] init];
    rView.predicate = _predicate;
    if([rView checkTimeIsOver]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(contentViewController:didSelectRowByTimeIsOver:)]) {
            
            [self.delegate contentViewController:self didSelectRowByTimeIsOver:YES];
        }
        
        return;
    }
    
    
    if([_content.type isEqualToString:@"0"]) {
        //单选
        NSString *optStr = _opts1[indexPath.row];
        
        _content.result = optStr;
        
        
        
    }else if([_content.type isEqualToString:@"1"]) {
        //多选
        NSString *optStr = _opts1[indexPath.row];
        NSMutableString *aResult = [_content.result mutableCopy];
        
        if([aResult containsString:optStr]) {
            
            NSRange range = [aResult rangeOfString:optStr];
            [aResult deleteCharactersInRange:range];
        }else {
            [aResult appendString:optStr];
        }
        aResult = [[self sortString:aResult] mutableCopy];
        
        _content.result = aResult;
        
        
    }else if([_content.type isEqualToString:@"2"]){
        //判断
        NSString *optStr = _opts2[indexPath.row];
        
        _content.result = optStr;
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [tableView reloadData];
    
}

- (NSString *)sortString:(NSString *)str {
    if(str.length == 0) {
        return str;
    }
    
    NSMutableArray *arrM = [NSMutableArray new];
    for (int i= 0 ; i < str.length; i ++) {
        [arrM addObject:[NSString stringWithFormat:@"%c",[str characterAtIndex:i]]];
    }
    
    NSArray *newArray = [arrM sortedArrayUsingSelector:@selector(compare:)];
    str = [newArray componentsJoinedByString:@""];
    
    return str;
    
}


//计算时间差
- (NSDateComponents *)getDifferenceByDate:(NSString *)date {
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *oldDate = [dateFormatter dateFromString:date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate  toDate:now  options:0];
    return comps;
}

@end
