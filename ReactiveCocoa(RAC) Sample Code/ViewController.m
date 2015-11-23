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
    [self signalSample];
}

/**
 *  RACSignal使用示例
 */
- (void)signalSample
{
    // 1.创建信号(冷信号) + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    //----首先把didSubscribe保存到信号中，还不会触发。
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        TZLog(@"didSubscribe()");
        
        // 3.发送信号 - (void)sendNext:(id)value
        //----siganl的didSubscribe中调用[subscriber sendNext:@1];
        //----sendNext底层其实就是执行subscriber的nextBlock
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            TZLog(@"signal dealloc, 信号销毁");
        }];
    }];
    
    // 2.订阅信号(热信号),才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    //----也就是调用signal的subscribeNext:nextBlock
    //----subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    //----subscribeNext内部会调用siganl的didSubscribe
    [signal subscribeNext:^(id x) {
        
        // block调用时刻：每当有信号发出数据，就会调用block.
        TZLog(@"nextBlock()");
    }];
}

/**
 *  链式编程示例
 */
- (void)calculate
{
    int result = [NSObject tz_makeCalculate:^(TZCalculateManager *mgr) {
        mgr.add(5).add(3);
    }];
    TZFUNC
    TZLog(@"%d", result);
}



@end
