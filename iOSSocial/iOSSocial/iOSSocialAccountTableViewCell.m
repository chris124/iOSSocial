/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
