//
//  iOSSocialUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

typedef void(^FetchUserDataHandler)(NSError *error);

@protocol iOSSUserProtocol;

@protocol iOSSUserSourceProtocol <TTModel>

/**
 * The title of this collection of photos.
 */
@property (nonatomic, copy) NSString* title;

/**
 * The total number of users in the source, independent of the number that have been loaded.
 */
@property (nonatomic, readonly) NSInteger numberOfObjects;

/**
 * The maximum index of users that have already been loaded.
 */
@property (nonatomic, readonly) NSInteger maxObjectIndex;

- (id<iOSSUserProtocol>)objectAtIndex:(NSInteger)index;

@end

@protocol iOSSUserProtocol <NSObject>

/**
 * The user source that the user belongs to.
 */
@property (nonatomic, assign) id<iOSSUserSourceProtocol> dataSource;

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