//
//  DEControlPanelViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 09/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DENotificationsCentral.h"
#import "DEControlPanelEditViewController.h"
#import "DECadastroViewController.h"

@protocol DEControlPanelProtocol;

@interface DEControlPanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DEControlPanelEditProtocol, DECadastroProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *listaOcorrenciasTableView;

@property (strong, nonatomic) DEControlPanelEditViewController *editViewController;

@property (strong, nonatomic) NSString *userName;
@property (nonatomic, strong) UIImage *userAvatar;

@property (strong, nonatomic) NSArray *userOcorrencias;
@property(strong, nonatomic) NSArray *tipoDeOccorencias;

@property (strong, nonatomic) DENotificationsCentral *sharedNC;

@property (strong, nonatomic) NSString *userId;

@property (weak, nonatomic) id<DEControlPanelProtocol> delegate;

@end

@protocol DEControlPanelProtocol <NSObject>

- (void)doneEditing;

@end
