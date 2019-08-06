//
//  ViewController.m
//  CallFunction_base
//
//  Created by 谢鑫 on 2019/8/6.
//  Copyright © 2019 Shae. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <MessageUI/MessageUI.h>
@interface ViewController ()<WKNavigationDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)clicked:(UIButton *)sender {
    //[self callByOpenURL];
    [self callByMkWebView];
}

- (IBAction)sendMessage:(UIButton *)sender {
    [self sendMessage];
}
- (IBAction)sendMail:(UIButton *)sender {
    [self sendMail];
}
//实现方式一：使用openURL:options:completionHandler:方法
-(void)callByOpenURL{
    NSString *phoneNum=[NSString stringWithFormat:@"telprompt://%@",self.phoneNumberTextField.text];
    NSURL *url=[NSURL URLWithString:phoneNum];
    UIApplication *app=[UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"success__");
        }];
    }
}

//实现方式二：使用WKWebView
-(void)callByMkWebView{
    NSString *phoneNum=[NSString stringWithFormat:@"telprompt://%@",self.phoneNumberTextField.text];
    WKWebView *webview=[[WKWebView alloc]init];
    webview.navigationDelegate =self;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phoneNum]]];
    [self.view addSubview:webview];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //代理方法中实现界面跳转
    NSURL *url=navigationAction.request.URL;
    UIApplication *app=[UIApplication sharedApplication];
    if ([url.absoluteString hasPrefix:@"tel"]) {
        if ([app canOpenURL:url]) {
            [app openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"success2");
            }];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
/*          发送短信            */
-(void)sendMessage{
    if( [MFMessageComposeViewController canSendText] ){
        MFMessageComposeViewController * messageController = [[MFMessageComposeViewController alloc]init];
        messageController.recipients = [NSArray arrayWithObject:self.phoneNumberTextField.text];
        messageController.body = @"来自99iOS的短信!";
        messageController.messageComposeDelegate = self;
        //显示发送信息界面的控制器
        [self presentViewController:messageController animated:YES completion:nil];
    }else{
        NSLog(@"设备不具备短信功能");
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result ==  MessageComposeResultSent) {
        NSLog(@"发送成功");
    }
}
/*         发送邮件     */
-(void)sendMail{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSString *recipient = [NSString stringWithFormat:@"%@",self.phoneNumberTextField.text];
        [controller setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
        //要发送的邮件主题
        [controller setSubject:@"邮件测试"];
        //要发送邮件的内容
        [controller setMessageBody:@"Hello " isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        NSLog(@"设备不具备发送邮件功能");
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        NSLog(@"邮件发送成功");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
