//
//  WCDBHelper.m
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import "WCDBHelper.h"
#import "AKCUserPath.h"
#import "Person.h"

@interface WCDBHelper()
@property (nonatomic,strong) WCTDatabase *database;
@property (nonatomic,strong,readonly) NSArray <Class>*tableClasss;
@end
@implementation WCDBHelper
+(instancetype)shareHelper
{
    static WCDBHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[WCDBHelper alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    _tableClasss = @[Person.class];
    return self;
}

+ (void)wcdb_open
{
    if ([[self shareHelper] database] == nil) {
        [[self shareHelper] setDatabase:[[WCTDatabase alloc] initWithPath:[AKCUserPath.getInstance.userdatabase stringByAppendingPathComponent:@"wcdbtest.encryptdb"]]];
        
        [[[self shareHelper] database] setConfig:^BOOL(std::shared_ptr<WCDB::Handle> handle, WCDB::Error &error) {
            return handle->exec(WCDB::StatementPragma().pragma(WCDB::Pragma::CacheSize, -2000));
        } forName:@"CacheSizeConfig"];
        
        [[[self shareHelper] tableClasss] enumerateObjectsUsingBlock:^(Class tableclass,NSUInteger index,BOOL *stop){
            BOOL createsuccess = [[[self shareHelper] database] createTableAndIndexesOfName:NSStringFromClass(tableclass)
                                                                                  withClass:tableclass];
            NSLog(@"wcdb,create table %@,%@",NSStringFromClass(tableclass),createsuccess?@"success":@"fail");
        }];
    }
}

+ (WCTDatabase*)wcdb
{
    [self wcdb_open];
    return [[self shareHelper] database];
}

+ (void)wcdb_close
{
    if ([[self shareHelper] database]) {
        [[[self shareHelper] database] close:^(){
            NSLog(@"wcdb,closed");
        }];
        [[self shareHelper] setDatabase:nil];
    }
}
@end
