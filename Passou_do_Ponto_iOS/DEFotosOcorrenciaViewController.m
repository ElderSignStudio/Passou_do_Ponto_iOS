//
//  DEFotosOcorrenciaViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 20/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEFotosOcorrenciaViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DENotificationsCentral.h"
#import "Constants.h"

@interface DEFotosOcorrenciaViewController ()

@end

@implementation DEFotosOcorrenciaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photoButton0.imageView.tag = 0;
    self.photoButton1.imageView.tag = 1;
    self.photoButton2.imageView.tag = 2;

    self.photoMutableArray = [[NSMutableArray alloc] initWithCapacity:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.needToRefresh) {
        
        // DELETA no MutableArray os com ID não existente no array passado.
        NSMutableArray *toBeDeleted = [NSMutableArray array];
        
        [self.photoMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            __block BOOL encontrou = NO;
            
            NSDictionary *dict = (NSDictionary *)obj;
            
            NSString *oldId = [dict objectForKey:@"id"];
            
            if (oldId) {
                
                [self.photoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSDictionary *newDict = (NSDictionary *)obj;
                    
                    NSString *newId = [newDict objectForKey:@"id"];
                    
                    if ([oldId isEqualToString:newId]) {
                        encontrou = YES;
                        *stop = YES;
                    }
                    
                }];
            }
            
            if (!encontrou) {
                [toBeDeleted addObject:self.photoMutableArray[idx]];
            }
            
        }];
        
        [self.photoMutableArray removeObjectsInArray:toBeDeleted];
        
        // INSERT no mutableArray os com ID diferente
        
        NSMutableArray *toBeInserted = [NSMutableArray array];
        
        [self.photoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            __block BOOL encontrou = NO;
            
            NSDictionary *newDict = (NSDictionary *)obj;
            NSString *newId = [newDict objectForKey:@"id"];
            
            [self.photoMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSDictionary *oldDict = (NSDictionary *)obj;
                
                NSString *oldId = [oldDict objectForKey:@"id"];
                
                if ([oldId isEqualToString:newId]) {
                    encontrou = YES;
                    *stop = YES;
                }
                
            }];
            
            if (!encontrou) {
                
                [toBeInserted addObject:self.photoArray[idx]];
            }
            
        }];
        
        for (NSDictionary *insert in toBeInserted) {
            
            NSMutableString *url = [NSMutableString stringWithString:filenameURL];
            [url appendString:[insert objectForKey:@"nome_arquivo"]];
            
            
            NSDictionary *newDict = @{@"id" : [insert objectForKey:@"id"],
                                      @"photo" : [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]};
            
            [self.photoMutableArray addObject:newDict];
            
        }
        
        self.needToRefresh = NO;

    }
    
    [self updateScreenImages];

}

#pragma mark - Buttons

- (IBAction)photoButtonPressed:(UIButton *)sender {
    
    self.photoClicked = sender.imageView.tag;
    
    if ([self.photoMutableArray count] <= self.photoClicked) {
        
        // Não tem foto neste button, abre o picker
        
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
            ipc.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
            
            ipc.allowsEditing = YES;
            ipc.delegate = self;
            
            [self presentViewController:ipc animated:YES completion:nil];
            
        } else {
            // Camera não disponível
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                           message:@"Camera não disponível!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }

    } else {
        
        // Tem foto neste button, DELETE
        
        DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
        
        [sharedNC showAlertYesOrNo:self content:@"Deleta?" ifYesExecute:^{
            
            // Se o cara confirma, deleta de verdade
            
            [self.photoMutableArray removeObjectAtIndex:self.photoClicked];
            [self updateScreenImages];
        }];
        
    }
    
}


- (IBAction)doneButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    id<DEOcorrenciaPhotoProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(photosChosen:)]) {
        
        [strongDelegate photosChosen:(NSArray *)self.photoMutableArray];
    }
    
}

#pragma mark - Photo

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) { // se veio um VIDEO
        NSURL *urlOfVideo = info[UIImagePickerControllerMediaURL];
        NSLog(@"Video URL = %@",urlOfVideo);
        
    } else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){ // se veio uma IMAGEM
        
        //self.photoMetadata = info[UIImagePickerControllerMediaMetadata];
        
        // coloca a foto n array de dict
        
        NSDictionary *newDict = @{@"photo" : info[UIImagePickerControllerOriginalImage]};
        [self.photoMutableArray addObject:newDict];
        
        [self updateScreenImages];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - Camera Helper Methods

// Existe uma camera no device?
- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// Camera suporta fotos?
- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

// Verifica se a camera siporta o tipo de função
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO; // __block: variavel RESULT se modificada dentro de mum block vai aparecer fora tambem
    
    if ([paramMediaType length] == 0) {
        NSLog(@"Media type is empty.");
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}


#pragma mark - Helper Methods

- (void)updateScreenImages
{
    // populate the screen UIImageViews

    if ([self.photoMutableArray count] > 0) {
        
        [self.photoButton0 setImage:[self.photoMutableArray[0] objectForKey:@"photo"] forState:UIControlStateNormal];
    } else [self.photoButton0 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];

    
    if ([self.photoMutableArray count] > 1) {
        
        [self.photoButton1 setImage:[self.photoMutableArray[1] objectForKey:@"photo"] forState:UIControlStateNormal];
    } else [self.photoButton1 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];
    
    if ([self.photoMutableArray count] > 2) {
        
        [self.photoButton2 setImage:[self.photoMutableArray[2] objectForKey:@"photo"] forState:UIControlStateNormal];
    } else [self.photoButton2 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];
    

}

@end
