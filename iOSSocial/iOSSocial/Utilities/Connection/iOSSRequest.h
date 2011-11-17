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