//
//  CommentsViewController.h
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "HPGrowingTextView.h"

@interface CommentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, HPGrowingTextViewDelegate>


-(id)initWithUserObject:(PFUser*)user;


@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic, strong) UILabel *topLbl;
@property (nonatomic, strong) UIButton *backBtn;


@property (nonatomic, strong) PFUser *theUserObj;
//@property (nonatomic, strong) PFUser *theEventsFromUserObj;

@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) UIView *blankTimelineView;
@property (nonatomic, assign) BOOL shouldAnimateOnReload;



@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HPGrowingTextView *theTextView;
@property (nonatomic, strong) UIButton *sendBtn;







@end
