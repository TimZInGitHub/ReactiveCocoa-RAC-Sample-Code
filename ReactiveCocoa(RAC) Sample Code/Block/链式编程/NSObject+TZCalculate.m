//
//  NSObject+TZCalculate.m
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "NSObject+TZCalculate.h"
#import "TZCalculateManager.h"

@implementation NSObject (TZCalculate)

+ (int)tz_makeCalculate:(void (^)(TZCalculateManager *))block
{
    TZCalculateManager *mgr = [[TZCalculateManager alloc] init];
    
        //执行计算代码
    block(mgr);
    
    return mgr.result;

}

@end
