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
#import "DECadastroViewController.h"
#import <AFNetworking.h>
#import "DENotificationsCentral.h"
#import "DERequestManager.h"
#import "Constants.h"

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
                
                // Pega o first name!
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                {
                     if (!error) {
                         
                         [strongDelegate loginSuccessful:result[@"first_name"]];
//AQUI PARA TIRAR O FB AUTOMATICO
//                         [self dismissViewControllerAnimated:YES completion:nil];
                         
                     } else {
                         FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                         [manager logOut];
                         
                         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                       message:@"Não foi possível obter o seu nome através do Facebook!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
                         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
                         [alert addAction:defaultAction];
                         [self presentViewController:alert animated:YES completion:nil];
                         
                     }
                 }];
            }

        }
}


- (IBAction)conectaButtonPressed:(UIButton *)sender {
    
    DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
    
    NSDictionary *parameters = @{@"login" : self.usuarioTextField.text,
                                 @"password" : self.passwordTextField.text};
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM postToServer:postUserLogin parameters:parameters caseOfSuccess:^(NSString *success) {
        
        id<DELoginProtocol> strongDelegate = self.delegate;
        
        if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
            
            [strongDelegate loginSuccessful:self.usuarioTextField.text];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [sharedNC showDialog:@"Bem vindo!" dialogType:YES duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        [sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    }];
    
    
}


- (IBAction)cadastraButtonPressed:(UIButton *)sender {
    // Chama a tela de cadastro
    
    self.cvc = [[DECadastroViewController alloc] init];
    self.cvc.delegate = self;
    self.cvc.novoCadastro = TRUE;
    [self presentViewController:self.cvc animated:YES completion:nil];
    
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
            
            // Pega o first name!
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    
                    [strongDelegate loginSuccessful:result[@"first_name"]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                    [manager logOut];
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                                   message:@"Não foi possível obter o seu nome através do Facebook!"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }

            }]; // Fim do bloco
        
        }
        
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    // Impossivel de acontecer por enquanto, não da tempo.
}


#pragma mark - DECadastroProtocol

- (void)cadastroPreenchido:(NSDictionary *)cadastro
{
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM postToServer:postInsertNewUser
                parameters:cadastro
             caseOfSuccess:^(NSString *success) {
                 
                 // SUCCESS
                 
                 id<DELoginProtocol> strongDelegate = self.delegate;
                 
                 if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
                     
                     [strongDelegate loginSuccessful:[cadastro objectForKey:@"login"]];
                     [self dismissViewControllerAnimated:YES completion:nil];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                 
             }
             caseOfFailure:^(int errorType, NSString *error) {
                 
                 // FAILURE
                 DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
                 [sharedNC showAlert:self.cvc content:error];

             }];

}

@end
