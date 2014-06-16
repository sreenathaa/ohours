//
//  ActivityViewController.m
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//


//static CGFloat const kPAWWallPostTableViewFontSize = 13.0f; // 18.f;
//static CGFloat const kPAWWallPostTableViewCellWidth = 245.f; // 230 // subject to change.
//
//static CGFloat const kPAWWallPostTableViewNameFontSize = 18.25f;


// Cell dimension and positioning constants
//static CGFloat const kPAWCellPaddingTop = 5.f;
//static CGFloat const kPAWCellPaddingBottom = 1.f;
//static CGFloat const kPAWCellPaddingSides = 0.f;
//static CGFloat const kPAWCellTextPaddingTop = 5.f;
//static CGFloat const kPAWCellTextPaddingBottom = 5.f;
//static CGFloat const kPAWCellTextPaddingSides = 5.f;

//static CGFloat const kPAWCellUsernameHeight = 15.f;
//static CGFloat const kPAWCellBkgdHeight = 32.f;
//static CGFloat const kPAWCellBkgdOffset = kPAWCellBkgdHeight - kPAWCellUsernameHeight;

static NSInteger kPAWCellImageTag = 1;
static NSInteger kPAWCellNameTag = 2;
static NSInteger kPAWCellTextLabelTag = 3;
static NSInteger kPAWCellAlphaViewTag = 4;
static NSInteger kPAWCellAvatarButtonTag = 5;


enum ActionTags {
    NotConfirmedActionTag = 0,
    ConfirmedActionTag = 1,
    NotFollowingActionTag = 2,
    FollowingActionTag = 3,
    
    EventMessageAlertTag = 4,
    CurrentUserConfirmedActionTag = 5,
    
};




#import "ActivityViewController.h"
#import "TTTTimeIntervalFormatter.h"

#import "CommentsViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"

#import "PAPProfileImageView.h"


static TTTTimeIntervalFormatter *timeFormatter;


@interface ActivityViewController ()

@property (nonatomic, strong) NSMutableArray *searchResultsMutableArray;


@end

@implementation ActivityViewController

@synthesize theTableView = _theTableView;
@synthesize topLbl;
@synthesize activityFromUserCommentsArray;


@synthesize searchResultsMutableArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    
    return self;
}

- (id)initWithArray:(NSArray *)array
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {

        if (array != nil)
        {
            self.activityFromUserCommentsArray = array;
        }
        else
        {
            [self queryForActivity];
        }
        
        
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
            timeFormatter.usesAbbreviatedCalendarUnits = YES;
        }
        
        
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width-0, self.view.frame.size.height-20);
        self.view.backgroundColor = [UIColor whiteColor];
        
        
        self.title = @"Activity"; //@"Messages"; 
        


        
        
    }
    return self;
    
}

