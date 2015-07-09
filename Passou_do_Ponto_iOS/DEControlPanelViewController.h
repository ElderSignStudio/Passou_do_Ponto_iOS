//
//  DEControlPanelViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 09/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DENotificationsCentral.h"

@interface DEControlPanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *listaOcorrenciasTableView;

@property (strong, nonatomic) NSArray *userOcorrencias;

@property (strong, nonatomic) DENotificationsCentral *sharedNC;

@end
