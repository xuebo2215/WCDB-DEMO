//
//  AKCasimUserPath.m
//  FmdbTest
//
//  Created by Xue Bo on 15-3-16.
//  Copyright (c) 2015年 Jumptest. All rights reserved.
//

#import "AKCUserPath.h"
@interface AKCUserPath()
{
    
}
@end

@implementation AKCUserPath
@synthesize account;
@synthesize documentRoot;
@synthesize documentDataRoot;
@synthesize userRoot;
@synthesize useraudio;
@synthesize userdatabase;
@synthesize userfile;
@synthesize useriamge;
@synthesize usertemp;
@synthesize uservideo;
@synthesize userlog;
@synthesize usersiplog;

static AKCUserPath *mAKCasimUserPath;
+ (AKCUserPath *)getInstance
{
    @synchronized(self)
    {
        if (!mAKCasimUserPath) {
            NSLog(@"AKCasimUserPath %@", @"getInstance");
            mAKCasimUserPath = [[AKCUserPath alloc] init];
            [mAKCasimUserPath showPaths];
        }
    }
    return mAKCasimUserPath;
}

+ (void)destory
{
    @synchronized(self)
    {
        if (mAKCasimUserPath) {
            NSLog(@"AKCasimUserPath destory");
            mAKCasimUserPath = nil;
        }
    }
}

+ (NSString *)documentRoot
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSLog(@"INIT %@", documentDirectory);

        self.documentRoot = documentDirectory;
        NSString *documentRootName = [[NSString alloc]init];
        documentRootName = @"data";
        
        self.account = [NSString stringWithFormat:@"%@_%@",@"wcdb",documentRootName];
        self.documentDataRoot = [self.documentRoot stringByAppendingPathComponent:documentRootName];
        BOOL createDataRoot = [self createDir:self.documentDataRoot];

        if (createDataRoot) {
            self.userRoot = [self.documentDataRoot stringByAppendingPathComponent:@"wcdb"];
            BOOL createuserRoot = [self createDir:self.userRoot];
            if (createuserRoot) {
                self.useraudio = [self.userRoot stringByAppendingPathComponent:@"audio"];
                self.userdatabase = [self.userRoot stringByAppendingPathComponent:@"database"];
                self.userfile = [self.userRoot stringByAppendingPathComponent:@"file"];
                self.useriamge = [self.userRoot stringByAppendingPathComponent:@"image"];
                self.usertemp = [self.userRoot stringByAppendingPathComponent:@"temp"];
                self.uservideo = [self.userRoot stringByAppendingPathComponent:@"video"];

                self.firmwareFilePath = [self.userRoot stringByAppendingPathComponent:@"firmware"];
                self.editComponent = [self.userRoot stringByAppendingPathComponent:@"textedit"];
                if (!([self createDir:self.useraudio] &&
                      [self createDir:self.userdatabase] &&
                      [self createDir:self.userfile] &&
                      [self createDir:self.useriamge] &&
                      [self createDir:self.usertemp] &&
                      [self createDir:self.uservideo] &&
                      [self createDir:self.firmwareFilePath] &&
                      [self createDir:self.editComponent])) {
                    NSLog(@"create userdirs fail!");
                }

            } else {
                NSLog(@"create userRoot fail!");
            }

        } else {
            NSLog(@"create dataRoot fail!");
        }

        self.userlog = [self.documentRoot stringByAppendingPathComponent:@"Logs"];
        self.usersiplog = [self.documentRoot stringByAppendingPathComponent:@"SipLogs"];

        if(![self createDir:self.userlog]) {
            NSLog(@"create userlog fail!");
        }
        
        if(![self createDir:self.usersiplog]) {
            NSLog(@"create usersiplog fail!");
        }
        
        NSLog(@"create all success!");
    }
    return self;
}

- (BOOL)createDir:(NSString *)path
{
    BOOL isDir = YES;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] ? YES : [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)showPaths
{
    NSLog(@"user paths documentRoot: %@ \n documentDataRoot: %@ \n userRoot: %@ \n useraudio: %@ \n userdatabase: %@ \n userfile: %@ \n useriamge: %@ \n usertemp: %@ \n uservideo: %@ \n  userlog: %@ \n usersiplog: %@ \nfirmware: %@, editComponent:%@\n", self.documentRoot, self.documentDataRoot, self.userRoot, self.useraudio, self.userdatabase, self.userfile, self.useriamge, self.usertemp, self.uservideo,  self.userlog,self.usersiplog, self.firmwareFilePath, self.editComponent);
}

@end