-(void)loadView{
    [super loadView];
    
    
    self.searchResultsMutableArray = [NSMutableArray array];
    
    
    // seachBar
    
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [theSearchBar setBarStyle:UIBarStyleDefault];
    theSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    [theSearchBar setTintColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]]; // "Cancel" button color
    //[theSearchBar setBarTintColor:[UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f]];
    [theSearchBar setBarTintColor:[UIColor whiteColor]];
    theSearchBar.backgroundColor = [UIColor whiteColor];
    
    
    theSearchBar.delegate = self;
    [theSearchBar setShowsScopeBar:NO];
    [theSearchBar sizeToFit];
    [theSearchBar setPlaceholder:@"Search usernames"];
    [theSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    
    
    // tableView
    
    self.theTableView = [[UITableView alloc] init];
    self.theTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -20);
    self.theTableView.dataSource = self;
    self.theTableView.delegate = self;
    self.theTableView.showsVerticalScrollIndicator = YES;
    [self.theTableView setBackgroundView:nil];
    self.theTableView.backgroundColor = [UIColor whiteColor];
    [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    self.theTableView.tableHeaderView = theSearchBar; //this hides/shows searchBar
    
    
    // searchDisplayController
    
    theSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
    theSearchDisplayController.searchResultsDataSource = self;
    theSearchDisplayController.searchResultsDelegate = self;
    theSearchDisplayController.delegate = self;
    theSearchDisplayController.searchResultsTableView.autoresizesSubviews = NO;
    [theSearchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    // finally
    [self.view addSubview:self.theTableView];
    

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    theSearchDisplayController.active = NO;
        
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UITableViewDataSource


-(void)queryForActivity {
    
    PFQuery *messagesToUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [messagesToUserQuery whereKeyExists:@"content"];
    [messagesToUserQuery whereKey:@"type" equalTo:@"comment"];
    [messagesToUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    //[messagesToUserQuery whereKey:@"toUser" containedIn:activeFriendsArray2];
    
    PFQuery *messagesFromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [messagesFromUserQuery whereKeyExists:@"content"];
    [messagesFromUserQuery whereKey:@"type" equalTo:@"comment"];
    //[messagesFromUserQuery whereKey:@"fromUser" containedIn:activeFriendsArray2];
    [messagesFromUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:messagesToUserQuery, messagesFromUserQuery, nil]];
    
    [query includeKey:@"toUser"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"user"];
    
    NSDate *now = [NSDate date];
    unsigned int      intFlags   = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSCalendar       *calendar   = [NSCalendar currentCalendar]; //
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:intFlags fromDate:now];
    NSDate *startOfDay = [[NSDate alloc] init];
    startOfDay = [calendar dateFromComponents:components];
    
    [query whereKey:@"createdAt" greaterThanOrEqualTo:startOfDay];  //after startOfDay
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"objects count: %lu", (unsigned long)objects.count);
            
            NSMutableArray *ma1 = [NSMutableArray array];
            NSMutableArray *userArray = [NSMutableArray array];
            
            for (NSUInteger i = 0; i < objects.count; i++) {
                
                PFObject *comment = [objects objectAtIndex:i];
                
                // add first comment to mutable array
                
                // get "theUser" - to or from, whichever is NOT currentUser
                PFUser *theUser;
                
                PFUser *commentFromUser = [comment objectForKey:@"fromUser"];
                PFUser *commentToUser = [comment objectForKey:@"toUser"];
                if ([commentFromUser.objectId isEqualToString:[PFUser currentUser].objectId])
                {
                    theUser = commentToUser;
                }
                else
                {
                    theUser = commentFromUser;
                }
                
                
                if (ma1.count==0)
                {
                    [ma1 addObject:comment];
                    [userArray addObject:theUser.objectId];
                }
                else
                {
                    if ([userArray containsObject:theUser.objectId])
                    {
                        //do nothing
                    }
                    else
                    {
                        [ma1 addObject:comment];
                        [userArray addObject:theUser.objectId];
                    }
                }
            }
            
            //NSLog(@"ma1: %@", ma1);
            NSLog(@"userArray: %@", userArray);
            
            self.activityFromUserCommentsArray = [NSArray arrayWithArray:ma1];
            
            
            [self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; //NO
            
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.searchResultsMutableArray.count;
    }
    else
    {
        //return activeFriendsArray2.count;
        
        return self.activityFromUserCommentsArray.count;
    }
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 52.0f;
    }
    else
    {
        return 70.0f;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        PAPProfileImageView *imageView = [[PAPProfileImageView alloc] init];
        [imageView setTag:kPAWCellImageTag];
        [cell.contentView addSubview:imageView];

        UIButton *avatarBtn = [[UIButton alloc]init];
        [avatarBtn setTag:kPAWCellAvatarButtonTag];
        [cell.contentView addSubview:avatarBtn];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setTag:kPAWCellNameTag];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *textLabel = [[UILabel alloc]init];
        [textLabel setTag:kPAWCellTextLabelTag];
        [cell.contentView addSubview:textLabel];
        
        UIView *alphaView = [[UIView alloc]init];
        [alphaView setTag:kPAWCellAlphaViewTag];
        [cell.contentView addSubview:alphaView];
        
    }
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
        PFUser *user = [self.searchResultsMutableArray objectAtIndex:indexPath.row];
        NSString *firstName = [user objectForKey:@"displayName"];
        NSString *username = user.username;
        

        PAPProfileImageView *imageView = (PAPProfileImageView*)[cell.contentView viewWithTag:kPAWCellImageTag];
        //[imageView setImage:nil];
        PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
        if (profilePictureSmall)
        {
            [imageView setFile:profilePictureSmall];
        }
        [imageView setBackgroundColor:[UIColor blackColor]];
        imageView.userInteractionEnabled = NO; // YES;
        [imageView setFrame:CGRectMake(10,5,42,42)];
        imageView.layer.cornerRadius = 21.f;
        imageView.layer.masksToBounds = YES;
        
   
        // no avatar btn here, dif
        
        
        UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellNameTag];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.5];
        nameLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setFrame:CGRectMake(10+42+10,
                                       5,
                                       290-100,
                                       25)];
        
        [nameLabel setText:firstName];
        
        
        UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
        textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        textLabel.textColor = [UIColor colorWithWhite:0.60 alpha:1.0];
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        textLabel.backgroundColor = [UIColor clearColor];
        [textLabel setFrame:CGRectMake(10+42+10,
                                       30,
                                       290-10,
                                       15)];
        
        [textLabel setText:username];
        
        
        UIView *alphaView = (UIView*) [cell.contentView viewWithTag:kPAWCellAlphaViewTag];
        alphaView.frame = CGRectMake(10+42+10, 52-0.5, self.view.frame.size.width-10-42-10, 0.5);
        alphaView.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.0]; //this gray - 205/255
        //alphaView.hidden = YES;

        
    }
    else
    {
        PFObject *obj = [self.activityFromUserCommentsArray objectAtIndex:indexPath.row];
        PFUser *fromUser = [obj objectForKey:@"fromUser"];
        NSDate *theDate = obj.createdAt;
        
        PFUser *user;
        
        if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
        {
            user = [obj objectForKey:@"toUser"];
        }
        else
        {
            user = [obj objectForKey:@"fromUser"];
        }

        
        NSString *displayName = [user objectForKey:@"displayName"];
        
        PAPProfileImageView *imageView = (PAPProfileImageView*)[cell.contentView viewWithTag:kPAWCellImageTag];
        //[imageView setImage:nil];
        PFFile *profilePictureMedium = [user objectForKey:@"profilePictureMedium"];
        if (profilePictureMedium)
        {
            [imageView setFile:profilePictureMedium];
        }
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.userInteractionEnabled = NO; //YES;
        [imageView setFrame:CGRectMake(10,5,60,60)];
        //imageView.layer.cornerRadius = 30.f;
        //imageView.layer.masksToBounds = YES;
        
        
        
        
        UIButton *avatarBtn = (UIButton*)[cell.contentView viewWithTag:kPAWCellAvatarButtonTag];
        avatarBtn.backgroundColor = [UIColor clearColor];
        [avatarBtn addTarget:self action:@selector(animateToUserProfileView1:) forControlEvents:UIControlEventTouchUpInside];
        [avatarBtn setFrame:CGRectMake(imageView.frame.origin.x,
                                       imageView.frame.origin.y,
                                       imageView.frame.size.width,
                                       imageView.frame.size.height)];
        avatarBtn.layer.cornerRadius = imageView.frame.size.width/2;
        avatarBtn.layer.masksToBounds = YES;
        
        
        UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellNameTag];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.5];
        nameLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setFrame:CGRectMake(10+60+10,
                                       10,
                                       320-10-60-10 -35,
                                       25)];
        
        
        if (displayName)
        {
            [nameLabel setText:displayName];
        }
        else
        {
            [nameLabel setText:user.username];
        }
        
        
        UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
        textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        textLabel.textColor = [UIColor colorWithWhite:0.60 alpha:1.0];
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        textLabel.backgroundColor = [UIColor clearColor];
        [textLabel setFrame:CGRectMake(10+60+10,
                                       35,
                                       320-10-60-10 -35,
                                       24)];
        
        //[textLabel setText:username];
        
        
        
        
        NSString *content = [obj objectForKey:@"content"];
        
        NSString *textString;
        
        if (content)
        {
            textString = [NSString stringWithFormat:@"%@ - %@", [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:theDate], content];
        }
        else
        {
            textString = [NSString stringWithFormat:@""];

        }
        
        [textLabel setText:textString];
        
        
        
        UIView *alphaView = (UIView*) [cell.contentView viewWithTag:kPAWCellAlphaViewTag];
        alphaView.frame = CGRectMake(10+60+10, 70-0.5, self.view.frame.size.width-10-60-10, 0.5);
        alphaView.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.0]; //this gray - 205/255
        //alphaView.hidden = YES;
        
        
        
        cell.backgroundColor = [UIColor whiteColor];

        // ??
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
        
    }
    
    
	return cell;
    
}


//- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void) setEditing:(BOOL)editing
//           animated:(BOOL)animated{
//    
//    [super setEditing:editing
//             animated:animated];
//    
//    [self.theTableView setEditing:editing
//                        animated:animated];
//    
//    
//}
//
//- (void)  tableView:(UITableView *)tableView
// commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//  forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete){
//        
//        /* First remove this object from the source */
//        //[self.allRows removeObjectAtIndex:indexPath.row];
//                
//        NSMutableArray *ma = [self.activityFromUserCommentsArray mutableCopy];
//        [ma removeObjectAtIndex:indexPath.row];
//        
//        
//        /* Then remove the associated cell from the Table View */
//        [tableView deleteRowsAtIndexPaths:@[indexPath]
//                         withRowAnimation:UITableViewRowAnimationLeft];
//        
//    }
//    
//}





#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSString *savedSearchTerm;
    savedSearchTerm = searchString;
    
    [controller.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    
    [controller.searchResultsTableView setRowHeight:1400];
    //[controller.searchResultsTableView setRowHeight:52];
    
    [controller.searchResultsTableView setScrollEnabled:NO];
    
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchResultsMutableArray removeAllObjects];
    
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"username"];
    [query whereKey:@"username" containsString:searchBar.text];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    
    [query orderByAscending:@"username"];
    [query setLimit:20];
    
    NSArray *results  = [query findObjects];
    
    [self.searchResultsMutableArray addObjectsFromArray:results];
    
    if (self.searchResultsMutableArray != nil) {
        
        [self.searchDisplayController.searchResultsTableView setScrollEnabled:YES];
        
    }
    
    [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchResultsMutableArray removeAllObjects];
    
    [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [searchBar resignFirstResponder];
}





