//
//  AKCDBBaseModel.m
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import "AKCDBBaseModel.h"
#import "WCDBHelper.h"

#define GetNSString(x) [NSString stringWithUTF8String:#x]

static inline NSString* FormatConditionOperator(ConditionOperator op) {
    if (op & ConditionOperator_More) {
        if (op & ConditionOperator_Equal) {
            return GetNSString(ConditionOperator_More|ConditionOperator_Equal);
        }
        return GetNSString(ConditionOperator_More);
    }else if(op & ConditionOperator_Small){
        if (op & ConditionOperator_Equal) {
            return GetNSString(ConditionOperator_Small|ConditionOperator_Equal);
        }
        return GetNSString(ConditionOperator_Small);
    }else if(op == ConditionOperator_Equal) {
        return GetNSString(ConditionOperator_Equal);
    }else if(op == ConditionOperator_IN) {
        return GetNSString(ConditionOperator_IN);
    }else if(op == ConditionOperator_notIN){
        return GetNSString(ConditionOperator_notIN);
    }else if (op == ConditionOperator_BETWEEN){
        return GetNSString(ConditionOperator_BETWEEN);
    }else if (op == ConditionOperator_notBETWEEN){
        return GetNSString(ConditionOperator_notBETWEEN);
    }else if (op == ConditionOperator_Like){
        return GetNSString(ConditionOperator_Like);
    }
    return NULL;
}

static inline NSString* FormatConditionLogicOperator(ConditionLogicOperator logicop) {
    switch (logicop) {
        case ConditionLogicOperator_And:
            return GetNSString(ConditionLogicOperator_And);
            break;
        case ConditionLogicOperator_Or:
            return GetNSString(ConditionLogicOperator_Or);
            break;
        default:
            return GetNSString(ConditionLogicOperator_And);
            break;
    }
    return NULL;
}

static inline NSString* FormatOrderType(OrderType ordertype) {
    switch (ordertype) {
        case OrderType_ASC:
            return GetNSString(OrderType_ASC);
            break;
        case OrderType_DESC:
            return GetNSString(OrderType_DESC);
            break;
        default:
            return GetNSString(OrderType_ASC);
            break;
    }
    return NULL;
}

@implementation Condition
- (NSString*)description
{
    return [NSString stringWithFormat:@"propertyname:%@,operatorType:%@,value:%@",_propertyname,FormatConditionOperator(_operatorType),_value];
}

- (instancetype)initWith:(NSString *)pname andOperator:(ConditionOperator)op andValue:(id)vl
{
    self = [super init];
    _propertyname = pname;
    _operatorType = op;
    _value = vl;
    return self;
}
+ (instancetype)ConditionWith:(NSString*)pname andOperator:(ConditionOperator)op andValue:(id)vl
{
    return [[self alloc] initWith:pname andOperator:op andValue:vl];
}
@end

@implementation Conditions
- (NSString*)description
{
    return [NSString stringWithFormat:@"conditions:%@,logicOperator:%@",_conditions,FormatConditionLogicOperator(_logicOperator)];
}

- (instancetype)initWith:(NSArray<Condition *> *)cdts andLogicOperator:(ConditionLogicOperator)lop
{
    self = [super init];
    _conditions = cdts;
    _logicOperator = lop;
    return self;
}

+ (instancetype)ConditionsWith:(NSArray<Condition *> *)cdts andLogicOperator:(ConditionLogicOperator)lop
{
    return [[self alloc] initWith:cdts andLogicOperator:lop];
}
@end

@implementation ComplexCondition
- (NSString*)description
{
    return [NSString stringWithFormat:@"complexCondition:%@,logicOperator:%@",_complexCondition,FormatConditionLogicOperator(_logicOperator)];
}

- (instancetype)initWith:(NSArray<Conditions *> *)cdtss andLogicOperator:(ConditionLogicOperator)lop
{
    self = [super init];
    _complexCondition = cdtss;
    _logicOperator = lop;
    return self;
}
+ (instancetype)ComplexConditionWith:(NSArray<Conditions *> *)cdtss andLogicOperator:(ConditionLogicOperator)lop
{
    return [[self alloc] initWith:cdtss andLogicOperator:lop];
}
@end

@implementation OrderInfo
- (NSString*)description
{
    return [NSString stringWithFormat:@"propertynames:%@,orderType:%@",_propertynames,FormatOrderType(_orderType)];
}
- (instancetype)initWith:(NSArray*)pns andOrderType:(OrderType)odt
{
    self = [super init];
    _propertynames = pns;
    _orderType = odt;
    return self;
}
+(instancetype)OrderInfoWith:(NSArray *)pns andOrderType:(OrderType)odt
{
    return [[self alloc] initWith:pns andOrderType:odt];
}
@end

