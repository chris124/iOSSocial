/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "iOSSRequest.h"
//#import "UIApplication+iOSSNetworkActivity.h"
#import "ASIFormDataRequest.h"
#import "ASIOARequest.h"

@interface iOSSRequest () {
    NSDictionary *_parameters;
    iOSSRequestMethod _requestMethod;
    NSURL *_URL;
}

@property(nonatomic, readwrite, retain) NSDictionary *parameters;
@property(nonatomic, readwrite, assign) iOSSRequestMethod requestMethod;
@property(nonatomic, readwrite, retain) NSURL *URL;
@property(nonatomic, copy)              iOSSRequestHandler requestHandler;
@property(nonatomic, retain)            ASIOARequest *request;
@property(nonatomic, retain)            NSMutableArray *files;
@property(nonatomic, retain)            NSMutableArray *data;

@end

@implementation iOSSRequest

@synthesize parameters=_parameters;
@synthesize requestMethod=_requestMethod;
@synthesize URL=_URL;
@synthesize requestHandler;
@synthesize request;
@synthesize oauth_params;
@synthesize files;
@synthesize data;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(iOSSRequestMethod)requestMethod
{
    self = [self init];
    if (self) {
        // Initialization code here.
        _URL = url;
        _parameters = parameters;
        _requestMethod = requestMethod;
    }
    
    return self;
}

- (void)performRequestWithHandler:(iOSSRequestHandler)handler
{
    self.requestHandler = handler;
    
    iOSSRequest *theRequest = self;
    
    switch (self.requestMethod) {
        case iOSSRequestMethodGET:
        {
            self.request = [ASIOARequest requestWithURL:self.URL];
            self.request.delegate = self;
            self.request.requestMethod = @"GET";

            if (self.oauth_params) {
                self.request.oauthParams = self.oauth_params;
            }

            self.request.completionBlock = ^(void) {
                if (theRequest.requestHandler) {
                    theRequest.requestHandler([theRequest.request responseData], nil, theRequest.request.error);
                }
            };
            
            [self.request setFailedBlock:^(void) {
                NSLog(@"failed");
                if (theRequest.requestHandler) {
                    theRequest.requestHandler(nil, nil, theRequest.request.error);
                }
            } ];

            [self.request startAsynchronous];
        }
            break;
            
        case iOSSRequestMethodPOST:
        {
            self.request = [ASIOARequest requestWithURL:self.URL];
            self.request.delegate = self;
            self.request.requestMethod = @"POST";

            NSArray *keys = [self.parameters allKeys];
            for (NSString *key in keys) {
                [self.request addPostValue:[self.parameters objectForKey:key] forKey:key];
            }
            
            for (NSDictionary *fileDictionary in self.files) {
                [self.request addFile:[fileDictionary objectForKey:@"path"] forKey:[fileDictionary objectForKey:@"key"]];
            }
            
            self.files = nil;
            
            for (NSDictionary *dataDictionary in self.data) {
                [self.request addData:[dataDictionary objectForKey:@"data"] 
                         withFileName:[dataDictionary objectForKey:@"fileName"] 
                       andContentType:[dataDictionary objectForKey:@"contentType"] 
                               forKey:[dataDictionary objectForKey:@"key"]];
            }
            
            self.data = nil;
            
            if (self.oauth_params) {
                self.request.oauthParams = self.oauth_params;
            }
            
            self.request.completionBlock = ^(void) {
                if (theRequest.requestHandler) {
                    theRequest.requestHandler([theRequest.request responseData], nil, theRequest.request.error);
                }
            };
            
            [self.request setFailedBlock:^(void) {
                NSLog(@"failed");
                if (theRequest.requestHandler) {
                    theRequest.requestHandler(nil, nil, theRequest.request.error);
                }
            } ];

            [self.request startAsynchronous];
        }
            break;
            
        case iOSSRequestMethodDELETE:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    //cwnote: make sure we POP!
    //[[UIApplication sharedApplication] ioss_pushNetworkActivity];
}

- (void)addFile:(NSString*)filePath forKey:(NSString *)key
{
    if (nil == self.files) {
        self.files = [NSMutableArray array];
    }
    
    NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path", key, @"key", nil];
    [self.files addObject:fileDictionary];
}

- (void)addData:(id)theData withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key
{
    if (nil == self.data) {
        self.data = [NSMutableArray array];
    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:theData, @"data", fileName, @"fileName", contentType, @"contentType", key, @"key", nil];
    [self.data addObject:dataDictionary];
}

@end
