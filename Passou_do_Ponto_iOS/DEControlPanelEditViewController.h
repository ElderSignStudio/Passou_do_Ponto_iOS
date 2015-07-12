//
//  DEControlPanelEditViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DEControlPanelEditProtocol;

@interface DEControlPanelEditViewController : UIViewController <UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<DEControlPanelEditProtocol> delegate;

@property (nonatomic) BOOL ocorrenciaENova;

@property (weak, nonatomic) IBOutlet UIPickerView *tipoOcorrenciaPicker;
@property (weak, nonatomic) IBOutlet UITextField *numeroOnibusTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeTextField;
@property (weak, nonatomic) IBOutlet UILabel *longitudeTextField;
@property (weak, nonatomic) IBOutlet UIButton *fotoButton;

@property (nonatomic, strong) NSArray *tiposDeOcorrencia;

// EDIT OCORRENCIAS
@property (nonatomic, strong) NSDictionary *ocorrenciaEditada;

// NEW OCORRENCIA
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

// PHOTO
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDictionary *photoMetadata;

@end

@protocol DEControlPanelEditProtocol <NSObject>

-(void)editCompleted:(NSDictionary *)ocorrenciaAtualizada;

@end
