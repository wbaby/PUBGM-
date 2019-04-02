//
//  DLGMemEntry.m
//  memui
//
//  Created by Liu Junqi on 4/23/18.
//  Copyright © 2018 DeviLeo. All rights reserved.
//

#import "DLGMemEntry.h"
#import "DLGMem.h"
#import "LRKeychain.h"
#import <WebKit/WebKit.h>
#import "JXBWebViewController.h"
@interface iosgods : NSObject

@end

@implementation iosgods

-(id)init
{
    if ((self = [super init]))
    {
    }
    
    return self;
}
//获取当前显示的VC
- (UIViewController *)getCurrentVC{
    //获取默认window
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication]windows];
        for(UIWindow *tmpWindow in windows){
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    
    //获取window的根视图
    UIViewController *currentVC = window.rootViewController;
    while (currentVC.presentedViewController) {
        currentVC = currentVC.presentedViewController;
    }
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [(UITabBarController*)currentVC selectedViewController];
    }
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        currentVC = [(UINavigationController*)currentVC visibleViewController];
    }
    return currentVC;
}
@end

static NSString *MUFENGKEY  =   @"MUFENG";
@interface JD : UIViewController<WKNavigationDelegate,WKUIDelegate>

@end

@implementation JD
static JD *jd = nil;
+ (JD *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (jd == nil) {
            jd = [[self alloc] init];
        }
    });
    return jd;
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"webviewurl==%@",[webView.URL absoluteString]);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"webviewurl==%@",[webView.URL absoluteString]);
    //精确匹配isEqualToString 关键词匹配containsString
    if ([[webView.URL absoluteString] containsString:@"jihuovip"])
    {
        NSString    *udid   =   [[UIDevice currentDevice] identifierForVendor].UUIDString;
        [LRKeychain addKeychainData:udid forKey:MUFENGKEY];
        [webView removeFromSuperview];
    }
}
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
//页面跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //允许页面跳转
    NSLog(@"%@",navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}



/**清除缓存和cookie*/

- (void)cleanCacheAndCookie{
    
    //清除cookies
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]){
        
        [storage deleteCookie:cookie];
        
    }
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    
    [cache removeAllCachedResponses];
    
    [cache setDiskCapacity:0];
    
    [cache setMemoryCapacity:0];
    
}
@end
@implementation DLGMemEntry

static void __attribute__((constructor)) entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[DLGMem alloc] init] launchDLGMem];
    });
    CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    CFNotificationCenterAddObserver(center, NULL, WillEnterForeground, CFSTR("UIApplicationWillEnterForegroundNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"aaaaaaaaaaaaaa");
        UIWindow    *window =   [[UIApplication sharedApplication] keyWindow];
        JXBWKWebView   *webView    =   [[JXBWKWebView alloc] initWithFrame:window.bounds];
        webView.navigationDelegate  =   [JD sharedInstance];
        webView.UIDelegate  =   [JD sharedInstance];
        NSString    *udid   =   [[UIDevice currentDevice] identifierForVendor].UUIDString;
        if ([[LRKeychain getKeychainDataForKey:MUFENGKEY] isEqualToString:udid])
        {
            [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://iosgods.cn"]]];
        }else
        {
            [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://iosgods.cn"]]];
        }
        [window addSubview:webView];
    });
}
static void WillEnterForeground(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    // not required; for example only
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"专业手游破解论坛" message:@"iosGods.cn" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"加入论坛获取更多破解" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iosgods.cn"]];
        NSLog(@"点击取消");
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"QQ350722326" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iosgods.cn/q.heml"]];
        NSLog(@"点击确认");
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"点击警告");
        
    }]];
    [[[[iosgods alloc] init] getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}


@end



