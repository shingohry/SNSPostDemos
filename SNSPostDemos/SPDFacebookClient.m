//
//  SPDFacebookClient.m
//  SNSPostDemos
//
//  Created by hiraya.shingo on 2016/04/20.
//  Copyright © 2016年 Shingo Hiraya. All rights reserved.
//

#import "SPDFacebookClient.h"

@import Accounts;
@import Social;

@interface SPDFacebookClient ()

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccountType *accountType;

@end

@implementation SPDFacebookClient

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _accountStore = [ACAccountStore new];
        _accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    }
    
    return self;
}

#pragma mark - Public

- (void)loadAccountWithCompletion:(void (^)(ACAccount *account, NSError *error))completion
{
    [self requestBasicPermissionsWithCompletion:^(BOOL granted, NSError *error) {
        if (!granted) {
            NSLog(@"no facebook Basic Permissions");
            completion(nil, error);
            return;
        }
        
        [self requestPostPermissionsWithCompletion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    NSLog(@"no facebook Post Permissions");
                    completion(nil, error);
                    return;
                }
                
                NSArray *accounts = [self.accountStore accountsWithAccountType:self.accountType];
                ACAccount *account = accounts.firstObject;
                completion(account, nil);
            });
        }];
    }];
}

- (void)requestBasicPermissionsWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    NSDictionary *options = @{
                              ACFacebookAppIdKey : @"<Enter Facebook App Id here!!!>",
                              ACFacebookPermissionsKey : @[ @"email" ]
                              };
    
    [self.accountStore requestAccessToAccountsWithType:self.accountType
                                               options:options
                                            completion:completion];
}

- (void)requestPostPermissionsWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    NSDictionary *options = @{
                              ACFacebookAppIdKey : @"<Enter Facebook App Id here!!!>",
                              ACFacebookPermissionsKey : @[ @"publish_actions" ],
                              ACFacebookAudienceKey : ACFacebookAudienceEveryone
                              };
    
    [self.accountStore requestAccessToAccountsWithType:self.accountType
                                               options:options
                                            completion:completion];
}

- (void)postWithAccount:(ACAccount *)account
                message:(NSString *)message
                  image:(UIImage *)image
             completion:(void (^)(NSError *error))completion
{
    ACAccountCredential *credential = [account credential];
    NSString *accessToken = [credential oauthToken];
    
    NSDictionary *parameters = @{
                                 @"access_token" : accessToken,
                                 @"message" : message
                                 };
    NSString *url = (image ? @"https://graph.facebook.com/me/photos" : @"https://graph.facebook.com/me/feed");
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodPOST
                                                      URL:[NSURL URLWithString:url]
                                               parameters:parameters];
    
    if (image) {
        [request addMultipartData:UIImageJPEGRepresentation(image, 1.0f)
                         withName:@"source"
                             type:@"multipart/form-data"
                         filename:@"image.jpg"];
    }
    
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

@end
