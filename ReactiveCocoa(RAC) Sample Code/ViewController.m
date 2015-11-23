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
#import "TZFlagModel.h"
#import "TZRedView.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet TZRedView *redView;
@property (weak, nonatomic) IBOutlet UIButton *buttion;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self calculate];
    
    //RAC 基本类的使用
    [self signalSample];
    [self subjectSample];
    [self replaySubjectSample];
    
    //RAC遍历数组
    [self arr];
    
    //RAC遍历字典;
    [self dict];
    
    //字典转模型;
    [self modelFormDict];

    //RACSubject替换代理1
    [self replaceDelegate1];
    
    //RAC替换代理2
    [self replaceDelegate2];
    
    //RAC替换KVO
    [self replaceKVO];
    
    //RAC监听事件
    [self observeEvent];
    
    //RAC代替通知
    [self replaceNotification];
    
    //RAC监听事件
    [self observeTextField];
    
    //处理多个请求，都返回结果的时候，统一做处理.
    [self resolveRequests];
    
    //common macro
    [self racCommonMacro];

}

- (void)racCommonMacro
{
    /**
     * RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
     [_textField.rac_textSignal subscribeNext:^(id x) {
     
            _label.text = x;
         }];
     
      用来给某个对象的某个属性绑定信号,只要产生信号内容,就会把内容给属性赋值
     */
    RAC(_label,text) = _textField.rac_textSignal;
    
    
    /**
     *  RACObserve(TARGET, KEYPATH)
     *
     *  @param TARGET       监听的对象
     *  @param KEYPATH      监听的值
     *
     *  @return 返回的是信号
     */
    [RACObserve(self.view, backgroundColor) subscribeNext:^(id x) {
        TZLog(@"常用宏%@", x);
    }];
}

#pragma mark - 
/**
 *  处理多个请求，都返回结果的时候，统一做处理.
 */
- (void)resolveRequests
{
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1, request2]];
    
    /**
     *   @weakify(Obj)和@strongify(Obj),一般两个都是配套使用,解决循环引用问题.
     */
    
    /**
     *  把参数中的数据包装成元组
     RACTuple *tuple = RACTuplePack(@"xmg",@20);
     
      解包元组，会把元组的值，按顺序给参数里面的变量赋值
      name = @"xmg" age = @20
     RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
     */
}

- (void)updateUIWithR1:(id)data r2:(id)data2
{
    TZLog(@"更新UI %@, %@", data, data2);
}

#pragma mark - 
/**
 *  RAC监听事件
 */
- (void)observeTextField
{
    [_textField.rac_textSignal subscribeNext:^(id x) {
        TZLog(@"文字改变了 %@", x);
    }];
}

#pragma mark - 
/**
 *  RAC代替通知
 */
- (void)replaceNotification
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        TZLog(@"键盘弹出了");
    }];
}

#pragma mark -
/**
 *  RAC监听事件
 */
- (void)observeEvent
{
    [[self.buttion rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        TZLog(@"按钮被点击了");
    }];
}

#pragma mark -
/**
 *  RAC替换KVO;
 */
- (void)replaceKVO
{
    [[self.view rac_valuesAndChangesForKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        TZLog(@"KVO, %@", self.view.backgroundColor);
    }];
}

#pragma mark -
/**
 *  RAC代替代理2
    rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
 */
- (void)replaceDelegate2
{
    [[self.redView rac_signalForSelector:@selector(buttionClick:)] subscribeNext:^(id x) {
        TZLog(@"替代代理2");
    }];
}

/**
 *  RACSubject替换代理
 1,给事件接受者添加一个RACSubject代替代理。
 2,在事件接收者的实现中 发送信号 sendNext:
 3,在事件执行者中 创建接受者的信号  XXX.delegateSignal = [RACSubject subject];
 4,最后 订阅代理信号 subscribeNext:
 */
- (void)replaceDelegate1
{
    self.redView.delegateSignal = [RACSubject subject];
    [self.redView.delegateSignal subscribeNext:^(id x) {
        self.view.backgroundColor = TZRandomColor;
        TZLog(@"替代代理1");
    }];
}

#pragma mark -
/**
 *  RAC字典转模型
 */
- (void)modelFormDict
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    
    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:filePath];
    
    NSArray *flags = [[dictArray.rac_sequence map:^id(id value) {
        return [TZFlagModel flagWithDict:value];
    }] array];
}

/**
 *  RAC遍历字典
 */
- (void)dict
{
    NSDictionary *dict = @{@"name": @"TZ", @"age": @"26"};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        
        RACTupleUnpack(NSString *key, NSString *value) = x;
        
        TZLog(@"%@: %@", key, value);
    }];
}

/**
 *  RAC遍历数组
 */
- (void)arr
{
    NSArray *numbers = @[@1, @2, @3, @4];
    
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        TZLog(@"%@", x);
    }];
}

#pragma mark -
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

#pragma mark -
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
