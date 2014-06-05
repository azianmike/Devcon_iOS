//
//  CommentTableCell.m
//  Poopify
//
//  Created by Ian Eckles on 11/14/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "CommentTableCell.h"

@implementation CommentTableCell
@synthesize user = _user;
@synthesize comment = _comment;

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

@end
