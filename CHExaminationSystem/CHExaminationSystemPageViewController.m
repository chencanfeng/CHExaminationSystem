//
//  CHExaminationSystemPageViewController.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/15.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemPageViewController.h"
#import "CHExaminationSystemResultController.h"

#import "CHExaminationSystemTimeCountView.h"

#import "CHExaminationSystemContentViewController.h"

#define kBarItemWidth 80.f

@interface CHExaminationSystemPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource,UIGestureRecognizerDelegate,UIAlertViewDelegate,CHExaminationSystemTimeCountViewProtocol,CHExaminationSystemContentViewControllerProcotal>

{
    
    int _examNum;
    
}

@property (weak, nonatomic) IBOutlet UIView *pageContentView;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageContentArray;
@property (nonatomic, strong) CHExaminationSystemTimeCountView *rView;

@end

@implementation CHExaminationSystemPageViewController

@synthesize curPageIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNaviTitle:_naviTitle leftButtonShow:YES rightButtom:nil];
    
    self.pageContentArray = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
    _examNum = (int)[self.pageContentArray count];
    
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:options];
    
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    // 设置UIPageViewController初始化数据, 将数据放在NSArray里面
    // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
    CHExaminationSystemContentViewController *initialViewController = [self viewControllerAtIndex:curPageIndex];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:nil];
    
   
    _pageViewController.view.frame = _pageContentView.bounds;
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.pageContentView  addSubview:_pageViewController.view];
    
    
    
    
    //获取UIPageViewController里的手势//解决边缘自动翻页跟控件冲突的问题
    for (UIGestureRecognizer *gr in self.pageViewController.view.gestureRecognizers) {
        
        gr.delegate= self ;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    //定时器
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rView];
    self.navigationItem.rightBarButtonItem = item;
    [self.rView openCountdown];
    
    _rView.serialStr = [NSString stringWithFormat:@"%d/%d",(int)(curPageIndex + 1), _examNum];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [_rView stopCountDown];
    
    
}

- (CHExaminationSystemTimeCountView *)rView {
    
    if(_rView == nil) {
        
        _rView = [[CHExaminationSystemTimeCountView alloc] initWithFrame:CGRectMake(0, 0, kBarItemWidth, 44) isShowSerial:YES];
        _rView.delegate = self;
        _rView.predicate = _predicate;
        
    }
    
    return _rView;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击返回的时候，记录当前页
- (void)backAction {
    if(self.returnTextBlock != nil) {
        self.returnTextBlock(curPageIndex);
    }
    
    [super backAction];
    
}

- (void)returnText:(ReturnTextBlock)block {
    
    _returnTextBlock = block;
}

- (void)timeCountView:(CHExaminationSystemTimeCountView *)countView timeToSubmitData:(NSString *)str {
    
    //交卷
    if(self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:submitDataByTimeOver:)]) {
        
        [self.delegate pageViewController:self submitDataByTimeOver:YES];
    }
    
}

- (void)contentViewController:(CHExaminationSystemContentViewController *)vc didSelectRowByTimeIsOver:(BOOL)over {
    
    
    //交卷
    if(self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:submitDataByTimeOver:)]) {
        
        [self.delegate pageViewController:self submitDataByTimeOver:YES];
    }
    
    
}


//解决边缘自动翻页跟控件冲突的问题
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{

    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate

//返回上一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(CHExaminationSystemContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    curPageIndex = index;
    _rView.serialStr = [NSString stringWithFormat:@"%d/%d",(int)(curPageIndex + 1), _examNum];
    
    return [self viewControllerAtIndex:index];
    
    
}

//返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(CHExaminationSystemContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.pageContentArray count]) {
        return nil;
    }
    curPageIndex = index;
    _rView.serialStr = [NSString stringWithFormat:@"%d/%d",(int)(curPageIndex + 1), _examNum];
    return [self viewControllerAtIndex:index];
    
    
}

#pragma mark - 根据index得到对应的UIViewController

- (CHExaminationSystemContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContentArray count] == 0) || (index >= [self.pageContentArray count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    CHExaminationSystemContentViewController *contentVC = [[CHExaminationSystemContentViewController alloc] init];
    contentVC.content = [self.pageContentArray objectAtIndex:index];
    contentVC.delegate = self;
    contentVC.predicate = _predicate;
    
    
    return contentVC;
}

#pragma mark - 数组元素值，得到下标值

- (NSUInteger)indexOfViewController:(CHExaminationSystemContentViewController *)viewController {
    return [self.pageContentArray indexOfObject:viewController.content];
}

#pragma mark - 点击底部的按钮
- (IBAction)clickedBottomButton:(UIButton *)sender {
    if(sender.tag == 101) {
        //上一题
        if(curPageIndex == 0 || curPageIndex == NSNotFound) {
            return;
        }
        curPageIndex -- ;
        _rView.serialStr = [NSString stringWithFormat:@"%d/%d",(int)(curPageIndex + 1), _examNum];
        CHExaminationSystemContentViewController *initialViewController = [self viewControllerAtIndex:curPageIndex];// 得到当前页
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        
        
        
        
    }else if(sender.tag == 102) {
        //交卷
        
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:submitDataByTimeOver:)]) {
            
            [self.delegate pageViewController:self submitDataByTimeOver:NO];
        }
        
        
        

        
        
    }else if(sender.tag == 103) {
        //下一题
        
        if (curPageIndex == [self.pageContentArray count] -1 || curPageIndex == NSNotFound) {
            return;
        }
        
        curPageIndex ++;
        _rView.serialStr = [NSString stringWithFormat:@"%d/%d",(int)(curPageIndex + 1), _examNum];
        CHExaminationSystemContentViewController *initialViewController = [self viewControllerAtIndex:curPageIndex];// 得到当前页
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
    }
    
}









@end
