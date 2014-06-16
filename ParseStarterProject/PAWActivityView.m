//
//  PAWActivityView.m
//  Anywall
//
//  Created by Christopher Bowns on 2/6/12.
//

static CGFloat const kPAWActivityViewActivityIndicatorPadding = 0.f; //10.0f

#import "PAWActivityView.h"

#import <QuartzCore/QuartzCore.h>

@implementation PAWActivityView

@synthesize label;
@synthesize activityIndicator;
@synthesize aView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        aView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width /2 -24, self.frame.size.height /2 -24 -0, 32, 32)]; //48, 48
        aView.backgroundColor = [UIColor clearColor]; // [UIColor colorWithWhite:0.7 alpha:0.4];
        aView.layer.cornerRadius = 24.0f; // 12.0f;
        aView.layer.masksToBounds = YES;
        
        
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
        
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]; //WhiteLarge
        
		self.backgroundColor = [UIColor clearColor];  //[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        
        
        [self addSubview:aView];
		[self addSubview:self.label];
		[self addSubview:activityIndicator];
    }
    return self;
}

- (void)setLabel:(UILabel *)aLabel {
	[label removeFromSuperview];
	[self addSubview:aLabel];
}

- (void)layoutSubviews {
    
    aView.frame = CGRectMake(self.frame.size.width /2 -24, self.frame.size.height /2 -24 -0, 32, 32); //48, 48
    
	// center the label and activity indicator.
	[label sizeToFit];
	label.center = CGPointMake(self.frame.size.width / 2 + 10.f, self.frame.size.height / 2);
	label.frame = CGRectIntegral(label.frame);
    
	//activityIndicator.center = CGPointMake(label.frame.origin.x - (activityIndicator.frame.size.width / 2) - kPAWActivityViewActivityIndicatorPadding, label.frame.origin.y + (label.frame.size.height / 2));
    activityIndicator.center = CGPointMake(label.frame.origin.x - 10 , label.frame.origin.y + (label.frame.size.height / 2) -0);
}

@end
