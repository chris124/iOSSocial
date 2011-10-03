//
//  iOSSocialAccountTableViewCell.m
//  iOSSocial
//
//  Created by Christopher White on 8/28/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSocialAccountTableViewCell.h"
#import "iOSSocialLocalUser.h"

@interface iOSSocialAccountTableViewCell () {
    id<iOSSocialLocalUserProtocol> _localUser;
}

@end

@implementation iOSSocialAccountTableViewCell

@synthesize localUser=_localUser;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (id)cellForTableView:(UITableView *)tableView 
{
    NSString *cellID = [self cellIdentifier];
    UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithCellIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;    
}


- (id)initWithCellIdentifier:(NSString *)cellID 
{
    return [self initWithStyle:UITableViewCellStyleSubtitle 
               reuseIdentifier:cellID];
}

- (void)setLocalUser:(id<iOSSocialLocalUserProtocol>)theLocalUser
{
    _localUser = theLocalUser;
    
    UIImageView *logoImageView = (UIImageView*)[self viewWithTag:1];
    if (!logoImageView) {
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 25.0f, 25.0f)];
        [logoImageView setTag:1];
        [self.contentView addSubview:logoImageView];
    }
    
    [self.localUser loadPhotoWithCompletionHandler:^(UIImage *photo, NSError *error) {
        logoImageView.image = photo;
    }];
    
    UILabel *nameLabel = (UILabel*)[self viewWithTag:2];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10.0f, 5.0f, 150.0f, 15.0f)];
        [nameLabel setTag:2];
        nameLabel.font = [UIFont systemFontOfSize:10.0f];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
    }
    
    nameLabel.text = [NSString stringWithFormat:@"%@", self.localUser.username];
    
    UILabel *serviceLabel = (UILabel*)[self viewWithTag:3];
    if (!serviceLabel) {
        serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10.0f, nameLabel.frame.origin.y+nameLabel.frame.size.height+5.0f, 150.0f, 15.0f)];
        [serviceLabel setTag:3];
        serviceLabel.font = [UIFont systemFontOfSize:10.0f];
        serviceLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:serviceLabel];
    }

    if ([self.localUser isAuthenticated]) {
        serviceLabel.text = [NSString stringWithFormat:@"Connected to %@", self.localUser.servicename];
    } else {
        serviceLabel.text = [NSString stringWithFormat:@"Disconnected from %@", self.localUser.servicename];
    }
}

@end
