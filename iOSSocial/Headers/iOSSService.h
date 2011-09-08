//
//  iOSSService.h
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol iOSSocialLocalUserProtocol;
@protocol iOSSServiceProtocol <NSObject>

@property(nonatomic, readonly, retain)  NSString *name;
@property(nonatomic, readonly, retain)  NSURL *photoUrl;
@property(nonatomic, readonly, retain)  id<iOSSocialLocalUserProtocol> localUser;

- (id)initWithDictionary:(NSDictionary*)serviceDictionary;

@property(nonatomic, readonly, getter=isConnected)  BOOL connected; // Authentication state

@end

@interface iOSSService : NSObject <iOSSServiceProtocol>

@end
