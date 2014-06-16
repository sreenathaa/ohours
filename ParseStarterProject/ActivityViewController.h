//
//  ActivityViewController.h
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

@interface ActivityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    UISearchBar *theSearchBar;
    UISearchDisplayController *theSearchDisplayController;
    
    
    
}


-(id)initWithArray:(NSArray*)array;


@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic, strong) UILabel *topLbl;

@property (nonatomic, strong) NSArray *activityFromUserCommentsArray;



@end
