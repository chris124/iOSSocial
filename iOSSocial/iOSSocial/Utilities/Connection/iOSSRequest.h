//
//  iOSSRequest.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIOARequest.h"

enum iOSSRequestMethod {
    iOSSRequestMethodGET,
    iOSSRequestMethodPOST,
    iOSSRequestMethodDELETE
};
typedef enum iOSSRequestMethod iOSSRequestMethod;

//typedef void(^iOSSRequestHandler)(NSString *responseString, NSError *error);
typedef void(^iOSSRequestHandler)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface iOSSRequest : NSObject <ASIHTTPRequestDelegate> {
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(iOSSRequestMethod)requestMethod;

@property(nonatomic, readonly, retain)  NSDictionary *parameters;
@property(nonatomic, readonly, assign)  iOSSRequestMethod requestMethod;
@property(nonatomic, readonly, retain)  NSURL *URL;
@property(nonatomic, retain)            NSDictionary *oauth_params;

- (void)performRequestWithHandler:(iOSSRequestHandler)handler;

- (void)addFile:(NSString*)filePath forKey:(NSString *)key;

- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

@end