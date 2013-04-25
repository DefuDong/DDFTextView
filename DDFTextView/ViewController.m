//
//  ViewController.m
//  DDFTextView
//
//  Created by 董德富 on 13-4-25.
//  Copyright (c) 2013年 董德富. All rights reserved.
//

#import "ViewController.h"
#import "DDFTextView.h"

@interface ViewController ()
<
  DDFTextViewDelegate
>
{
    IBOutlet UILabel *_label;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *str =  @"This[jk01]w tr @y[jk12]ou! Developed b[jk21]y->@董德富 for #iPh☞one #ObjC...❤ My GitHub page: https://github.com/DefuDong/CustomTextView.git  @支持中文。@四句iovjeiovjer // ogkdopg[jk01][jk30][jk_]@返回岁hfiowhiuwfiowejeiojdiojvjiojwiow我还veuiohvuiervu➤ioejiojoiiowfifksjfios飞机哦isjfiosf";
    
    _label.text = str;
    
    DDFTextView *textView = [[DDFTextView alloc] initWithFrame:CGRectMake(20, 230, 280, 200)];
    textView.backgroundColor = [UIColor lightGrayColor];
    textView.delegate = self;
    textView.text = str;
    textView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:textView];
    
    
    float height = [DDFTextView heightOfText:str font:textView.font limitSize:textView.frame.size];
    CGRect rect = textView.frame;
    rect.size.height = height;
    textView.frame = rect;
}


- (void)ddfTextViewDidTouchSuccess:(NSString *)string {
    NSLog(@"%@", string);
}


@end