// DID SELECT

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        PFUser *user = [self.searchResultsMutableArray objectAtIndex:indexPath.row];
        if (user)
        {
            //[theSearchBar resignFirstResponder];
            
            
            
            //[self searchBarCancelButtonClicked:theSearchBar];
            
            ProfileViewController *pvc = [[ProfileViewController alloc]initWithUser:user];
            [self.navigationController pushViewController:pvc animated:YES];
            
        }
        
    }
    else
    {
        if (indexPath.row < self.activityFromUserCommentsArray.count)
        {
            PFObject *obj = [self.activityFromUserCommentsArray objectAtIndex:indexPath.row];
            PFUser *fromUser = [obj objectForKey:@"fromUser"];
            
            PFUser *user;
            
            if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
            {
                user = [obj objectForKey:@"toUser"];
            }
            else
            {
                user = [obj objectForKey:@"fromUser"];
            }
            
            if (user)
            {
                //NSLog(@"user hit");
                
                CommentsViewController *cvc = [[CommentsViewController alloc] initWithUserObject:user];
                [self.navigationController pushViewController:cvc animated:YES];
                
               
            }
           
            
        }
        
    }
    
}


-(void)animateToUserProfileView1:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.theTableView];
    NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        
        PFObject *obj = [self.activityFromUserCommentsArray objectAtIndex:indexPath.row];
        PFUser *fromUser = [obj objectForKey:@"fromUser"];
        
        PFUser *user;
        
        if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
        {
            user = [obj objectForKey:@"toUser"];
        }
        else
        {
            user = [obj objectForKey:@"fromUser"];
        }
        
        if (user)
        {
            //NSLog(@"animateToUserProfileView1 HIT %@", user);
            
            ProfileViewController *pvc = [[ProfileViewController alloc]initWithUser:user];
            [self.navigationController pushViewController:pvc animated:YES];
            
        }
        
        
        
        
    }
}


@end
