//
//  ProfileViewController.m
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//


enum Tags {
    UnfollowAlertTag = 0,
    Something1Tag = 1,
    Something2Tag = 2,
};


#import "ProfileViewController.h"

#import "PAPProfileImageView.h"

#import "PAPCache.h"
#import "PAPUtility.h"

@interface ProfileViewController ()

@property (nonatomic, assign) BOOL isCurrentlyFollowingUser;
@property (nonatomic, strong) UIButton *followUnfollowBtn;

@end

@implementation ProfileViewController

@synthesize theTableView = _theTableView;

@synthesize theUserObj;

@synthesize isCurrentlyFollowingUser;
@synthesize followUnfollowBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(id)initWithUser:(PFUser *)theUser {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.theUserObj = theUser;
        
        NSString *titleString = [[NSString stringWithFormat:@"%@", [self.theUserObj objectForKey:@"username"]] uppercaseString];
        //NSString *titleString = [self.theUserObj objectForKey:@"username"];
        
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width-0, self.view.frame.size.height-20);
        self.view.backgroundColor = [UIColor whiteColor];

        self.title = titleString;
        
        
        self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height ) style:UITableViewStyleGrouped];
        self.theTableView.dataSource = self;
        self.theTableView.delegate = self;
        self.theTableView.showsVerticalScrollIndicator = YES;
        [self.view addSubview:self.theTableView];
        [self.theTableView setBackgroundView:nil];
        [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        self.theTableView.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
        
        self.theTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 220+50+38)];
        
        self.theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
        
        
        
        
        PAPProfileImageView *avatarImgView = [[PAPProfileImageView alloc]init];
        [avatarImgView setBackgroundColor:[UIColor clearColor]];
        avatarImgView.userInteractionEnabled = YES;
        [self.theTableView.tableHeaderView addSubview:avatarImgView];
        avatarImgView.frame = CGRectMake(self.theTableView.frame.size.width/2-45, 25 +2, 90, 90);
        
        PFFile *profilePictureMedium = [self.theUserObj objectForKey:@"profilePictureMedium"];
        if (profilePictureMedium)
        {
            [avatarImgView setFile:profilePictureMedium]; 
        }
        
        
        UILabel *nameLbl = [[UILabel alloc]init];
        [nameLbl setFrame:CGRectMake(0, avatarImgView.frame.origin.y+avatarImgView.frame.size.height +10 -1, self.view.frame.size.width, 40)];
        nameLbl.backgroundColor = [UIColor clearColor];
        nameLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:24.5];
        [nameLbl setTextColor:[UIColor colorWithWhite:0.10 alpha:1.0]];
        [nameLbl setTextAlignment:NSTextAlignmentCenter];
        NSString *displayName = [self.theUserObj objectForKey:@"displayName"];
        [nameLbl setText:displayName];
        [self.theTableView.tableHeaderView addSubview:nameLbl];

        UILabel *locationLbl = [[UILabel alloc]init];
        [locationLbl setFrame:CGRectMake(0, nameLbl.frame.origin.y+nameLbl.frame.size.height +0  , self.view.frame.size.width, 20)];
        locationLbl.backgroundColor = [UIColor clearColor];
        locationLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5];
        [locationLbl setTextColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        [locationLbl setTextAlignment:NSTextAlignmentCenter];
        NSString *currentCityString = [[PFUser currentUser] objectForKey:@"currentCity"];
        [locationLbl setText:currentCityString];
        [self.theTableView.tableHeaderView addSubview:locationLbl];

        
        
        followUnfollowBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 50)];
        [followUnfollowBtn addTarget:self action:@selector(followBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        followUnfollowBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [followUnfollowBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.5f]];
        [self.theTableView.tableHeaderView addSubview:followUnfollowBtn];

        if ([[self.theUserObj objectId] isEqualToString:[[PFUser currentUser] objectId]])
        {
            followUnfollowBtn.backgroundColor = [UIColor whiteColor];
            [followUnfollowBtn setTitle:@"It's You!" forState:UIControlStateNormal];
            [followUnfollowBtn setTitleColor:[UIColor colorWithWhite:0.1 alpha:1.0] forState:UIControlStateNormal];
        }
        else
        {
            //query for following or not following...
            
            __block BOOL checkingSecondHit;

            PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
            [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.theUserObj];
            [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
            [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
            [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error && [error code] != kPFErrorCacheMiss) {
                    //error
                } else {
                    
                    if (!checkingSecondHit)
                    {
                        checkingSecondHit = YES;
                        
                        followUnfollowBtn.backgroundColor = [UIColor colorWithWhite:0.70 alpha:1.0];
                        [followUnfollowBtn setTitle:@"Loading..." forState:UIControlStateNormal];
                        [followUnfollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                    else
                    {
                        if (number == 0) {
                            // is NOT Following
                            self.isCurrentlyFollowingUser = NO;
                            //blue
                            followUnfollowBtn.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
                            [followUnfollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
                            [followUnfollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        } else {
                            // isFollowing
                            self.isCurrentlyFollowingUser = YES;
                            //green
                            followUnfollowBtn.backgroundColor = [UIColor colorWithRed:76.0f/255.0f green:232.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
                            [followUnfollowBtn setTitle:@"Following" forState:UIControlStateNormal];
                            [followUnfollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        }
                    }
                    
                    
                }
            }];
            
        }
        
        UIView *topLineView = [[UIView alloc]init];
        topLineView.frame = CGRectMake(0, 220, self.view.frame.size.width, 0.5);
        topLineView.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.0];
        [self.theTableView.tableHeaderView addSubview:topLineView];
        
        UIView *bottomLineView = [[UIView alloc]init];
        bottomLineView.frame = CGRectMake(0, 220+49.5, self.view.frame.size.width, 0.5);
        bottomLineView.backgroundColor = [UIColor colorWithWhite:0.804 alpha:1.0];
        [self.theTableView.tableHeaderView addSubview:bottomLineView];
        
        
    }
    
    
    return self;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section==0 )
    {
        return 0;
        
    }
    else
    {
        return 0;
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 0;
            break;
        case 2:
            return 0;
            break;
            
        default:
            return 0; //"default" for switch statements - just in case
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
    
}


#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;
    //[cell setBackgroundView:nil];
    

    
    if (indexPath.section == 0 && indexPath.row == 0 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Status"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(125, 0, 160, 50)];
        lbl2.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        [lbl2 setTextColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        [lbl2 setBackgroundColor:[UIColor clearColor]];
        [lbl2 setTextAlignment:NSTextAlignmentRight];
        [cell addSubview:lbl2];
        
        NSString *status = [self.theUserObj objectForKey:@"status"];
        //NSLog(@"status: %@", status);
        if ([status isEqualToString:@"OPEN"])
        {
            [lbl2 setText:@"Open"];
        }
        else
        {
            [lbl2 setText:@"Closed"]; //Not Available
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0 && indexPath.row == 1 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Places"]];  //@"Places"
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(125, 0, 160, 50)];
        lbl2.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        [lbl2 setTextColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        [lbl2 setBackgroundColor:[UIColor clearColor]];
        [lbl2 setTextAlignment:NSTextAlignmentRight];
        [cell addSubview:lbl2];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:1];
        [formatter setRoundingMode: NSNumberFormatterRoundUp];
        
        NSString *status = [[PFUser currentUser] objectForKey:@"status"];
        if ([status isEqualToString:@"OPEN"])
        {
            // add new time
            NSDate *now = [NSDate date];
            NSDate *originalStartTime = [[PFUser currentUser] objectForKey:@"startTime"];
            NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:originalStartTime];
            double between = distanceBetweenDates/3600; //secs in an hour
            NSNumber *incrementNum = [NSNumber numberWithFloat:between];
            
            NSNumber *previousTotalHours = [[PFUser currentUser] objectForKey:@"totalHours"];
            NSNumber *sum = [NSNumber numberWithFloat:([previousTotalHours floatValue] + [incrementNum floatValue])];
            
            NSString *numberString = [formatter stringFromNumber:sum];
            
            [lbl2 setText:numberString];
            
        }
        else
        {
            NSNumber *totalHours = [[PFUser currentUser] objectForKey:@"totalHours"];
            NSString *numberString = [formatter stringFromNumber:totalHours];
            if (totalHours)
            {
                [lbl2 setText:numberString];
            }
            else
            {
                [lbl2 setText:@""];
            }
            
        }
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    if (indexPath.section == 0 && indexPath.row == 2 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Following"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    if (indexPath.section == 0 && indexPath.row == 3 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Followers"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    

    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
    [self.theTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}




-(void)followBtnAction:(id)sender {
    
    if ([[self.theUserObj objectId] isEqualToString:[[PFUser currentUser] objectId]])
    {
        // do nothing
    }
    else
    {
        if (self.isCurrentlyFollowingUser)
        {
            //unfollow, alert first
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unfollow", nil];
            alert.tag = UnfollowAlertTag;
            [alert show];
        }
        else
        {
            //follow
            //green
            followUnfollowBtn.backgroundColor = [UIColor colorWithRed:76.0f/255.0f green:232.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
            [followUnfollowBtn setTitle:@"Following" forState:UIControlStateNormal];
            [followUnfollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            self.isCurrentlyFollowingUser = YES;
            [[PAPCache sharedCache] setFollowStatus:YES user:self.theUserObj];
            //I Put this here
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            
            [PAPUtility followUserInBackground:self.theUserObj block:^(BOOL succeeded, NSError *error) {
                if (error) {
                    self.isCurrentlyFollowingUser = YES;
                }
            }];
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == UnfollowAlertTag)
    {
        if (buttonIndex == 0)
        {
            //do nothing
        }
        else
        {
            //unfollow
            //blue
            followUnfollowBtn.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            [followUnfollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
            [followUnfollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            self.isCurrentlyFollowingUser = NO;
            [[PAPCache sharedCache] setFollowStatus:NO user:self.theUserObj];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            
            [PAPUtility unfollowUserEventually:self.theUserObj];
            
        }
    }
    
}

@end
