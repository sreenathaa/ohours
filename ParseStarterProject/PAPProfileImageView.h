//Need this for h1
//
//  PAPProfileImageView.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//
#import <Parse/Parse.h>

@class PFImageView;
@interface PAPProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;

@end
