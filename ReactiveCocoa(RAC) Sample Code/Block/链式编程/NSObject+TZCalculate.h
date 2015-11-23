//
//  NSObject+TZCalculate.h
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TZCalculateManager;

@interface NSObject (TZCalculate)


    //聚合操作代码
+ (int)tz_makeCalculate:(void(^)(TZCalculateManager *))block;

@end
