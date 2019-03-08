//
//  SQLProWebViewController.m
//  SQLPro-iOS
//
//  Created by Kyle Hankinson on 8/31/17.
//  Copyright © 2017 Hankinsoft Development, Inc. All rights reserved.
//

#import "SQLProWebViewController.h"
#import "NetworkActivityIndicatorHelper.h"

@import WebKit;

@interface SQLProWebViewController()<WKUIDelegate, WKNavigationDelegate>
{
    WKWebView           * webView;
}

@end

@implementation SQLProWebViewController
{
    NSURL * targetURL;
}

- (id) initWithURL: (NSURL*) _targetURL
{
    self = [super init];
    if(self)
    {
        targetURL = _targetURL;
    }
    
    return self;
} // End of init

- (void) loadView
{
    WKWebViewConfiguration * webConfiguration = [WKWebViewConfiguration new];
    webView = [[WKWebView alloc] initWithFrame: CGRectZero
                                 configuration: webConfiguration];

    webView.UIDelegate = self;
    webView.navigationDelegate = self;

    self.view = webView;
} // End of loadView

- (void) viewDidLoad
{
    [super viewDidLoad];

    NSURLRequest * request = [NSURLRequest requestWithURL: targetURL];
    [webView loadRequest: request];
} // End of viewDidLoad

#pragma mark -
#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [NetworkActivityIndicatorHelper increaseActivity];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [NetworkActivityIndicatorHelper decreaseActivity];
}

@end
