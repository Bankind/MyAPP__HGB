//
//  HGBFileQuickLookTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class HGBFileQuickLookTool;
/**
 快速预览
 */
@protocol HGBFileQuickLookToolDelegate <NSObject>
@optional
/**
 打开成功

 @param quickLook quickLook
 */
-(void)quickLookDidOpenSucessed:(HGBFileQuickLookTool *)quickLook;
/**
 打开失败

 @param quickLook quickLook
 */
-(void)quickLookDidOpenFailed:(HGBFileQuickLookTool *)quickLook;
/**
 关闭快速预览

 @param quickLook quickLook
 */
-(void)quickLookDidClose:(HGBFileQuickLookTool *)quickLook;

@end

@interface HGBFileQuickLookTool : NSObject
#pragma mark 设置
/**
 设置代理

 @param delegate 代理
 */
+(void)setQuickLookDelegate:(id<HGBFileQuickLookToolDelegate>)delegate;
/**
 设置失败提示

 @param withoutFailPrompt 失败提示标志
 */
+(void)setQuickLookWithoutFailPrompt:(BOOL)withoutFailPrompt;
#pragma mark 打开文件
/**
 快速浏览文件

 @param path 路径
 @param parent 父控制器
 */
+(void)lookFileAtPath:(NSString *)path inParent:(UIViewController *)parent;


/**
 快速浏览文件

 @param url 路径
 @param parent 父控制器
 */
+(void)lookFileAtUrl:(NSString *)url inParent:(UIViewController *)parent;
@end
