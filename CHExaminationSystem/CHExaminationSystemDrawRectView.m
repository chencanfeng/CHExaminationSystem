


//
//  CHExaminationSystemDrawRectView.m
//  CHExaminationSystem
//
//  Created by 陈灿锋 on 2017/6/14.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHExaminationSystemDrawRectView.h"

#import "CHExaminationSystemPageViewController.h"




//X or Y 方向的间隙
#define marginX 20.f
#define marginY 10.f
//每一行的列数
#define kColumn 6.f



@interface CHExaminationSystemDrawRectView ()
@property (nonatomic,assign)CGFloat w; //圆的直径
@property (nonatomic,assign)CGFloat radius; //圆的半径
@property (nonatomic ,assign) int num; // 显示的个数

@property (nonatomic, strong) NSArray * centerPointsArr;
//@property (nonatomic ,strong) NSArray  *paperSource;  //全部题目


@end



@implementation CHExaminationSystemDrawRectView

@synthesize num,w,radius,centerPointsArr;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.961 green:0.969 blue:0.969 alpha:1.00];
        w = (kScreenWidth - 2 * marginY - (kColumn -1) * marginX)/kColumn;
        radius = w/2.f;
        
        
        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //计算圆圈的中心点
    NSMutableArray * centerArr = [NSMutableArray new];
    for (int i = 0; i < num; i ++) {
        int index = i % 6;
        int row = i/6.f;
        CGPoint p = CGPointMake(marginY + radius  + (marginX + w) * index , marginY + radius  + (w + marginY) * row);
        [centerArr addObject:[NSValue valueWithCGPoint:p]];
    }
    centerPointsArr = [centerArr copy];
    
    //设置画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0.851,0.851,0.851,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度

    UIFont *font;
    if(kScreenWidth >= 414) {
        
        font = [UIFont boldSystemFontOfSize:20.0];
    }else if(kScreenWidth >= 375) {
        
        font = [UIFont boldSystemFontOfSize:17.0];
    }else {
        
       font = [UIFont boldSystemFontOfSize:14.0];
        
    }
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //开始画
    if(self.examState == finished) {
        
        
        UIColor *normalColor = [UIColor colorWithRed:0.259 green:0.686 blue:0.424 alpha:1.00]; //浅绿色
        UIColor *selectColor = [UIColor redColor];
        
        for (int i = 0; i < num ; i ++) {
            NSDictionary *ex = _model[i];
            NSValue *pValue = centerArr[i];
            
            /*画圆*/
            UIColor*aColor = [ex[@"check"] isEqualToString:@"true"] ? normalColor : selectColor;
            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
            CGContextAddArc(context, [pValue CGPointValue].x, [pValue CGPointValue].y, radius, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
            
            /*写文字*/
            NSDictionary *attributes = @{ NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle,
                                          NSForegroundColorAttributeName: [UIColor whiteColor]};
            
            NSString * numStr = [NSString stringWithFormat:@"%d",i + 1];
            [numStr drawInRect:CGRectMake([pValue CGPointValue].x - radius, [pValue CGPointValue].y - w/4.f, w, w/2.f) withAttributes:attributes];
        }
        
    }else if(self.examState == started || self.examState == continued) {
        UIColor *normalColor = [UIColor whiteColor];
        UIColor *selectColor = [UIColor colorWithRed:0.141 green:0.737 blue:0.898 alpha:1.00];//浅蓝色
        
        
        for (int i = 0; i < num ; i ++) {
            
            NSValue *pValue = centerArr[i];
            
            Examination *ex = _model[i];
            
            /*画圆*/
            UIColor*aColor = [ex.result isEqualToString:@""] ? normalColor : selectColor;
            CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
            CGContextAddArc(context, [pValue CGPointValue].x, [pValue CGPointValue].y, radius, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
            
            
            
        }
        
        for (int i = 0; i < num ; i ++) {
            
            NSValue *pValue = centerArr[i];
            
            Examination *ex = _model[i];
            
            /*写文字*/
            UIColor *bColor = [ex.result isEqualToString:@""] ? [UIColor darkGrayColor]:normalColor;
            NSDictionary *attributes = @{ NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle,
                                          NSForegroundColorAttributeName: bColor};
            
            NSString * numStr = [NSString stringWithFormat:@"%d",i + 1];
            [numStr drawInRect:CGRectMake([pValue CGPointValue].x - radius, [pValue CGPointValue].y - w/4.f, w, w/2.f) withAttributes:attributes];
            
            
            
        }
        
        
        
    }
    
}




// 获取view 的高度
- (CGFloat)getDrawRectHeight {
    
    
    
    
    int row = num/6.f;
    
    return marginY + (marginY + w) * (row +1);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.examState == started || self.examState == finished) {
        return;
    }
    
    //get touch position relative to main view
    CGPoint point = [[touches anyObject] locationInView:self];
    
    for (int i = 0 ; i < [centerPointsArr count] ; i ++) {
        NSValue *pValue = centerPointsArr[i];
        CGRect rect = CGRectMake([pValue CGPointValue].x - radius, [pValue CGPointValue].y - radius, 2 * radius, 2 * radius);
        if(CGRectContainsPoint(rect, point)) {
            NSLog(@"在第%d个圈里面",i + 1);
            Examination *obj = _model[i];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(drawRectView:didClickedExamItem:)]) {
                
                [self.delegate drawRectView:self didClickedExamItem:obj];
            }
            
            break;
        }
    }
    
}




- (UIViewController*) viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


- (void)setModel:(NSArray *)model {
    
    _model = model;
    
    num = (int)[model count];
    
//    self.paperSource = [Examination MR_findAllSortedBy:@"t_id" ascending:YES withPredicate:_predicate];
    
}

@end
