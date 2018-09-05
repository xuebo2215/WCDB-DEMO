//
//  Person.h
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKCDBBaseModel.h"
@interface Person : AKCDBBaseModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) NSUInteger high;
@property (nonatomic, assign) NSUInteger time;
@end
