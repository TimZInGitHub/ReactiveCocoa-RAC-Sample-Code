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
    [self subjectSample];
    [self replaySubjectSample];
}

/**
 *  RACReplaySubject使用示例
    RACReplaySubject:重复提供信号类，RACSubject的子类。
    RACReplaySubject与RACSubject区别:
        RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
    使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
    使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
     RACReplaySubject:底层实现和RACSubject不一样。
    如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    也就是先保存值，在订阅值。
 */
- (void)replaySubjectSample
{
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    //----调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    //----调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    [replaySubject subscribeNext:^(id x) {
        TZLog(@"第一个订阅者接收到的数据%@", x);
    }];
    [replaySubject subscribeNext:^(id x) {
        TZLog(@"第二个订阅者接收到的数据%@", x);
    }];
}

/**
 *  RACSubject使用示例
    RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
    RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
    RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
        使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 */
- (void)subjectSample
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        TZLog(@"第一个订阅者%@", x);
    }];
    [subject subscribeNext:^(id x) {
        TZLog(@"第二个订阅者%@", x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
    
}

/**
 *  RACSignal使用示例
 *  RACSiganl:信号类,一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。
 *   信号类(RACSignal)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。
 *   默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。
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
    RACDisposable *disposable =  [signal subscribeNext:^(id x) {
        
        // block调用时刻：每当有信号发出数据，就会调用block.
        TZLog(@"nextBlock()");
    }];
    
    // 默认一个信号发送数据完毕们就会主动取消订阅.
    // 只要订阅者在,就不会自动取消信号订阅
    // 取消订阅信号
//    [disposable dispose];
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