@implementation AKCDBBaseModel
+ (id)wcdb
{
    return WCDBHelper.wcdb;
}

+ (BOOL)wcdb_insert:(NSArray*)objs
{
    BOOL insertres = [self.wcdb insertObjects:objs into:NSStringFromClass(self)];
    return insertres;
}

+ (WCTProperty)Property:(NSString*)name
{
    return WCTProperty(name);
}

+ (id)wcdb_update:(NSDictionary*)dict where:(Condition*)condition returnNew:(BOOL)returnNew
{
    NSLog(@"%s,%@,%@,%@,%d",__FUNCTION__,dict,NSStringFromClass(self),condition,returnNew);
    __block BOOL updateres = YES;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString*property,id value,BOOL*stop){
        updateres = [self.wcdb updateRowsInTable:NSStringFromClass(self) onProperty:[self Property:property] withValue:value where:[self formatCondition:condition]];
        NSLog(@"%d,%@,%@",updateres,property,value);
        if (!updateres) {
            *stop = YES;
        }
    }];
    if (returnNew && updateres) {
        return [self wcdb_getUseCondition:condition];
    }else{
        return @(updateres);
    }
}

/*
 *  Condition -> WINQ 映射 需要子类复写
 */
+ (WCTCondition)formatCondition:(Condition*)condition
{
    return NULL;
}

+ (WCTCondition)formatConditions:(Conditions*)conditions
{
    return NULL;
}

+ (WCTCondition)formatComplexCondition:(ComplexCondition*)complexCondition
{
    return NULL;
}

+ (WCTOrderByList)orderBy:(OrderInfo*)ord
{
    WCTCondition con;
    return {con.order(WCTOrderedNotSet)};
}

+ (id)wcdb_getall
{
    NSArray *persons = [self.wcdb getAllObjectsOfClass:self fromTable:NSStringFromClass(self)];
    return persons;
}

+ (id)wcdb_getUseCondition:(Condition*)condition
{
    NSLog(@"%s,%@",__FUNCTION__,condition);
    if (condition) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatCondition:condition]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseCondition:(Condition*)condition orderBy:(OrderInfo*)orderinfo
{
    NSLog(@"%s,%@,%@",__FUNCTION__,condition,orderinfo);
    if (condition && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatCondition:condition] orderBy:[self orderBy:orderinfo]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseCondition:(Condition*)condition  limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%lu,%lu",__FUNCTION__,condition,limit,offset);
    if (condition) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatCondition:condition]  limit:limit offset:offset];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseCondition:(Condition*)condition orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%@,%lu,%lu",__FUNCTION__,condition,orderinfo,limit,offset);
    if (condition && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatCondition:condition]  orderBy:[self orderBy:orderinfo] limit:limit offset:offset];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseConditions:(Conditions*)conditions
{
    NSLog(@"%s,%@",__FUNCTION__,conditions);
    if (conditions) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatConditions:conditions]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseConditions:(Conditions*)conditions orderBy:(OrderInfo*)orderinfo
{
    NSLog(@"%s,%@,%@",__FUNCTION__,conditions,orderinfo);
    if (conditions && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatConditions:conditions] orderBy:[self orderBy:orderinfo]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseConditions:(Conditions*)conditions limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%lu,%lu",__FUNCTION__,conditions,limit,offset);
    if (conditions) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatConditions:conditions] limit:limit offset:offset];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseConditions:(Conditions*)conditions orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%@,%lu,%lu",__FUNCTION__,conditions,orderinfo,limit,offset);
    if (conditions && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatConditions:conditions] orderBy:[self orderBy:orderinfo] limit:limit offset:offset];
        return persons;
    }
    return nil;
}


+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition
{
    NSLog(@"%s,%@",__FUNCTION__,complexCondition);
    if (complexCondition) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatComplexCondition:complexCondition]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition orderBy:(OrderInfo*)orderinfo
{
    NSLog(@"%s,%@,%@",__FUNCTION__,complexCondition,orderinfo);
    if (complexCondition && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatComplexCondition:complexCondition] orderBy:[self orderBy:orderinfo]];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%lu,%lu",__FUNCTION__,complexCondition,limit,offset);
    if (complexCondition) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatComplexCondition:complexCondition] limit:limit offset:offset];
        return persons;
    }
    return nil;
}

+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSLog(@"%s,%@,%@,%lu,%lu",__FUNCTION__,complexCondition,orderinfo,limit,offset);
    if (complexCondition && orderinfo) {
        NSArray *persons = [self.wcdb getObjectsOfClass:self fromTable:NSStringFromClass(self) where:[self formatComplexCondition:complexCondition] orderBy:[self orderBy:orderinfo] limit:limit offset:offset];
        return persons;
    }
    return nil;
}
@end
