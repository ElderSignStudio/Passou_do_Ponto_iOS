//
//  DEFotosOcorrenciaViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 20/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DEOcorrenciaPhotoProtocol;

@interface DEFotosOcorrenciaViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *photoButton0;
@property (weak, nonatomic) IBOutlet UIButton *photoButton1;
@property (weak, nonatomic) IBOutlet UIButton *photoButton2;

@property (nonatomic, strong) NSDictionary *photos;
@property (nonatomic, strong) NSMutableDictionary *photosMutable;

@property (nonatomic) NSInteger photoClicked;

@property (nonatomic, weak) id<DEOcorrenciaPhotoProtocol> delegate;

@end

@protocol DEOcorrenciaPhotoProtocol <NSObject>

-(void)photosChosen:(NSDictionary *)photos;

@end

