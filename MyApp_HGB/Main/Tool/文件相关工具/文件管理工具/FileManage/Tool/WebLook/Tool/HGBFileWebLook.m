//
//  HGBFileWebLook.m
//  测试
//
//  Created by huangguangbao on 2017/8/17.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBFileWebLook.h"
#import "HGBFileWebController.h"

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]//系统版本号
#define VERSION 8.0//界限版本号

@interface HGBFileWebLook ()
/**
 浏览器
 */
@property(strong,nonatomic)HGBFileWebController *webView;
/**
 父控制器
 */
@property(strong,nonatomic)UIViewController *parent;
/**
 代理
 */
@property(assign,nonatomic)id<HGBFileWebLookToolDelegate>delegate;
/**
 路径
 */
@property(strong,nonatomic)NSString *url;
/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;
@end
@implementation HGBFileWebLook
static HGBFileWebLook *instance;
#pragma mark init
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBFileWebLook alloc]init];
    }
    return instance;
}
#pragma mark 设置
/**
 设置代理

 @param delegate 代理
 */
+(void)setWebLookDelegate:(id<HGBFileWebLookToolDelegate>)delegate{
    [HGBFileWebLook shareInstance];
    instance.delegate=delegate;
}
/**
 设置失败提示

 @param withoutFailPrompt 失败提示标志
 */
+(void)setWebLookWithoutFailPrompt:(BOOL)withoutFailPrompt{
    [HGBFileWebLook shareInstance];
    instance.withoutFailPrompt=withoutFailPrompt;
}
#pragma mark 打开文件

/**
 快速浏览文件

 @param path 路径
 @param parent 父控制器
 */
+(void)lookFileAtPath:(NSString *)path inParent:(UIViewController *)parent{
    [HGBFileWebLook shareInstance];
    if(parent==nil){
        [HGBFileWebLook alertWithPrompt:@"parent不能为空"];
        if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
            [instance.delegate webLookDidOpenFailed:instance];
        }
        return;
    }
    if(path==nil&&path.length==0){
        [HGBFileWebLook alertWithPrompt:@"路径不能为空"];
        if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
            [instance.delegate webLookDidOpenFailed:instance];
        }
        return;
    }
    [HGBFileWebLook lookFileAtUrl:[[NSURL fileURLWithPath:path] absoluteString] inParent:parent];

}


/**
 快速浏览文件

 @param url 路径
 @param parent 父控制器
 */
+(void)lookFileAtUrl:(NSString *)url inParent:(UIViewController *)parent{
    if(parent==nil){
        [HGBFileWebLook alertWithPrompt:@"parent不能为空"];
        if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
            [instance.delegate webLookDidOpenFailed:instance];
        }
        return;
    }
    if(url==nil&&url.length==0){
        [HGBFileWebLook alertWithPrompt:@"url不能为空"];
        if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
            [instance.delegate webLookDidOpenFailed:instance];
        }
        return;
    }
    if([url containsString:@"http"]||[url containsString:@"https"]){
        if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]){
            [HGBFileWebLook alertWithPrompt:@"url无法发开"];
            if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
                [instance.delegate webLookDidOpenFailed:instance];
            }
            return;
        }
    }else{
        if(![HGBFileWebLook isExitAtFilePath:[[NSURL URLWithString:url] path]]){
            [HGBFileWebLook alertWithPrompt:@"文件不存在"];
            if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenFailed:)]) {
                [instance.delegate webLookDidOpenFailed:instance];
            }
            return;
        }
    }

    instance.parent=parent;
    instance.url=url;

    if (instance.delegate&&[instance.delegate respondsToSelector:@selector(webLookDidOpenSucessed:)]) {
        [instance.delegate webLookDidOpenSucessed:instance];
    }
     instance.webView=[[HGBFileWebController alloc]init];
    [instance.webView loadURL:url];
    [instance.webView createNavigationItemWithTitle:[url lastPathComponent]];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:instance.webView];
    [parent presentViewController:nav animated:YES completion:nil];
}
#pragma mark 提示
/**
 展示内容

 @param prompt 提示
 */
+(void)alertWithPrompt:(NSString *)prompt{
    if(instance==nil||instance.withoutFailPrompt==YES){
        return;
    }
    if((SYSTEM_VERSION<VERSION)){
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
    }else{
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [[HGBFileWebLook currentViewController] presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBFileWebLook findBestViewController:viewController];
}

/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [HGBFileWebLook findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBFileWebLook findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBFileWebLook findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBFileWebLook findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
#pragma mark 文件
/**
 文档是否存在

 @param filePath 归档的路径
 @return 结果
 */
+(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}
@end
