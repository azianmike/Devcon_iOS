//
//  CommentTableCell.h
//  Poopify
//
//  Created by Ian Eckles on 11/14/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *user;
@property (nonatomic, weak) IBOutlet UITextView *comment;

@end
