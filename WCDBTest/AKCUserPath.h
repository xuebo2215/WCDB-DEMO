//
//  AKCasimUserPath.h
//  FmdbTest
//
//  Created by Xue Bo on 15-3-16.
//  Copyright (c) 2015年 Jumptest. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface AKCUserPath : NSObject
/*
 目录结构
 document----data|
                  ---|--userRoot(username)---|----audio//音频目录
                                  |----database//数据库
                                  |----file//文件
                                  |----image//图片
                                  |----temp
                                  |----video//视频
 document----
          |Logs  //log目录
          |SipLogs //sip log 目录
 
 
 
 */



//用来检测账户有没有发生改变 / 2016-08-08 15:29:18xb
//解决切换不同账户，或者不同服务器切换账户会有路径没有切换的bug
@property (atomic, copy) NSString *account;

//应用程序docoument根目录
@property (atomic, copy) NSString *documentRoot;
//应用程序数据根目录
@property (atomic, copy) NSString *documentDataRoot;
//应用程序用户数据根目录
@property (atomic, copy) NSString *userRoot;
//应用程序用户音频目录
@property (atomic, copy) NSString *useraudio;
//应用程序用户数据库目录
@property (atomic, copy) NSString *userdatabase;
//应用程序用户文件目录
@property (atomic, copy) NSString *userfile;
//应用程序用户图片目录
@property (atomic, copy) NSString *useriamge;
//应用程序用户temp目录
@property (atomic, copy) NSString *usertemp;
//应用程序用户视频目录
@property (atomic, copy) NSString *uservideo;
//应用程序用户日志目录
@property (atomic, copy) NSString *userlog;
//应用程序用户sip log 目录
@property (atomic, copy) NSString *usersiplog;
//MUC升级固件保存路径
@property (atomic, copy) NSString *firmwareFilePath;
@property (atomic, copy) NSString *editComponent;
+ (AKCUserPath *)getInstance;
+ (void)destory;
+ (NSString *)documentRoot;
@end
