//
//  DELoginViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/04/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DELoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface DELoginViewController () 

@end

@implementation DELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the Facebook permission to ask from the user
    self.loginButton.readPermissions = @[@"public_profile", @"email"];
    self.loginButton.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        if ([FBSDKAccessToken currentAccessToken]) {
            // User is logged in, do work such as go to next view controller.
            
            id<DELoginProtocol> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
                    
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                {
                     if (!error) {
                         [strongDelegate loginSuccessful:result[@"first_name"]];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                 }];
            }

        }
}


- (IBAction)conectaButtonPressed:(UIButton *)sender {
    [self loginWith:self.usuarioTextField.text password:self.passwordTextField.text];
}


-(void)loginWith:(NSString *)username password:(NSString *)pass
{
    NSLog(@"login with username and password...");
    
    id<DELoginProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
        FBSDKProfile *profile = [[FBSDKProfile alloc] init];
        [strongDelegate loginSuccessful:profile.firstName];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBSDKLoginButton Protocol

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    // The set of permissions declined by the user in the associated request.
    NSSet *declinedPerm = result.declinedPermissions;
    
    if ([declinedPerm containsObject:@"public_profile"]) {
        // o cara não aceitou a permission de profile - logout
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                       message:@"É necessário aceitar as permissões do Facebook para utilizar esta forma de login!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
        // Login OK
        
        id<DELoginProtocol> strongDelegate = self.delegate;
        
        if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
            FBSDKProfile *profile = [[FBSDKProfile alloc] init];
            [strongDelegate loginSuccessful:profile.firstName];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    // Impossivel de acontecer por enquanto
}


@end
