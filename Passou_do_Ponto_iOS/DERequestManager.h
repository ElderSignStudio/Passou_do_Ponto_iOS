//
//  DERequestManager.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 06/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


@interface DERequestManager : NSObject

- (void)getFromServer:(NSString *)url
        caseOfSuccess:(void (^)(id responseObject, NSString *msg))successBlock
        caseOfFailure:(void (^)(int errorType, NSString *error))failureBlock;

- (void)postToServer:(NSString *)url
          parameters:(NSDictionary *)param
       caseOfSuccess:(void (^)(NSString *success))successBlock
       caseOfFailure:(void (^)(int errorType, NSString *error))failureBlock;

- (void)uploadPicture:(UIImage *)image
         ocorrenciaId:(NSString *)ocorrenciaId
        caseOfSuccess:(void (^)(NSString *success))successBlock
        caseOfFailure:(void (^)(int errorType, NSString *error))failureBlock;

+ (id)sharedRequestManager;

@end
