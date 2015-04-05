//
//  DELoginViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/04/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DELoginViewController.h"

@interface DELoginViewController ()

@end

@implementation DELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)conectaButtonPressed:(UIButton *)sender {
    [self loginWith:self.usuarioTextField.text password:self.passwordTextField.text];
}

- (IBAction)facebookButtonPressed:(UIButton *)sender {
    [self loginWithFacebook];
}

-(void)loginWithFacebook
{
    NSLog(@"login with facebook...");
    
    id<DELoginProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(loginSucces:)]) {
        [strongDelegate loginSucces:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginWith:(NSString *)username password:(NSString *)pass
{
    NSLog(@"login with username and password...");
    
    id<DELoginProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(loginSucces:)]) {
        [strongDelegate loginSucces:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
