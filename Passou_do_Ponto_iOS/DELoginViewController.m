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

static NSString *postInsertNewUser = @"http://passoudoponto.org/usuario/insert";

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
#warning tiras os comments aqui de baixo
                         //[self dismissViewControllerAnimated:YES completion:nil];
                         
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
    
    id<DELoginProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
        [strongDelegate loginSuccessful:self.usuarioTextField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cadastraButtonPressed:(UIButton *)sender {
    // Chama a tela de cadastro
    
    self.cvc = [[DECadastroViewController alloc] init];
    self.cvc.delegate = self;
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // Pede pro manager fazer o Post
    
    NSDictionary *teste_param = @{
                               @"login" : @"Danadinho",
                               @"email" : @"alo@alo.com",
                               @"nome" : @"Teta",
                               @"sobrenome" : @"Tetinha",
                               @"nascimento" : @"18/09/1981",
                               @"password" : @"tetassa",
                               @"password_2" : @"tetassa",
                               };
    
    
    [manager POST:postInsertNewUser parameters:/*cadastro*/teste_param success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // Post funcionou
        
        NSError *json_error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&json_error];
        
        
        if (json_error != nil) { // Erro no Parser JSON
            
            NSData *jsonData = responseObject;
            const unsigned char *ptr = [jsonData bytes];
            
            NSMutableString *texto = [[NSMutableString alloc] initWithString:@""];
            
            for (int i=0; i<[jsonData length]; i++) {
                unsigned char c = *ptr++;
                [texto appendString:[NSString stringWithFormat:@"%c",c]];
            }
            
            NSLog(@"JSON Parser Error! Texto: %@ / Erro: %@",texto, json_error);
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [object objectForKey:@"status"];
            
            if ([status isEqual: @"OK"]) {
                NSLog(@"OK Msg: %@",[object objectForKey:@"msg"]);
                
                id<DELoginProtocol> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(loginSuccessful:)]) {
                    
                    [strongDelegate loginSuccessful:[cadastro objectForKey:@"login"]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            } else if ([status isEqual: @"ERROR"]){
                
                DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
                [sharedNC showAlert:self.cvc content:[object objectForKey:@"msg"]];
                
            }
        } else NSLog(@"JSON Parser Error, Object is not a dictionary!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Erro no POST
        
        NSLog(@"Post Request Error: %@", error);
        
    }];

}

@end
