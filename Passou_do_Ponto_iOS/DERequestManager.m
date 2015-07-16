//
//  DERequestManager.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 06/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DERequestManager.h"
#import <AFNetworking.h>
#import "Constants.h"

@implementation DERequestManager

#pragma mark Singleton Methods

+ (id)sharedRequestManager {
    
    static DERequestManager *sharedRequestManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedRequestManager = [[self alloc] init];
    });
    
    return sharedRequestManager;
}

- (id)init
{
    if (self = [super init]) {
        //initialize properties here
    }
    return self;
}

#pragma mark - Post to server

- (void)postToServer:(NSString *)url
                parameters:(NSDictionary *)param
             caseOfSuccess:(void (^)(NSString *success))successBlock
             caseOfFailure:(void (^)(int errorType, NSString *error))failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // Pede pro manager fazer o Post
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // POST SUCCESS
        
        NSError *json_error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&json_error];
        
        
        if (json_error != nil) { // Erro no Parser JSON
            
            //Le o erro e logga no console
            [self printServerCommunicationMessage:responseObject];
            NSLog(@"JSON Parser Error: %@", json_error);
            
            //Manda erro de volta
            failureBlock(generalError, @"Communication Error");
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [object objectForKey:@"status"];
            
            NSLog(@"Server Msg: %@",[object objectForKey:@"msg"]);
            
            if ([status isEqual: @"OK"]) {
                
                successBlock([NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                
            } else if ([status isEqual: @"ERROR"]){
            
                    failureBlock(generalError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                
            } else if ([status isEqual:@"AUTH_ERROR"]){
                
                    failureBlock(authError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                
            } else if ([status isEqual:@"ACCESS_DENIED"]){
                
                    failureBlock(accessDenied,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
            }
            
        } else NSLog(@"JSON Parser Error, returned object is not a dictionary!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // POST ERROR
        
        NSLog(@"Post Request Error: %@", error);
        failureBlock(generalError,@"Communication Error");

    }];
    
}

- (void)getFromServer:(NSString *)url
       caseOfSuccess:(void (^)(id responseObject, NSString *msg))successBlock
       caseOfFailure:(void (^)(int errorType, NSString *error))failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // Pede pro manager fazer o Post
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Post funcionou
        
        NSError *json_error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&json_error];
        
        
        if (json_error != nil) { // Erro no Parser JSON
            
            //Le o erro e logga no console
            [self printServerCommunicationMessage:responseObject];
            NSLog(@"JSON Parser Error: %@", json_error);
            
            //Manda erro de volta
            failureBlock(0, @"Communication Error");
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [object objectForKey:@"status"];
            
            if ([status isEqual: @"OK"]) {
                
                successBlock([object objectForKey:@"data"], [object objectForKey:@"msg"]);
                
            } else if ([status isEqual: @"ERROR"]){
                
                    failureBlock(generalError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                
            } else if ([status isEqual:@"AUTH_ERROR"]){
                
                    failureBlock(authError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                
            } else if ([status isEqual:@"ACCESS_DENIED"]){
                
                    failureBlock(accessDenied,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
            }
            
        } else NSLog(@"JSON Parser Error, Object is not a NSDictionary! Here it is: %@", object);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Erro no POST
        
        NSLog(@"Post Request Error: %@", error);
        
        failureBlock(0, @"Communication Error");
    }];
    
}

#pragma mark - Picture Methods


- (void)uploadPicture:(UIImage *)image ocorrenciaId:(NSString *)ocorrenciaId caseOfSuccess:(void (^)(NSString *))successBlock caseOfFailure:(void (^)(int, NSString *))failureBlock
{
    if (image != nil) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd-MM-yyyy HH:mm"];
        
        NSString *fileName = [dateFormater stringFromDate:[NSDate date]];
        NSString *fileExtension = @".jpg";
        
        NSDictionary *parameters = @{@"id" : ocorrenciaId,
                                     @"userfile" : fileName};
        
        // Faz o POST
        
        [manager POST:uploadPictureURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            // BODY
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.30)
                                        name:@"userfile"
                                    fileName:[fileName stringByAppendingString:fileExtension]
                                    mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Post funcionou
            
            NSError *json_error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&json_error];
            
            if (json_error != nil) { // Erro no Parser JSON
                
                //Le o erro e logga no console
                [self printServerCommunicationMessage:responseObject];
                NSLog(@"JSON Parser Error: %@", json_error);
                
                //Manda erro de volta
                failureBlock(0, @"Communication Error");
                
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                
                NSString *status = [object objectForKey:@"status"];
                
                NSLog(@"%@",[object objectForKey:@"msg"]);
                
                if ([status isEqual: @"OK"]) {
                    
                    successBlock([object objectForKey:@"msg"]);
                    
                } else if ([status isEqual: @"ERROR"]){
                    
                    failureBlock(generalError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                    
                } else if ([status isEqual:@"AUTH_ERROR"]){
                    
                    failureBlock(authError,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                    
                } else if ([status isEqual:@"ACCESS_DENIED"]){
                    
                    failureBlock(accessDenied,[NSString stringWithFormat:@"%@",[object objectForKey:@"msg"]]);
                }
                
            } else NSLog(@"JSON Parser Error, Object is not a NSDictionary! Here it is: %@", object);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // Erro no POST
            
            NSLog(@"Post Request Error: %@", error);
            failureBlock(0, @"Communication Error");
        }];
    }

}


#pragma mark - Helper Methods

- (void)printServerCommunicationMessage:(NSData *)data
{
    const unsigned char *ptr = [data bytes];
    
    NSMutableString *texto = [[NSMutableString alloc] initWithString:@""];
    
    for (int i=0; i<[data length]; i++) {
        unsigned char c = *ptr++;
        [texto appendString:[NSString stringWithFormat:@"%c",c]];
    }
    
    NSLog(@"Texto bruto enviado: %@",texto);
    
}

@end
