//
//  UISendingView.m
//  Poopify
//
//  Created by Ian Eckles on 11/20/13.
//  Copyright (c) 2013 Ian Eckles. All rights reserved.
//

#import "UISendingView.h"

#pragma mark - Private Stuff
@interface UISendingView()

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation UISendingView

#pragma mark - Accessors
@synthesize label = _label;
@synthesize spinner = _spinner;

- (UILabel *)label
{
	if (!_label)
	{
		_label = [[UILabel alloc] initWithFrame:self.bounds];
		_label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	}
	return _label;
}

- (UIActivityIndicatorView *)spinner
{
	if (!_spinner) _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	return _spinner;
}

#pragma mark - Initializers
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0.5f]];
		self.label.text = @"Sending…";
		self.label.textColor = self.spinner.color;
		[self.spinner startAnimating];
		
		[self addSubview:self.label];
		[self addSubview:self.spinner];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self setNeedsLayout];
	}
	return self;
}

#pragma mark - Layout Management
#define SPACE_BETWEEN_SPINNER_AND_LABEL 5
- (void)layoutSubviews
{
	//Set label's size to correct one
	CGSize labelSize = [self.label.text sizeWithFont:self.label.font];
	CGRect labelFrame;
	labelFrame.size = labelSize;
	self.label.frame = labelFrame;
	//Center label and spinner (we need it to ommit vertical origin calculation)
	self.label.center = self.center;
	self.spinner.center = self.center;
	//Allign label and spinner horizontaly
	labelFrame = self.label.frame;
	CGRect spinnerFrame = self.spinner.frame;
	CGFloat totalWidth = spinnerFrame.size.width + SPACE_BETWEEN_SPINNER_AND_LABEL + labelSize.width;
	spinnerFrame.origin.x = self.bounds.origin.x+(self.bounds.size.width-totalWidth)/2;
	labelFrame.origin.x = spinnerFrame.origin.x + spinnerFrame.size.width + SPACE_BETWEEN_SPINNER_AND_LABEL;
	self.label.frame = labelFrame;
	self.spinner.frame = spinnerFrame;
}

@end
