//
//  iOSSocialUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol iOSSUserSourceProtocol;

@protocol iOSSUserProtocol <NSObject>

/**
 * The user source that the user belongs to.
 */
@property (nonatomic, assign) id<iOSSUserSourceProtocol> userSource;

/**
 * The index of the user within its user source.
 */
@property (nonatomic) NSInteger index;

- (id)initWithDictionary:(NSDictionary*)userDictionary;

@end
/*
@interface iOSSocialUser : NSObject <iOSSUserProtocol>

@property (nonatomic, assign) id<iOSSUserSourceProtocol> userSource;

@end
*/