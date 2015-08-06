//
//  DEControlPanelEditViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEControlPanelEditViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DEFotosOcorrenciaViewController.h"
#import "DERequestManager.h"
#import "Constants.h"
#import "DENotificationsCentral.h"

@interface DEControlPanelEditViewController ()

@end

@implementation DEControlPanelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.numeroOnibusTextField.delegate = self;
    
    if (self.ocorrenciaENova) {
        
        self.numeroOnibusTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@""];
        self.longitudeTextField.text = self.lng;
        self.latitudeTextField.text = self.lat;
        
    } else {
        
        self.numeroOnibusTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"num_onibus"];
        self.longitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lng"];
        self.latitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lat"];
        self.numeroOrdemTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"num_ordem"];
        
        self.fotoButton.hidden = NO;
    }
    
    // Initialize DEFotosOcorrenciaViewController
    if (!self.fotoViewController) self.fotoViewController = [[DEFotosOcorrenciaViewController alloc] init];
    
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
- (IBAction)okButtonPressed:(UIButton *)sender {
    
    id<DEControlPanelEditProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(editCompleted:)]) {
        
        long selectedRow = [self.tipoOcorrenciaPicker selectedRowInComponent:0] + 1;
        
        NSDictionary *ocorrenciaFoiEditada;
        
        if (self.ocorrenciaENova) {
            
            // monta o dicitionary no formato do INSERT OCORRENCIA
            
            ocorrenciaFoiEditada = @{
                           @"lat" : self.lat,
                           @"lng" : self.lng,
                           @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue],
                           @"usuario_id" : self.userId,
                           @"nr_onibus" : self.numeroOnibusTextField.text,
                           @"nr_ordem" : self.numeroOrdemTextField.text,
                           };
            
        } else {
            
            // monta o dicitionary no formato do EDIT OCORRENCIA
            ocorrenciaFoiEditada = @{@"id" : [self.ocorrenciaEditada objectForKey:@"id"], @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue], @"nr_onibus" : self.numeroOnibusTextField.text, @"usuario_id" : @"1", @"nr_ordem" : self.numeroOrdemTextField.text};
        }
        
        
        NSLog(@"%@",ocorrenciaFoiEditada);
        [strongDelegate editCompleted:ocorrenciaFoiEditada];
    }
    
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fotoButtonPressed:(UIButton *)sender {
    
    // show alert que vai demorar
    DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
    [sharedNC showDialogProgress:@"Carregando fotos" viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    
    NSMutableString *url = [NSMutableString stringWithString:postGetOcorrenciaFotos];
    [url appendString:[self.ocorrenciaEditada objectForKey:@"id"]];

    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:url caseOfSuccess:^(id responseObject, NSString *msg) {
    
        self.photosToBeDeleted = [[NSMutableArray alloc] init];
        self.photosToBeInserted = [[NSMutableArray alloc] init];
        
        // Pegou a listagem de fotos
        self.photoArray = (NSArray *)responseObject;
        
        // Propriedades da DEFotosOcorrenciaViewController
        self.fotoViewController.delegate = self;
        self.fotoViewController.photoArray = self.photoArray;
        self.fotoViewController.needToRefresh = YES;
        
        [self presentViewController:self.fotoViewController animated:YES completion:nil];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        // Erro ao pegar listagem de fotos
        
        DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
        [sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    }];

}


#pragma mark - UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.tiposDeOcorrencia count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.tiposDeOcorrencia[row];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - DEOcorrenciaPhotoProtocol

- (void)photosChosen:(NSArray *)photoArray
{
//    NSLog(@"Self: %@",self.photoArray);
//    NSLog(@"Nova: %@",photoArray);
    
    // Deleta as fotos que não precisa mais
    for (NSDictionary *originalDict in self.photoArray) {
        // percorre a array original de fotos
        
        NSString *originalId = [originalDict objectForKey:@"id"];
        BOOL encontrou = NO;
        
        for (NSDictionary *novoDict in photoArray) {
            // percorre o novo array
            
            NSString *novoId = [novoDict objectForKey:@"id"];
            
            if ([originalId isEqualToString:novoId]) {
                // achou o mesmo ID
                encontrou = YES;
                break;
            }
        }
        
        if (!encontrou) {
            // Deleta
            
            // monta o url
            NSString *idOcorrencia = [self.ocorrenciaEditada objectForKey:@"id"];
            NSString *idFoto = [originalDict objectForKey:@"id"];
            NSString *url = [NSString stringWithFormat:@"%@%@/%@",postDeleteFoto,idOcorrencia,idFoto];
            
            [self.photosToBeDeleted addObject:url];
            
        }
    }
    
    // Insere as novas fotos
    for (NSDictionary *novoDict in photoArray) {
        
        if (![novoDict objectForKey:@"id"]) {
            // não tem o campo ID, ou seja, foto nova. Insere
            
            [self.photosToBeInserted addObject:[novoDict objectForKey:@"photo"]];
        }
    }
    
    [self deleteAndInsertPhotos:[self.ocorrenciaEditada objectForKey:@"id"] toBeDeletedArray:self.photosToBeDeleted toBeInsertedArray:self.photosToBeInserted];
    
}

- (void)deleteAndInsertPhotos:(NSString *)idOcorrencia toBeDeletedArray:(NSArray *)toBeDeleted toBeInsertedArray:(NSArray *)toBeInserted
{

    // show alert que vai demorar
    DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
    [sharedNC showDialogProgress:@"Updating" viewToShow:self.view];
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    // Define errors to be processed when everything is complete.
    __block NSArray *tbdArray = toBeDeleted;
    __block NSArray *tbiArray = toBeInserted;
    __block NSString *ocorrenciaId = idOcorrencia;
    __block NSString *deleteError = nil;
    __block NSString *insertError = nil;
    __block NSString *deleteSuccess = nil;
    __block NSString *insertSucess = nil;
    
    // Create the dispatch group
    dispatch_group_t serviceGroup = dispatch_group_create();

    for (NSString *url in tbdArray) {
        // Start the first service
        dispatch_group_enter(serviceGroup);
        [sharedRM postToServer:url parameters:nil caseOfSuccess:^(NSString *success) {
            
            //success
            deleteSuccess = success;
            dispatch_group_leave(serviceGroup);
        } caseOfFailure:^(int errorType, NSString *error) {
            //failure
            deleteError = error;
            dispatch_group_leave(serviceGroup);
        }];
    }
    
    for (UIImage *image in tbiArray) {
        // Start the second service
        dispatch_group_enter(serviceGroup);
        [sharedRM uploadPicture:image ocorrenciaId:ocorrenciaId caseOfSuccess:^(NSString *success) {
            
            //success
            insertSucess = success;
            dispatch_group_leave(serviceGroup);
        } caseOfFailure:^(int errorType, NSString *error) {
            //failure
            insertError = error;
            dispatch_group_leave(serviceGroup);
        }];
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        // Assess any errors
        if (deleteError || insertError)
        {
            // GENERAL ERROR
            DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
            [sharedNC showDialog:@"Erro ao inserir/deletar foto." dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
        }
        
        // FInal completion code
        [sharedNC dismiss:self.view];
    });
}

#pragma mark - Helper methods

// Dismiss the keyboard when touching anywhere else
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
