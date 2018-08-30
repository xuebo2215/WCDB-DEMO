//
//  AKCDBBaseModel.h
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger,ConditionOperator)
{
    ConditionOperator_More                  =   1<<0,
    ConditionOperator_Small                 =   1<<1,
    ConditionOperator_Equal                 =   1<<2,
    ConditionOperator_Like                  =   1<<3,
    ConditionOperator_IN                    =   1<<4,
    ConditionOperator_notIN                 =   1<<5,
    ConditionOperator_BETWEEN               =   1<<6,
    ConditionOperator_notBETWEEN            =   1<<7

};

typedef NS_ENUM(NSUInteger,ConditionLogicOperator)
{
    ConditionLogicOperator_And = 0,
    ConditionLogicOperator_Or
};

typedef NS_ENUM(NSUInteger,OrderType)
{
    OrderType_ASC = 0,
    OrderType_DESC
};

@interface OrderInfo : NSObject
@property(nonatomic,copy)NSArray*propertynames;
@property(assign)OrderType orderType;
+ (instancetype)OrderInfoWith:(NSArray*)pnames andOrderType:(OrderType)odt;
@end

/*  封装WINQ
 *  封装了一些简单的WINQ操作 ，避免直接使用WINQ
 *
 */
@interface Condition : NSObject
@property(nonatomic,copy)NSString*propertyname;
@property(assign)ConditionOperator operatorType;
@property(nonatomic,strong)id value;
+ (instancetype)ConditionWith:(NSString*)pname andOperator:(ConditionOperator)op andValue:(id)vl;
@end


@interface Conditions : NSObject
@property(nonatomic,strong)NSArray<Condition*> *conditions;
@property(assign)ConditionLogicOperator logicOperator;
+(instancetype)ConditionsWith:(NSArray<Condition*>*)cdts andLogicOperator:(ConditionLogicOperator)lop;
@end

@interface ComplexCondition : NSObject
@property(nonatomic,strong)NSArray<Conditions*> *complexCondition;
@property(assign)ConditionLogicOperator logicOperator;
+ (instancetype)ComplexConditionWith:(NSArray<Conditions*>*)cdtss andLogicOperator:(ConditionLogicOperator)lop;
@end

@interface AKCDBBaseModel : NSObject
+ (id)wcdb;
+ (BOOL)wcdb_insert:(NSArray*)objs into:(NSString*)table;

+ (id)wcdb_getall;

+ (id)wcdb_getUseCondition:(Condition*)condition;
+ (id)wcdb_getUseCondition:(Condition*)condition orderBy:(OrderInfo*)orderinfo;
+ (id)wcdb_getUseCondition:(Condition*)condition limit:(NSUInteger)limit offset:(NSUInteger)offset;
+ (id)wcdb_getUseCondition:(Condition*)condition orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset;

+ (id)wcdb_getUseConditions:(Conditions*)conditions;
+ (id)wcdb_getUseConditions:(Conditions*)conditions orderBy:(OrderInfo*)orderinfo;
+ (id)wcdb_getUseConditions:(Conditions*)conditions limit:(NSUInteger)limit offset:(NSUInteger)offset;
+ (id)wcdb_getUseConditions:(Conditions*)conditions orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset;


+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition;
+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition orderBy:(OrderInfo*)orderinfo;
+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition limit:(NSUInteger)limit offset:(NSUInteger)offset;
+ (id)wcdb_getUseComplexCondition:(ComplexCondition*)complexCondition orderBy:(OrderInfo*)orderinfo limit:(NSUInteger)limit offset:(NSUInteger)offset;
@end
