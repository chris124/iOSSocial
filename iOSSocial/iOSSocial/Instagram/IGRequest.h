//
//  IGRequest.h
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum IGRequestMethod {
    IGRequestMethodGET,
    IGRequestMethodPOST,
    IGRequestMethodDELETE
};
typedef enum IGRequestMethod IGRequestMethod;

typedef void(^IGRequestHandler)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface IGRequest : NSObject {
    BOOL    requiresAuthentication;
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(IGRequestMethod)requestMethod;

@property(nonatomic, readonly, retain) NSDictionary *parameters;
@property(nonatomic, readonly, assign) IGRequestMethod requestMethod;
@property(nonatomic, readonly, retain) NSURL *URL;
@property(nonatomic, assign)    BOOL requiresAuthentication;

- (void)addMultiPartData:(NSData *)data 
                withName:(NSString *)name 
                    type:(NSString *)type;

- (NSURL *)authorizedURL;

- (void)performRequestWithHandler:(IGRequestHandler)handler;

@end
