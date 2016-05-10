//
//  SPDRootViewController.m
//  SNSPostDemos
//
//  Created by hiraya.shingo on 2016/04/20.
//  Copyright © 2016年 Shingo Hiraya. All rights reserved.
//

#import "SPDRootViewController.h"

@import Social;

@implementation UIColor (Hex)

+ (UIColor *)colorWithRGBHex:(NSUInteger)hex
{
    return [UIColor colorWithRed:((hex & 0xFF0000) >> 16) / 255.0f
                           green:((hex & 0x00FF00) >>  8) / 255.0f
                            blue:((hex & 0x0000FF) >>  0) / 255.0f
                           alpha:1.0f];
}

@end

@interface SPDRootViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *twitterComposeVCCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *facebookComposeVCCell;

@end

@implementation SPDRootViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isEqual:self.twitterComposeVCCell]) {
        [self openComposeViewControllerWithServiceType:SLServiceTypeTwitter];
    } else if ([cell isEqual:self.facebookComposeVCCell]) {
        [self openComposeViewControllerWithServiceType:SLServiceTypeFacebook];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    headerFooterView.textLabel.textColor = (section == 0) ? [UIColor colorWithRGBHex:0x55acee] : [UIColor colorWithRGBHex:0x3b5998];
}

#pragma mark - Private

- (void)openComposeViewControllerWithServiceType:(NSString *)serviceType
{
    // アカウントが設定済かをチェックする
    if (![SLComposeViewController isAvailableForServiceType:serviceType]) {
        NSLog(@"%@ is not Available", serviceType);
        return;
    }
    
    // ServiceType を指定して SLComposeViewController を作成
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    // 処理完了時に実行される completionHandler を設定
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultCancelled) {
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Done");
        }
    };
    
    // テキスト、画像、URL を追加したい場合は、SLComposeViewController を表示する前に設定する
//    [composeViewController setInitialText:@"これはデフォルトのテキストです。"];
//    [composeViewController addImage:[UIImage imageNamed:@"image"]];
//    [composeViewController addURL:[NSURL URLWithString:@"http://dev.classmethod.jp/"]];

    // SLComposeViewController を表示
    [self presentViewController:composeViewController animated:YES completion:nil];
}

@end
