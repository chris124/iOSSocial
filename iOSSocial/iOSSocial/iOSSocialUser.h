//
//  iOSSocialUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^FetchUserDataHandler)(NSError *error);

@protocol iOSSocialUserProtocol <NSObject>

- (id)initWithDictionary:(NSDictionary*)userDictionary;

@end