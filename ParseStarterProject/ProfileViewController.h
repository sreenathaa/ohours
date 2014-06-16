//
//  ProfileViewController.h
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>


@property (nonatomic, strong) UITableView *theTableView;


@property (nonatomic, strong) PFUser *theUserObj; 

- (id)initWithUser:(PFUser *)theUser;




@end
