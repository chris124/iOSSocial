//
//  iOSSFormEncodedPOSTRequest.h
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iOSSFormEncodedPOSTRequest : NSMutableURLRequest

+ (id)requestWithURL:(NSURL *)url formParameters:(NSDictionary *)params;
- (id)initWithURL:(NSURL *)url formParameters:(NSDictionary *)params; 

- (void)setFormParameters:(NSDictionary *)params;

@end
