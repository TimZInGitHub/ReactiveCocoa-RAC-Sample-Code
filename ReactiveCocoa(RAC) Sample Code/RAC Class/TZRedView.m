//
//  TZRedView.m
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "TZRedView.h"

@interface TZRedView ()



@end

@implementation TZRedView

- (IBAction)buttionClick:(UIButton *)sender {
    
    if (self.delegateSignal) {
        [self.delegateSignal sendNext:nil];
    }
}


@end
