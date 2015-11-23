//
//  TZCalculateManager.m
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "TZCalculateManager.h"

@implementation TZCalculateManager


/**
 *  方法的返回值是block,block必须有返回值（本身对象），block参数（需要操作的值）
 */
- (TZCalculateManager *(^)(int))add
{
    return ^(int value){
        _result += value;
        
        return self;
    };
}

@end
