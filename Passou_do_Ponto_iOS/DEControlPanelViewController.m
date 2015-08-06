//
//  DEControlPanelViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 09/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEControlPanelViewController.h"
#import "DERequestManager.h"
#import "DENotificationsCentral.h"
#import "DEControlPanelEditViewController.h"
#import "Constants.h"
#import "DECadastroViewController.h"

@interface DEControlPanelViewController ()

@end

@implementation DEControlPanelViewController

#pragma mark - Init and Load

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.listaOcorrenciasTableView.allowsSelectionDuringEditing = NO;
    
    self.sharedNC = [DENotificationsCentral sharedNotificationCentral];
    
    self.firstNameLabel.text = self.userName;
    
    if (self.userAvatar) {
        self.avatarImageView.image = self.userAvatar;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)doneButtonPressed:(UIButton *)sender {
    
    id<DEControlPanelProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(doneEditing)]) {
        [strongDelegate doneEditing];
    }
}

- (IBAction)editUsuarioButtonPressed:(UIButton *)sender {
    
    // Chama a tela de cadastro
    
    DECadastroViewController *cvc = [[DECadastroViewController alloc] init];
    
    cvc.delegate = self;
    cvc.novoCadastro = NO;
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:postGetUserData caseOfSuccess:^(id responseObject, NSString *msg) {
        
        // pega os dados do usuario e atualiza
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        cvc.userName = [dict objectForKey:@"login"];
        cvc.email = [dict objectForKey:@"email"];
        cvc.firstName = [dict objectForKey:@"nome"];
        cvc.familyName = [dict objectForKey:@"sobrenome"];
        
        NSString *nasc = (NSString *)[dict objectForKey:@"nasc"];
        
        if ([nasc class] == [NSNull class]) {
            cvc.birthDate = @"01/01/1981";
        } else cvc.birthDate = [dict objectForKey:@"nasc"];
        
        
        
        [self presentViewController:cvc animated:YES completion:nil];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        [self.sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];

    }];
}


#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userOcorrencias count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OcorrenciaId"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OcorrenciaId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)self.userOcorrencias[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [item objectForKey:@"nome"], [item objectForKey:@"num_onibus"]];
    cell.detailTextLabel.text = [item objectForKey:@"dthr_format"];

    
    // Descobre qual o icone para dmostrar
    [self.tipoDeOccorencias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tipo = (NSString *)obj;
       
    if ([tipo isEqualToString:[item objectForKey:@"nome"]]) {
        cell.imageView.image = [self.tipoDeOcorrenciasIcones[idx] objectForKey:@"me"];
    }
        
    }];

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = (NSDictionary *)self.userOcorrencias[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteOcorrencia:[item objectForKey:@"id"] rowNumber:indexPath.row];
    
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = (NSDictionary *)self.userOcorrencias[indexPath.row];
    
    self.editViewController = [[DEControlPanelEditViewController alloc] init];
    self.editViewController.ocorrenciaEditada = item;
    self.editViewController.tiposDeOcorrencia = self.tipoDeOccorencias;
    self.editViewController.delegate = self;
    self.editViewController.ocorrenciaENova = NO;
    self.editViewController.userId = self.userId;
    
    [self presentViewController:self.editViewController animated:YES completion:nil];
}


#pragma mark - AFNetwork Methods

- (void)deleteOcorrencia:(NSString *)id rowNumber:(NSUInteger)row
{
    // monta a url
    NSMutableString *postUrl = [NSMutableString stringWithString:postDeletaOcorrencia];
    [postUrl appendString:id];
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM postToServer:postUrl
                parameters:nil
             caseOfSuccess:^(NSString *success) {
                 
                 // Remoção ocorrida, remove na array tambem
                 
                 NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.userOcorrencias];
                 [tempArray removeObjectAtIndex:row];
                 self.userOcorrencias = [NSArray arrayWithArray:tempArray];
                 
                 [self.listaOcorrenciasTableView reloadData];
             }
             caseOfFailure:^(int errorType, NSString *error) {
                 
                 [self.sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];
                 
             }];
    
    
}

- (void)updateOcorrenciasUsuario
{
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM getFromServer:postGetOccurenceByCurrentUser caseOfSuccess:^(id responseObject, NSString *msg) {
        
        self.userOcorrencias = (NSArray *)responseObject;
        [self.listaOcorrenciasTableView reloadData];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        [self.sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];

    }];
    
    
}

#pragma mark - DEControlPanelEdit Protocol

- (void)editCompleted:(NSDictionary *)ocorrenciaAtualizada
{
    
    // pede para o server atualizar
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
    
    [sharedRM postToServer:postOccurenceUpdate parameters:ocorrenciaAtualizada caseOfSuccess:^(NSString *success) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self updateOcorrenciasUsuario];
        [self.listaOcorrenciasTableView reloadData];
        
        [sharedNC showDialog:success dialogType:YES duration:2.0 viewToShow:self.view];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        [sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    }];
}

#pragma mark - DECadastro Protocol

- (void)cadastroPreenchido:(NSDictionary *)cadastro
{
    DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
    
    // atualiza dados do usuário
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM postToServer:postUpdateUserData parameters:cadastro caseOfSuccess:^(NSString *success) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        //self.userName = [cadastro objectForKey:@"login"];
        self.firstNameLabel.text = [cadastro objectForKey:@"login"];
        
        [sharedNC showDialog:success dialogType:YES duration:2.0 viewToShow:self.view];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        [sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    }];
}

@end
