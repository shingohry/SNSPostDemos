//
//  SPDTwitterClient.h
//  SNSPostDemos
//
//  Created by hiraya.shingo on 2016/04/20.
//  Copyright © 2016年 Shingo Hiraya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACAccount;

/**
 *  OS に登録済みの Twitter アカウントを利用する処理を行うクラス
 */
@interface SPDTwitterClient : NSObject

/**
 *  OS に登録済みの Twitter アカウントを取得する
 *
 *  @param completion 処理完了時に実行されるハンドラブロック
 */
- (void)loadAccountsWithCompletion:(void (^)(NSArray *accounts, NSError *error))completion;

/**
 *  Twitter へ投稿する
 *
 *  @param account    アカウント情報
 *  @param message    メッセージ
 *  @param image      画像
 *  @param completion 処理完了時に実行されるハンドラブロック
 */
- (void)postWithAccount:(ACAccount *)account
                message:(NSString *)message
                  image:(UIImage *)image
             completion:(void (^)(NSError *error))completion;

@end
