//
//  Person.m
//  WCDBTest
//
//  Created by 薛波 on 2018/8/29.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import "Person.h"
#import "Person+WCTTableCoding.h"



@implementation Person

WCDB_IMPLEMENTATION(Person)

WCDB_SYNTHESIZE(Person, name)
WCDB_SYNTHESIZE(Person, age)
WCDB_SYNTHESIZE(Person, high)

WCDB_PRIMARY(Person, name)

WCDB_INDEX(Person, "_multiIndexSubfix", age)
WCDB_INDEX(Person, "_multiIndexSubfix", name)

- (NSString*)description
{
    return [NSString stringWithFormat:@"name:%@,age:%lu,high:%lu",_name,(unsigned long)_age,(unsigned long)_high];
}

+ (WCTOrderByList)orderBy:(OrderInfo*)ordinfo
{
    WCTOrderByList list;
    for(NSUInteger index = 0; index < ordinfo.propertynames.count; index++)
    {
        NSString *pname = ordinfo.propertynames[index];
        list.push_back(self.PropertyNamed(pname).order(ordinfo.orderType==OrderType_ASC?WCTOrderedAscending:WCTOrderedDescending));
    }
    return list;
}


+ (WCTCondition)formatCondition:(Condition*)condition
{
    if (condition.operatorType & ConditionOperator_More) {
        WCTCondition wWCTCondition = self.PropertyNamed(condition.propertyname) > (WCTValue*)[condition value];
        if (condition.operatorType & ConditionOperator_Equal) {
            wWCTCondition = wWCTCondition || self.PropertyNamed(condition.propertyname) == (WCTValue*)[condition value];
        }
        return wWCTCondition;
    }else if(condition.operatorType & ConditionOperator_Small){
        WCTCondition wWCTCondition = self.PropertyNamed(condition.propertyname) < (WCTValue*)[condition value];
        if (condition.operatorType & ConditionOperator_Equal) {
            wWCTCondition = wWCTCondition || self.PropertyNamed(condition.propertyname) == (WCTValue*)[condition value];
        }
        return wWCTCondition;
    }else if(condition.operatorType == ConditionOperator_Equal) {
        return self.PropertyNamed(condition.propertyname) == (WCTValue*)[condition value];
    }else if(condition.operatorType == ConditionOperator_IN) {
        return self.PropertyNamed(condition.propertyname).in((NSArray<WCTValue*>*)[condition value]);
    }else if(condition.operatorType == ConditionOperator_notIN){
        return self.PropertyNamed(condition.propertyname).notIn((NSArray<WCTValue*>*)[condition value]);
    }else if (condition.operatorType == ConditionOperator_BETWEEN){
        return self.PropertyNamed(condition.propertyname).between((NSArray<WCTValue*>*)[condition value][0], (NSArray<WCTValue*>*)[condition value][1]);
    }else if (condition.operatorType == ConditionOperator_notBETWEEN){
        return self.PropertyNamed(condition.propertyname).notBetween((NSArray<WCTValue*>*)[condition value][0], (NSArray<WCTValue*>*)[condition value][1]);
    }else if (condition.operatorType == ConditionOperator_Like){
        return self.PropertyNamed(condition.propertyname).like((WCTValue*)[condition value]);
    }
    return NULL;
}

+ (WCTCondition)formatConditions:(Conditions*)conditions
{
    if (conditions.conditions.count>0) {
        if (conditions.conditions.count>1) {
            unsigned long logic = conditions.logicOperator;
            __block WCTCondition wWCTCondition = [self formatCondition:conditions.conditions.firstObject];
            for (NSUInteger index = 1; index<conditions.conditions.count; index++) {
                Condition *condition_next = conditions.conditions[index];
                switch (logic) {
                    case ConditionLogicOperator_And:
                        wWCTCondition = wWCTCondition && [self formatCondition:condition_next];
                        break;
                    case ConditionLogicOperator_Or:
                        wWCTCondition = wWCTCondition || [self formatCondition:condition_next];
                        break;
                    default:
                        break;
                }
            }
            return wWCTCondition;
        }else{
            return [self formatCondition:conditions.conditions.firstObject];
        }
    }
    return NULL;
}

+ (WCTCondition)formatComplexCondition:(ComplexCondition*)complexcondition
{
    if (complexcondition.complexCondition.count>0) {
        if (complexcondition.complexCondition.count>1) {
            unsigned long logic = complexcondition.logicOperator;
            __block WCTCondition wWCTCondition = [self formatConditions:complexcondition.complexCondition.firstObject];
            for (NSUInteger index = 1; index<complexcondition.complexCondition.count; index++) {
                Conditions *conditions_next = complexcondition.complexCondition[index];
                switch (logic) {
                    case ConditionLogicOperator_And:
                        wWCTCondition = wWCTCondition && [self formatConditions:conditions_next];
                        break;
                    case ConditionLogicOperator_Or:
                        wWCTCondition = wWCTCondition || [self formatConditions:conditions_next];
                        break;
                    default:
                        break;
                }
            }
            return wWCTCondition;
        }else{
            return [self formatConditions:complexcondition.complexCondition.firstObject];
        }
    }
    
    
    return NULL;
}
@end
