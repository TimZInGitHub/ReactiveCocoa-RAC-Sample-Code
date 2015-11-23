//
//  TZFlagModel.m
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "TZFlagModel.h"

@implementation TZFlagModel

+ (instancetype)flagWithDict:(NSDictionary *)dict
{
    TZFlagModel *flagModel = [[self alloc] init];
    
    [flagModel setValuesForKeysWithDictionary:dict];
    
    return flagModel;
}

@end
