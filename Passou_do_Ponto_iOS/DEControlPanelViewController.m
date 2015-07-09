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

static NSString *postDeletaOcorrencia = @"http://passoudoponto.org/ocorrencia/delete/";

@interface DEControlPanelViewController ()

@end

@implementation DEControlPanelViewController

#pragma mark - Init and Load

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.listaOcorrenciasTableView.allowsSelectionDuringEditing = NO;
    
    self.sharedNC = [DENotificationsCentral sharedNotificationCentral];
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

#pragma mark - Buttons

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - AFNetwork methods

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

@end
