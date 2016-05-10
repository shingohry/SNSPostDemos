//
//  SPDPostViewController.m
//  SNSPostDemos
//
//  Created by hiraya.shingo on 2016/04/21.
//  Copyright © 2016年 Shingo Hiraya. All rights reserved.
//

#import "SPDPostViewController.h"
#import "SPDTwitterClient.h"
#import "SPDFacebookClient.h"

@interface SPDPostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) SPDTwitterClient *twitterClient;
@property (nonatomic) SPDFacebookClient *facebookClient;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@end

@implementation SPDPostViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepare];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)cancelButtonDidTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonDidTap:(id)sender
{
    [self post];
}

- (IBAction)addImageButtonDidTap:(id)sender
{
    UIImagePickerController *controller = [UIImagePickerController new];
    controller.delegate = self;
    [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.hidden = NO;
    self.addImageButton.hidden = YES;
}

#pragma mark - Private

- (void)prepare
{
    self.twitterClient = [SPDTwitterClient new];
    self.facebookClient = [SPDFacebookClient new];
}

- (void)post
{
    if (self.isTwitterView) {
        [self postToTwitter];
    } else {
        [self postToFacebook];
    }
}

- (void)postToTwitter
{
    if (self.textView.text.length == 0) {
        NSLog(@"no text");
        return;
    }
    
    [self.twitterClient loadAccountsWithCompletion:^(NSArray *accounts, NSError *error) {
        if (accounts.count == 0) {
            NSLog(@"no twitter account");
            return;
        }
        
        [self.twitterClient postWithAccount:accounts.firstObject
                                    message:self.textView.text
                                      image:self.imageView.image
                                 completion:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"error:%@", error.localizedDescription);
                                     } else {
                                         NSLog(@"success!");
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }
                                 }];
    }];
}

- (void)postToFacebook
{
    if (self.textView.text.length == 0) {
        NSLog(@"no text");
        return;
    }
    
    [self.facebookClient loadAccountWithCompletion:^(ACAccount *account, NSError *error) {
        if (!account || error) {
            NSLog(@"no facebook account");
            return;
        }
        
        [self.facebookClient postWithAccount:account
                                     message:self.textView.text
                                       image:self.imageView.image
                                  completion:^(NSError *error) {
                                      if (error) {
                                          NSLog(@"error:%@", error.localizedDescription);
                                      } else {
                                          NSLog(@"success!");
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  }];
    }];
}

@end
