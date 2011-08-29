//
//  iOSSocialAccountTableViewCell.h
//  iOSSocial
//
//  Created by Christopher White on 8/28/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "PRPSmartTableViewCell.h"

@protocol iOSSocialLocalUserProtocol;
@interface iOSSocialAccountTableViewCell : PRPSmartTableViewCell

@property(nonatomic, retain)   id<iOSSocialLocalUserProtocol> localUser;

@end
