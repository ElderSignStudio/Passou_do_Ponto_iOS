//
//  Constants.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 11/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#ifndef Passou_do_Ponto_iOS_Constants_h
#define Passou_do_Ponto_iOS_Constants_h

static CGFloat kOverlayHeight = 100.0f;
static NSString *postInsertUrl = @"http://passoudoponto.org/ocorrencia/insert";
static NSString *postGetAllUrl = @"http://passoudoponto.org/ocorrencia/get_all";
static NSString *postGetOccurenceType = @"http://passoudoponto.org/ocorrencia/ref_get_tipos";
static NSString *postGetOccurenceByCurrentUser = @"http://passoudoponto.org/usuario/ocorrencias";
static NSString *postInsertNewUser = @"http://passoudoponto.org/usuario/insert";
static NSString *postDeletaOcorrencia = @"http://passoudoponto.org/ocorrencia/delete/";
static NSString *postOccurenceUpdate = @"http://passoudoponto.org/ocorrencia/update";
static NSString *postGetUserData = @"http://passoudoponto.org/usuario/get_data/";
static NSString *postUpdateUserData = @"http://passoudoponto.org/usuario/update";
static NSString *postGetOcorrenciaFotos = @"http://passoudoponto.org/foto/ocorrencia/";
static NSString *filenameURL = @"http://passoudoponto.org/files/";
static NSString *postDeleteFoto = @"http://passoudoponto.org/foto/delete/";
static NSString *postUserLogin = @"http://passoudoponto.org/login/user_pass";


static NSString *uploadPictureURL = @"http://passoudoponto.org/foto/upload";

static int generalError = 1;
static int authError = 2;
static int accessDenied = 3;

#endif
