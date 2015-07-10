//
//  DEControlPanelEditViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DEControlPanelEditProtocol;

@interface DEControlPanelEditViewController : UIViewController <UIPickerViewDelegate>

@property (nonatomic, weak) id<DEControlPanelEditProtocol> delegate;

@property (weak, nonatomic) IBOutlet UIPickerView *tipoOcorrenciaPicker;
@property (weak, nonatomic) IBOutlet UITextField *numeroOnibusTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeTextField;
@property (weak, nonatomic) IBOutlet UILabel *longitudeTextField;

@property (nonatomic, strong) NSArray *tiposDeOcorrencia;
@property (nonatomic, strong) NSDictionary *ocorrenciaEditada;

@end

@protocol DEControlPanelEditProtocol <NSObject>

-(void)editCompleted:(NSDictionary *)ocorrenciaAtualizada;

@end
