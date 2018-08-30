# WCDB DEMO for iOS OC

WCDB基于WINQ，引入了Objective-C++代码，因此对于所有引入WCDB的源文件，都需要将其后缀.m改为.mm。为减少影响范围，可以通过Objective-C的category特性将其隔离，达到只在model层使用Objective-C++编译，而不影响controller和view。

按照WCDB官方的推荐，我们的查询方法，WINQ的组装只能在对应的Model.mm文件中进行，Model.h方法暴露查询方法。
例如Person.h 中暴露

		- (NSArray*)getPersonAgeMoreThan30;

在Person.m的实现中组装WINQ

		- (NSArray*)getPersonAgeMoreThan30
		{
		  return [Person.wcdb getObjectsWhere:Person.age>30];
		}



这样我的理解是Person中会有很多查询的方法。
我想在任何地方组装WINQ,然后在Person.h中只需要暴露一个类似  + (id)getUseCondition:(WINQ)WINQ; 这样的接口，这样用起来岂不是方便很多？

这个DEMO就是实现了一个Condition，封装了一些简单的WINQ操作。可以在Person类外部使用Condition来封装查询条件。Person.m中实现+ (WCTCondition)formatCondition:(Condition*)condition来做对应的转换。
具体看代码。


 	{
 		/*
 		查询 age 在 @[@1,@30]之间 ，并且用high排序
 		*/

        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"age"
                                                                     andOperator:ConditionOperator_BETWEEN
                                                                        andValue:@[@1,@30]] orderBy:[OrderInfo OrderInfoWith:@[@"high"] andOrderType:OrderType_DESC] limit:30 offset:100];
        NSLog(@"read by Condition between ORDER ,count %ld,%@",persons.count,persons);
    }



    
    {

    	/*
 		查询 age >= 97 ，或者 high > 1 
 		使用 @[@"age",@"high"] 排序
 		limit 150 
 		offset 0
 		*/

        NSArray *persons = [Person wcdb_getUseConditions:[Conditions ConditionsWith:@[[Condition ConditionWith:@"age"
                                                                                                   andOperator:ConditionOperator_Equal|ConditionOperator_More
                                                                                                      andValue:@97],
                                                                                      [Condition ConditionWith:@"high"
                                                                                                   andOperator:ConditionOperator_More
                                                                                                      andValue:@1]]
                                                                   andLogicOperator:ConditionLogicOperator_Or]
                            orderBy:[OrderInfo OrderInfoWith:@[@"age",@"high"] andOrderType:OrderType_DESC] limit:150 offset:0];
        NSLog(@"read by Conditions ORDER count %ld,%@",persons.count,persons);
    }
	


