//
//  IGUserFollowsDataSource.h
//  PhotoStream
//
//  Created by Christopher White on 8/8/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialUser.h"
/*
@protocol IGUser;

@protocol IGUserFollowsDataSourceProtocol <TTModel>

@property (nonatomic, copy) NSString* title;

@property (nonatomic, readonly) NSInteger numberOfObjects;

@property (nonatomic, readonly) NSInteger maxObjectIndex;

- (id<IGUser>)objectAtIndex:(NSInteger)index;

@end
*/
@interface IGUserFollowsDataSource : NSObject <TTTableViewDataSource, iOSSUserSourceProtocol /*IGUserFollowsDataSourceProtocol*/> {
    id<TTModel> _model;
}

@property(nonatomic, readonly, assign)  NSInteger count;

- (id)initWithDictionary:(NSDictionary*)collectionDictionary;

@end