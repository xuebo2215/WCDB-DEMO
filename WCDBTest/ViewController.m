//
//  ViewController.m
//  WCDBTest
//
//  Created by 薛波 on 2018/8/28.
//  Copyright © 2018年 薛波. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation ViewController

- (NSString *)generateUUID
{
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    return result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:UIColor.whiteColor];
    UILabel *label = [[UILabel alloc] init];
    [label setText:@"WCDB TEST"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
    [label setFrame:CGRectMake((SCREEN_WIDTH-100)/2, 100, 100, 44)];
    
    UIButton *inserbtn = [[UIButton alloc] init];
    [inserbtn setTitle:@"insert" forState:UIControlStateNormal];
    [inserbtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [inserbtn addTarget:self action:@selector(insertTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inserbtn];
    [inserbtn setFrame:CGRectMake((SCREEN_WIDTH-100)/2, CGRectGetMaxY(label.frame)+10, 100, 44)];
    
    UIButton *readbtn = [[UIButton alloc] init];
    [readbtn setTitle:@"read" forState:UIControlStateNormal];
    [readbtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [readbtn addTarget:self action:@selector(readTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readbtn];
    [readbtn setFrame:CGRectMake((SCREEN_WIDTH-100)/2, CGRectGetMaxY(inserbtn.frame)+10, 100, 44)];
    
    
    UIButton *readorderbtn = [[UIButton alloc] init];
    [readorderbtn setTitle:@"readOrderTest" forState:UIControlStateNormal];
    [readorderbtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [readorderbtn addTarget:self action:@selector(readOrderTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readorderbtn];
    [readorderbtn setFrame:CGRectMake((SCREEN_WIDTH-200)/2, CGRectGetMaxY(readbtn.frame)+10, 200, 44)];
    
    
    UIButton *readallbtn = [[UIButton alloc] init];
    [readallbtn setTitle:@"readAll" forState:UIControlStateNormal];
    [readallbtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [readallbtn addTarget:self action:@selector(readAll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readallbtn];
    [readallbtn setFrame:CGRectMake((SCREEN_WIDTH-100)/2, CGRectGetMaxY(readorderbtn.frame)+10, 100, 44)];
}

- (void)insertTest
{
    //3AF5E536-6551-4AF5-9E86-C751E2B3B5FA
    NSLog(@"insertres 1 start");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *persons = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i<100; i++) {
            Person *p = [Person new];
            [p setName:[self generateUUID]];
            NSUInteger age = arc4random() % 100;
            NSUInteger high = arc4random() % 100;
            [p setAge:age];
            [p setHigh:high];
            [persons addObject:p];
        }
        BOOL insertres = [Person wcdb_insert:persons into:NSStringFromClass(Person.class)];
        NSLog(@"insertres 1 : %d",insertres);
    });
    
    NSLog(@"insertres 2 start");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *persons = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i<10000; i++) {
            Person *p = [Person new];
            [p setName:[self generateUUID]];
            NSUInteger age = arc4random() % 100;
            NSUInteger high = arc4random() % 100;
            [p setAge:age];
            [p setHigh:high];
            [persons addObject:p];
        }
        BOOL insertres = [Person wcdb_insert:persons into:NSStringFromClass(Person.class)];
        NSLog(@"insertres 2 : %d",insertres);
    });
}

- (void)readAll
{
    {
        NSArray *persons = [Person wcdb_getall];
        NSLog(@"read by wcdb_getall count %ld,%@",persons.count,persons);
    }
}

- (void)readOrderTest
{
    {
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"age"
                                                                     andOperator:ConditionOperator_BETWEEN
                                                                        andValue:@[@1,@30]] orderBy:[OrderInfo OrderInfoWith:@[@"high"] andOrderType:OrderType_DESC] limit:30 offset:100];
        NSLog(@"read by Condition between ORDER ,count %ld,%@",persons.count,persons);
    }
    
    {
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
}

- (void)readTest
{
    
    NSLog(@"readTest  start");
    
    /*dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"name"
                                                                    andOperator:ConditionOperator_Equal
                                                                        andValue:@"BE71977B-011D-48EA-83AF-1237BB99EF71"]];
        NSLog(@"read by Condition equal ,count %ld,%@",persons.count,persons);
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"name"
                                                                     andOperator:ConditionOperator_IN
                                                                        andValue:@[@"FDDBBFFC-75B3-48DA-B324-ADBC68BBA0B8",@"C2DD2455-D535-4BA6-B803-6325442B3E2D"]]];
        NSLog(@"read by Condition in ,count %ld,%@",persons.count,persons);
    });
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"name"
                                                                     andOperator:ConditionOperator_notIN
                                                                        andValue:@[@"FDDBBFFC-75B3-48DA-B324-ADBC68BBA0B8",@"C2DD2455-D535-4BA6-B803-6325442B3E2D"]]];
        NSLog(@"read by Condition notin ,count %ld,%@",persons.count,persons);
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"age"
                                                                     andOperator:ConditionOperator_BETWEEN
                                                                        andValue:@[@28,@29]]];
        NSLog(@"read by Condition between ,count %ld,%@",persons.count,persons);
    });
    
    
   
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"age"
                                                                     andOperator:ConditionOperator_notBETWEEN
                                                                        andValue:@[@28,@29]]];
        NSLog(@"read by Condition not between ,count %ld,%@",persons.count,persons);
    });
    */
    {
        NSArray *persons = [Person wcdb_getUseCondition:[Condition ConditionWith:@"name"
                                                                     andOperator:ConditionOperator_Like
                                                                        andValue:@"%F0EC%"] orderBy:[OrderInfo OrderInfoWith:@[@"age",@"high"] andOrderType:OrderType_DESC]];
        NSLog(@"read by Condition LIKE ,count %ld,%@",persons.count,persons);
    };
    
   
    
    return;
    
    {
        NSArray *persons = [Person wcdb_getUseConditions:[Conditions ConditionsWith:@[[Condition ConditionWith:@"age"
                                                                                                   andOperator:ConditionOperator_Equal|ConditionOperator_More
                                                                                                      andValue:@97],
                                                                                      [Condition ConditionWith:@"high"
                                                                                                   andOperator:ConditionOperator_Equal
                                                                                                      andValue:@37]]
                                                                   andLogicOperator:ConditionLogicOperator_And]];
        NSLog(@"read by Conditions count %ld,%@",persons.count,persons);
    };
    
    
    {
       
        
        NSArray *persons = [Person wcdb_getUseComplexCondition:[ComplexCondition ComplexConditionWith:@[[Conditions ConditionsWith:@[[Condition ConditionWith:@"age"
                                                                                                                                                  andOperator:ConditionOperator_Equal|ConditionOperator_More
                                                                                                                                                     andValue:@97],
                                                                                                                                     [Condition ConditionWith:@"high"
                                                                                                                                                  andOperator:ConditionOperator_Equal|ConditionOperator_More
                                                                                                                                                     andValue:@37]]
                                                                                                                  andLogicOperator:ConditionLogicOperator_And],
                                                                                                        
                                                                                                        [Conditions ConditionsWith:@[[Condition ConditionWith:@"name"
                                                                                                                                                  andOperator:ConditionOperator_Equal
                                                                                                                                                     andValue:@"BE71977B-011D-48EA-83AF-1237BB99EF71"],
                                                                                                                                     [Condition ConditionWith:@"high"
                                                                                                                                                  andOperator:ConditionOperator_More
                                                                                                                                                     andValue:@37]]
                                                                                                                  andLogicOperator:ConditionLogicOperator_And]] andLogicOperator:ConditionLogicOperator_And]];
        NSLog(@"read by ComplexCondition count %ld,%@",persons.count,persons);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
