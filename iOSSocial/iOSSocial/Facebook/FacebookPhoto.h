//
//  FacebookPhoto.h
//  MadRaces
//
//  Created by Christopher White on 7/8/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface FacebookPhoto : NSObject <TTPhoto>

- (id)initWithDictionary:(NSDictionary*)photoDictionary;

@end
