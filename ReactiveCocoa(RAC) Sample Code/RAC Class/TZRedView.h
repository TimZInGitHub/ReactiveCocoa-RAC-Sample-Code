//
//  TZRedView.h
//  ReactiveCocoa(RAC) Sample Code
//
//  Created by Tim.Z on 11/23/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZRedView : UIView

@property (nonatomic, strong) RACSubject *delegateSignal;

- (IBAction)buttionClick:(UIButton *)sender;

@end
