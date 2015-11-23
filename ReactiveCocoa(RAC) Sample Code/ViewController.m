//
//  ViewController.m
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+TZCalculate.h"
#import "TZCalculateManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self calculate];
}


/**
 *  链式编程示例
 */
- (void)calculate
{
    int result = [NSObject tz_makeCalculate:^(TZCalculateManager *mgr) {
        mgr.add(5).add(3);
    }];
    TZLog(@"%d", result);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
