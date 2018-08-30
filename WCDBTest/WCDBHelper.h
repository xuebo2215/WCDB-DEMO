//
//  WCDBHelper.h
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>
@interface WCDBHelper : NSObject
+ (WCTDatabase*)wcdb;
+ (void)wcdb_close;
@end
