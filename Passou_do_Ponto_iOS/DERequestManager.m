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
            
            NSData *jsonData = responseObject;
            const unsigned char *ptr = [jsonData bytes];
            
            NSMutableString *texto = [[NSMutableString alloc] initWithString:@""];
            for (int i=0; i<[jsonData length]; i++) {
                unsigned char c = *ptr++;
                [texto appendString:[NSString stringWithFormat:@"%c",c]];
            }
            
            NSLog(@"JSON Parser Error! Texto: %@ / Erro: %@",texto, json_error);
            
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
       expectedClass:(Class)expectedClass
       caseOfSuccess:(void (^)(id responseObject))successBlock
       caseOfFailure:(void (^)(NSString *error))failureBlock
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
            failureBlock(@"Communication Error");
            
        } else if ([object isKindOfClass:expectedClass]) {
            
            successBlock(object);
            
        } else NSLog(@"JSON Parser Error, Object is not a array!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Erro no POST
        
        NSLog(@"Post Request Error: %@", error);
        
        failureBlock(@"Communication Error");
    }];
    
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
    
    NSLog(@"Texto: %@",texto);
    
}

@end
