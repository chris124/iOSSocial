//
//  InstagramMedia.h
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface InstagramMedia : NSObject <TTPhoto>

- (id)initWithDictionary:(NSDictionary*)mediaDictionary;

@end
