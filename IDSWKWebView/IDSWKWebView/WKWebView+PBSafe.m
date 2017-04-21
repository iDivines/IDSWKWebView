//
//  WKWebView+PBSafe.m
//  IDSWKWebView
//
//  Created by colfly on 2017/4/21.
//  Copyright © 2017年 com.cmbchina.com. All rights reserved.
//

#import "WKWebView+PBSafe.h"
#import <objc/runtime.h>
@implementation WKWebView (PBSafe)

+ (void) load{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
        return;
    }
    
    Method oldMethod =class_getInstanceMethod([WKWebView class],
                                              @selector(evaluateJavaScript:completionHandler:));
    
    Method newMethod =class_getInstanceMethod([WKWebView class],
                                              @selector(safeEvaluateJavaScript:completionHandler:));
    
    method_exchangeImplementations(oldMethod,newMethod);
}

- (void)safeEvaluateJavaScript:(NSString *)javaScriptString
             completionHandler:(void (^)(id, NSError *))completionHandler{
    /*IOS8中，如果WKWebView退出并被释放导致completionHandler变成野指针，
     而此时 javaScript Core 还在执行JS代码，待 javaScript Core 执行完毕后会调用completionHandler()，导致 crash.
     通过在 completionHandler 里 retain WKWebView 防止 completionHandler 被过早释放。
     */
    id strongSelf = self;
    [self safeEvaluateJavaScript:javaScriptString completionHandler:^(id r, NSError *e) {
        [strongSelf title];
        if (completionHandler) {
            completionHandler(r, e);
        }
    }];
}

@end
