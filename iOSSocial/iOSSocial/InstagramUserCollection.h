//
//  InstagramUserCollection.h
//  iOSSocial
//
//  Created by Christopher White on 7/19/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@protocol IGUser;

@protocol IGUserSource <TTModel>

/**
 * The title of this collection of photos.
 */
@property (nonatomic, copy) NSString* title;

/**
 * The total number of users in the source, independent of the number that have been loaded.
 */
@property (nonatomic, readonly) NSInteger numberOfUsers;

/**
 * The maximum index of users that have already been loaded.
 */
@property (nonatomic, readonly) NSInteger maxUserIndex;

- (id<IGUser>)userAtIndex:(NSInteger)index;

@end

@interface InstagramUserCollection : NSObject <TTTableViewDataSource, IGUserSource> {
    id<TTModel> _model;
}

@property(nonatomic, readonly, assign)  NSInteger count;

- (id)initWithDictionary:(NSDictionary*)collectionDictionary;

@end
