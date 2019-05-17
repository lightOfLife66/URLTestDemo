//
//  ViewController.m
//  URLTextDemo
//
//  Created by 袁涛 on 2019/5/14.
//  Copyright © 2019 Y_T. All rights reserved.
//

#import "ViewController.h"
#import "HHFFilterURL.h"

@interface ViewController ()
@property (nonatomic, strong) HHFFilterURL *objc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    HHFFilterURL *objc = [HHFFilterURL new];
    objc.atomicStop = NO;
    objc.successBlock = ^(NSInteger index, NSString *url) {
        NSLog(@"-----成功了 url:%@",url);
    };
    
    objc.failBlock = ^{
        NSLog(@"-----失败了");
    };
    
    [objc setURLs:@[@"https://m.ii",
                    @"https://m.baidu.com",
                    @"https://m.ii"]];
    _objc = objc;
}


//判断URL 是否有用
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
}



@end
