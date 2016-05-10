//
//  SPDTwitterClient.m
//  SNSPostDemos
//
//  Created by hiraya.shingo on 2016/04/20.
//  Copyright © 2016年 Shingo Hiraya. All rights reserved.
//

#import "SPDTwitterClient.h"

@import Accounts;
@import Social;

@interface SPDTwitterClient ()

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccountType *accountType;

@end

@implementation SPDTwitterClient

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _accountStore = [ACAccountStore new];
        _accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    
    return self;
}

#pragma mark - Public

- (void)loadAccountsWithCompletion:(void (^)(NSArray *accounts, NSError *error))completion
{
    [self.accountStore requestAccessToAccountsWithType:self.accountType
                                               options:nil
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (granted) {
                                                        NSArray *accounts = [self.accountStore accountsWithAccountType:self.accountType];
                                                        completion(accounts, nil);
                                                    } else {
                                                        completion(nil, error);
                                                    }
                                                });
                                            }];
}

- (void)postWithAccount:(ACAccount *)account
                message:(NSString *)message
                  image:(UIImage *)image
             completion:(void (^)(NSError *error))completion
{
    if (!image) {
        [self postWithAccount:account
                      message:message
                mediaIdString:nil
                   completion:completion];
        return;
    }
    
    [self uploadImageWithAccount:account
                           image:image
                      completion:^(NSString *mediaIdString, NSError *error) {
                          [self postWithAccount:account
                                        message:message
                                  mediaIdString:mediaIdString
                                     completion:completion];
                      }];
}

#pragma mark - Private

- (void)uploadImageWithAccount:(ACAccount *)account
                         image:(UIImage *)image
                    completion:(void (^)(NSString *mediaIdString, NSError *error))completion
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:[NSURL URLWithString:@"https://upload.twitter.com/1.1/media/upload.json"]
                                               parameters:nil];
    [request addMultipartData:UIImageJPEGRepresentation(image, 1.0f)
                     withName:@"media"
                         type:@"image/jpeg"
                     filename:@"image.jpg"];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion(nil, error);
            } else {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
                NSString *mediaIdString = json[@"media_id_string"];
                completion(mediaIdString, nil);
            }
        });
    }];
}

- (void)postWithAccount:(ACAccount *)account
                message:(NSString *)message
          mediaIdString:(NSString *)mediaIdString
             completion:(void (^)(NSError *error))completion
{
    NSDictionary *parameters = nil;
    
    if (mediaIdString) {
        parameters = @{ @"media_ids" : mediaIdString,
                        @"status" : message };
    } else {
        parameters = @{ @"status" : message };
    }
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"]
                                               parameters:parameters];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

@end
