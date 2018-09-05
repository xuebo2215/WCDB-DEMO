//
//  Person+WCTTableCoding.h
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import "Person.h"
#import <WCDB/WCDB.h>

@interface Person (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(age)
WCDB_PROPERTY(high)
WCDB_PROPERTY(time)

@end
