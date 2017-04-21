//
//  PBWKWebViewController.m
//  IDSWKWebView
//
//  Created by colfly on 2017/4/21.
//  Copyright © 2017年 com.cmbchina.com. All rights reserved.
//

#import "PBWKWebViewController.h"
@import WebKit;

@interface PBWKWebViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation PBWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 2)];
    [self.view addSubview:_progressView];
    //监听网页加载进度
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    //get请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [_webView loadRequest:request];
}

#pragma mark -
#pragma mark - WKNavigationDelegate

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //删除a标签的target属性，解决tager=_blank是点击没反应的问题
    //TODO:关注删除了target属性后时候引入其他问题
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

//Invoked when an error occurs while starting to load data for the main frame.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
}

// @abstract Invoked when an error occurs during a committed main frame navigation.
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

// web content进程在网页占用内存过大时会被系统强制结束从而导致白屏
// ios9之后web content进程结束的时候会执行该方法,重新加载网页解决白屏问题，但是会导致网页多次被加载
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    
}



#pragma mark -
#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == _webView) {
        [_progressView setAlpha:1.0f];
        [self.progressView setProgress:_webView.estimatedProgress animated:YES];
        ///***
        if (_webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [_progressView setProgress:0.0f animated:NO];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
    }
}

#pragma mark -
#pragma mark -

- (void)dealloc{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


@end
