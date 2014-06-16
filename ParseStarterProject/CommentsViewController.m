//
//  CommentsViewController.m
//  Ohours
//
//  Created by Clay Zug on 3/17/14.
//
//


static CGFloat const kPAWWallPostTableViewFontSize = 15.f; // 18.f;
static CGFloat const kPAWWallPostTableViewCellWidth = 245.f; // 230 // subject to change.

static CGFloat const kPAWWallPostTableViewDateFontSize = 14.f;

// Cell dimension and positioning constants
static CGFloat const kPAWCellPaddingTop = 5.f;
//static CGFloat const kPAWCellPaddingBottom = 1.f;
static CGFloat const kPAWCellPaddingSides = 0.f;
static CGFloat const kPAWCellTextPaddingTop = 5.f;
//static CGFloat const kPAWCellTextPaddingBottom = 5.f;
static CGFloat const kPAWCellTextPaddingSides = 5.f;

static CGFloat const kPAWCellUsernameHeight = 15.f;
static CGFloat const kPAWCellBkgdHeight = 32.f;
static CGFloat const kPAWCellBkgdOffset = kPAWCellBkgdHeight - kPAWCellUsernameHeight;

static NSInteger kPAWCellAvatarTag = 1;
static NSInteger kPAWCellNameTag = 2;
static NSInteger kPAWCellDateTag = 3;
static NSInteger kPAWCellTextLabelTag = 4;

static NSInteger kPAWCellAvatarButtonTag = 5;



enum AlertTags {
    LogoutAlertTag = 0,
    SaveToCalTag = 1,
    SaveToRemTag = 2,
    
    OpenWebLinkTag = 3,
};


#import "PAPCache.h"
#import "PAPConstants.h"


#import "CommentsViewController.h"
#import "TTTTimeIntervalFormatter.h"

#import "ProfileViewController.h"

#import "PAPProfileImageView.h"

static TTTTimeIntervalFormatter *timeFormatter;


@interface CommentsViewController ()

@end

@implementation CommentsViewController

@synthesize theTableView = _theTableView;
@synthesize topLbl, backBtn;

@synthesize theUserObj;

@synthesize commentsArray;
@synthesize blankTimelineView;
@synthesize shouldAnimateOnReload;

@synthesize containerView, theTextView, sendBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithUserObject:(PFUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
            timeFormatter.usesAbbreviatedCalendarUnits = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self.theTextView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:self.theTextView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didHideKeyboard:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:self.theTextView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:self.theTextView];
        
        
        
        
        self.theUserObj = user;

        NSString *titleString = [[NSString stringWithFormat:@"%@", self.theUserObj.username]uppercaseString];

        
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width-0, self.view.frame.size.height-20);
        self.view.backgroundColor = [UIColor whiteColor];
        

        self.title = titleString; // @"Ohours";
        
        
        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [infoBtn addTarget:self action:@selector(infoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
        self.navigationItem.rightBarButtonItem = infoBarBtn;
        
        
        
        self.theTableView = [[UITableView alloc] init];
        self.theTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -48+1);
        self.theTableView.dataSource = self;
        self.theTableView.delegate = self;
        self.theTableView.showsVerticalScrollIndicator = YES;
        [self.view addSubview:self.theTableView];
        [self.theTableView setBackgroundView:nil];
        self.theTableView.backgroundColor = [UIColor whiteColor];
        
        self.theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.0f)]; //5.0f
        
        self.blankTimelineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -48+1 -44)];
        
        UILabel *emptyLbl = [[UILabel alloc]init];
        [emptyLbl setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        [emptyLbl setBackgroundColor:[UIColor clearColor]];
        [emptyLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5]];
        [emptyLbl setTextColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
        [emptyLbl setTextAlignment:NSTextAlignmentCenter];
        [emptyLbl setText:@"No messages today.\nSend a message to start a conversation."];
        [emptyLbl setNumberOfLines:2];
        [self.blankTimelineView addSubview:emptyLbl];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:tap];
        
        
        
        ////////////////////////////////
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -48 -0, self.view.frame.size.width, 48)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.alpha = 1.0f;
        
        ///// ADDING TextView Stuff to commentsView
        
        //when centering, move textView ONE PIXEL TO LEFT to center the curser
        theTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(11, 7.0f, 245 +5, 48.0f)];
        theTextView.delegate = self;
        theTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);  //top, left, bottom, right
        theTextView.minNumberOfLines = 1;
        theTextView.maxNumberOfLines = 3;  //6;
        // you can also set the maximum height in points with maxHeight
        //theTextView.maxHeight = 200.0f;
        //theTextView.minHeight = 50.0f;
        //theTextView.returnKeyType = UIReturnKeySend;
        theTextView.keyboardType = UIKeyboardTypeTwitter;
        theTextView.font = [UIFont systemFontOfSize:15];
        theTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);  //
        theTextView.backgroundColor = [UIColor clearColor]; //clearColor
        theTextView.placeholder = @"Write a message"; //Write a comment
        theTextView.textColor = [UIColor blackColor];
        
        theTextView.enablesReturnKeyAutomatically = YES; //this disbles return key initially
        theTextView.alpha = 1.0f;
        [theTextView setTextAlignment:NSTextAlignmentLeft];
        
        [self.view addSubview:containerView];
        // view hierachy
        [containerView addSubview:theTextView];
        
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width -0, 0.5)];
        line2.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:199.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        [containerView addSubview:line2];
        
        
        sendBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(self.view.frame.size.width -48 -13, 0, 48, 48);
        sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        sendBtn.backgroundColor = [UIColor clearColor];
        [sendBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.5f]];
        [sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn setTitle:@"Send" forState:UIControlStateDisabled];
        [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor colorWithWhite:0.55 alpha:1.0] forState:UIControlStateDisabled];
        [sendBtn setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:52.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [containerView addSubview:sendBtn];
        sendBtn.enabled = NO;
        sendBtn.alpha = 0.4;
        
        
        
        [self queryForTable];
        
        
        
    }
    
    return self;
}



-(void)loadView
{
    [super loadView];
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource

- (void)queryForTable
{
    PFQuery *messagesToUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [messagesToUserQuery whereKeyExists:@"content"];
    [messagesToUserQuery whereKey:@"type" equalTo:@"comment"];
    [messagesToUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [messagesToUserQuery whereKey:@"toUser" equalTo:self.theUserObj];
    
    PFQuery *messagesFromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [messagesFromUserQuery whereKeyExists:@"content"];
    [messagesFromUserQuery whereKey:@"type" equalTo:@"comment"];
    [messagesFromUserQuery whereKey:@"fromUser" equalTo:self.theUserObj];
    [messagesFromUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:messagesToUserQuery, messagesFromUserQuery, nil]];
    
    [query includeKey:@"toUser"]; //
    [query includeKey:@"fromUser"]; //the commenter
    [query orderByAscending:@"createdAt"];
    
    //NSDate *startTime = [self.theUserObj objectForKey:@"startTime"];
    
    NSDate *now = [NSDate date];
    unsigned int      intFlags   = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSCalendar       *calendar   = [NSCalendar currentCalendar]; //
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:intFlags fromDate:now];
    NSDate *startOfDay = [[NSDate alloc] init];
    startOfDay = [calendar dateFromComponents:components];
    
    [query whereKey:@"createdAt" greaterThanOrEqualTo:startOfDay];
    
    
    if ([self.commentsArray count] == 0)
    {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
	}
    else
    {
        [query setCachePolicy:kPFCachePolicyNetworkOnly];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             
             //Save results and update the table
             self.commentsArray = objects;
             
             if (objects.count == 0 )
             {
                 self.theTableView.scrollEnabled = YES;
                 
                 if (!self.blankTimelineView.superview) {
                     self.theTableView.tableHeaderView = self.blankTimelineView;
                     self.blankTimelineView.alpha = 1.0f;
                 }
                 
                 [self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; //NO
                 
                 //[theTextView becomeFirstResponder];
                 //[self slideViewIntoPlace];
                 
                 
             }
             else
             {
                 self.theTableView.tableHeaderView = nil;
                 
                 
                 if (self.shouldAnimateOnReload)
                 {
                     self.shouldAnimateOnReload = NO;
                     
                     [self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; //NO
                     
                     
                     //CGRect containerFrame = containerView.frame;
                     CGRect tableFrame = self.theTableView.frame;
                     CGPoint tableContentOffset = self.theTableView.contentOffset;
                     CGSize tableContentSize = self.theTableView.contentSize;

                     
                     
                     tableContentOffset.y = tableContentSize.height -  tableFrame.size.height ;
                     
                     [UIView beginAnimations:nil context:NULL];
                     [UIView setAnimationBeginsFromCurrentState:YES];
                     [UIView setAnimationDuration:0.25];
                     [UIView setAnimationCurve:0.25];
                     
                     if (tableContentSize.height > tableFrame.size.height-48 )  //(tableContentSize.height > tableFrame.size.height -50)
                     {
                         self.theTableView.contentOffset = tableContentOffset;
                     }
                     
                     [UIView commitAnimations];
                     
                     
                     
                     
                 }
                 else
                 {
                     
                     
                     
                     [self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; //NO
                     
                     //[theTextView becomeFirstResponder];
                     //[self slideViewIntoPlace];
                     
                     
                 }
                 
                 
             }
             
             
         }
         else
         {
             //error
         }
     }];
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.commentsArray.count;
}






- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.commentsArray count]) {
		return [theTableView rowHeight];
	}
    
	PFObject *object = [self.commentsArray objectAtIndex:indexPath.row];
    PFUser *user = [object objectForKey:@"fromUser"];
    NSString *username;  // = [user objectForKey:@"firstName"];
    //    if ([user.email isEqualToString:[PFUser currentUser].email])
    //    {
    //        username = @"Me";
    //    }
    //    else
    //    {
    //        username = user.username; // = [user objectForKey:@"firstName"];
    //    }
    
    username = user.username; // = [user objectForKey:@"firstName"];
    
    
   
    NSString *text = [object objectForKey:@"content"];
 
    
    
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kPAWWallPostTableViewFontSize]};
    NSDictionary *nameAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:kPAWWallPostTableViewDateFontSize]};
    
    CGRect textSize;
    CGRect nameSize = [username boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:nameAttributes
                                             context:nil];
    
    textSize = [text boundingRectWithSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:textAttributes
                                  context:nil];
    
    
	
    CGFloat rowHeight = kPAWCellPaddingTop + CGRectGetHeight(nameSize) + CGRectGetHeight(textSize) + kPAWCellBkgdOffset +6; // (+6 for design, +3 to text.origin.y
    return rowHeight;
    
    
    
    
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        PAPProfileImageView *avatarImageView = [[PAPProfileImageView alloc] init];
        [avatarImageView setTag:kPAWCellAvatarTag];
        [cell.contentView addSubview:avatarImageView];
        
        UIButton *nameBtn = [[UIButton alloc] init];
        [nameBtn setTag:kPAWCellNameTag];
        [cell.contentView addSubview:nameBtn];
        
        UILabel *dateLbl = [[UILabel alloc]init];
        [dateLbl setTag:kPAWCellDateTag];
        [cell.contentView addSubview:dateLbl];
        
        UILabel *textLabel = [[UILabel alloc]init];
        [textLabel setTag:kPAWCellTextLabelTag];
        [cell.contentView addSubview:textLabel];
        
        UIButton *avatarBtn = [[UIButton alloc]init];
        [avatarBtn setTag:kPAWCellAvatarButtonTag];
        [cell.contentView addSubview:avatarBtn];
        
        
        
    }
    
    PFObject *object = [self.commentsArray objectAtIndex:indexPath.row];
    PFUser *user = [object objectForKey:@"fromUser"];
    
    NSDate *theDate = object.createdAt;
    
    NSString *username;  // = [user objectForKey:@"firstName"];
    
    username = user.username; // = [user objectForKey:@"firstName"];
    
    
    NSString *text = [object objectForKey:@"content"];
  
    
    
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kPAWWallPostTableViewFontSize]};
    NSDictionary *nameAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:kPAWWallPostTableViewDateFontSize]};
    
    CGRect textSize;
    CGRect nameSize = [username boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:nameAttributes
                                             context:nil];
    
    textSize = [text boundingRectWithSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:textAttributes
                                  context:nil];
    
    
    
    
    
    PAPProfileImageView *avatarImageView = (PAPProfileImageView*)[cell.contentView viewWithTag:kPAWCellAvatarTag];
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    if (profilePictureSmall)
    {
        [avatarImageView setFile:profilePictureSmall];
    }
    [avatarImageView setBackgroundColor:[UIColor clearColor]];
    avatarImageView.userInteractionEnabled = NO; //YES
    [avatarImageView setFrame:CGRectMake(9,kPAWCellPaddingTop+kPAWCellTextPaddingTop,38,38)];
    
    
    UIButton *avaterBtn = (UIButton*)[cell.contentView viewWithTag:kPAWCellAvatarButtonTag];
	avaterBtn.backgroundColor = [UIColor clearColor];
    [avaterBtn addTarget:self action:@selector(animateToUserProfileView:) forControlEvents:UIControlEventTouchUpInside];
    [avaterBtn setFrame:CGRectMake(9,kPAWCellPaddingTop+kPAWCellTextPaddingTop,38,38)];

    
    
    
    UIButton *nameBtn = (UIButton*) [cell.contentView viewWithTag:kPAWCellNameTag];
    [nameBtn setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides +52 -2,
                                 kPAWCellPaddingTop+kPAWCellTextPaddingTop,
                                 nameSize.size.width,  //200
                                 CGRectGetHeight(nameSize))];
    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    nameBtn.backgroundColor = [UIColor clearColor];
    [nameBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kPAWWallPostTableViewDateFontSize]];
    [nameBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [nameBtn setTitle:username forState:UIControlStateDisabled];
    [nameBtn setTitle:username forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor colorWithWhite:0.10 alpha:1.0] forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor colorWithWhite:0.10 alpha:1.0] forState:UIControlStateHighlighted];
    
    
    
    UILabel *dateLbl = (UILabel*)[cell.contentView viewWithTag:kPAWCellDateTag];
    [dateLbl setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:theDate]];
    dateLbl.font = [UIFont boldSystemFontOfSize:13];
    dateLbl.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    dateLbl.backgroundColor = [UIColor clearColor];
    [dateLbl setTextAlignment:NSTextAlignmentRight];
    [dateLbl setFrame:CGRectMake(self.view.frame.size.width -60 -14 ,
                                 kPAWCellPaddingTop+kPAWCellTextPaddingTop +0.5f,
                                 60,
                                 CGRectGetHeight(nameSize))];
    
    
    
    
	// Configure the cell content
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    textLabel.textColor = [UIColor colorWithWhite:0.10 alpha:1.0];
    
    [textLabel setText:text];
    
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kPAWWallPostTableViewFontSize];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    textLabel.backgroundColor = [UIColor clearColor];
    
	[textLabel setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides +52 -1,
                                   kPAWCellPaddingTop+kPAWCellTextPaddingTop +CGRectGetHeight(nameSize) +2,
                                   CGRectGetWidth(textSize),
                                   CGRectGetHeight(textSize) +5)];
    
    
    
    
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
    
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];// [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:255.0f/255.0f];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //[theTextView resignFirstResponder];
    
    
    
}


-(void)animateToUserProfileView:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.theTableView];
    NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        PFObject *object = [self.commentsArray objectAtIndex:indexPath.row];
        PFUser *user = [object objectForKey:@"fromUser"];
        
        if (user) {
            
            [theTextView resignFirstResponder];
            
            
            //NSLog(@"animateToUserProfileView HIT %@", user);
            
            ProfileViewController *pvc = [[ProfileViewController alloc]initWithUser:user];
            [self.navigationController pushViewController:pvc animated:YES];
            
        }
        
        
        
        
    }
    
    
    
}




- (void)sendBtnAction
{
    NSString *trimmedComment = [theTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedComment rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].length > 0 && [PFUser currentUser]) {
        
        PFObject *comment = [PFObject objectWithClassName:@"Activity"];
        [comment setValue:@"comment" forKey:@"type"];
        [comment setValue:self.theUserObj forKey:@"user"];
        [comment setValue:trimmedComment forKey:@"content"];
        [comment setValue:[PFUser currentUser] forKey:@"fromUser"];
        [comment setValue:self.theUserObj forKey:@"toUser"];
        
        
        // IF A PUBLIC EVENT, check for mentions
        
        //check for at mention
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
        NSArray *matches = [regex matchesInString:trimmedComment options:0 range:NSMakeRange(0, trimmedComment.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:1]; //1   //could be matches.count to query multiple times
            NSString* word = [trimmedComment substringWithRange:wordRange];
            NSLog(@"Found mention %@", word);
            if (word)
            {
                PFQuery *query = [PFUser query];
                [query whereKey:@"username" equalTo:word];
                NSArray *results  = [query findObjects];
                
                for (PFUser *aUser in results)
                {
                    if ([[aUser objectId] isEqualToString:[[PFUser currentUser] objectId]])
                    {
                        
                    }
                    else
                    {
                        [comment addUniqueObject:aUser forKey:@"mentions"];
                    }
                }
            }
            else
            {
                // do nothing
            }
            
        }
        
        
        
        
        
        // not sure what ACL to use ???
        
        PFACL *publicACL = [PFACL ACL];
        [publicACL setPublicReadAccess:YES];
        [publicACL setPublicWriteAccess:NO];
        [comment setACL:publicACL];
        
        
        
//        // Show activityView
//        activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(6, 1, 48, 48)];
//        UILabel *label = activityView.label;
//        label.text = @"";
//        label.font = [UIFont boldSystemFontOfSize:18.5f];
//        [activityView.activityIndicator startAnimating];
//        [activityView layoutSubviews];
//        [sendBtn addSubview:activityView];
        
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:[NSDictionary dictionaryWithObject:comment forKey:@"comment"] repeats:NO];
        
        
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [timer1 invalidate];
            
            // Tear down the activity view in all cases, succeed or error
            //[activityView.activityIndicator stopAnimating];
            //[activityView removeFromSuperview];
            
            
            if (succeeded)
            {
                // fetch if needed... ?
                
                if (self.theUserObj != [PFUser currentUser])
                {
                    NSString *privateChannelName = [self.theUserObj objectForKey:kPAPUserPrivateChannelKey];
                    
                    
                    if (privateChannelName && privateChannelName.length != 0)
                    {
                        NSString *string = [NSString stringWithFormat:@"%@ sent you a comment", [PFUser currentUser].username];
                        
                        PFPush *push = [[PFPush alloc] init];
                        [push setChannel:privateChannelName];
                        [push setMessage:string];
                        [push sendPushInBackground];
                    }
                }
                
                
                
                self.shouldAnimateOnReload = YES;
                
                [self queryForTable];
                
                
                [theTextView setText:@""];
                
                [UIView animateWithDuration:0.200f animations:^{
                    sendBtn.alpha = 0.4f;
                } completion:^(BOOL finished){
                    sendBtn.enabled = NO;
                }];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.theUserObj userInfo:@{@"comments": @(self.commentsArray.count + 1)}];
                
            }
            
            
            
            
        }];
        
    }
    else
    {
        
    }
    
    
    
    
    
    
    
}




- (void)handleCommentTimeout:(NSTimer *)aTimer
{
//    [activityView.activityIndicator stopAnimating];
//    [activityView removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"Your comment will be posted next time there is an Internet connection."  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alert show];
}






/////////// KEYBOARD STUFF

-(void)dismissKeyboard {

    [theTextView resignFirstResponder];

}


- (void)viewDidUnload {
    [super viewDidUnload];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:self.theTextView];
    
}

-  (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self.theTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:self.theTextView];
}

#pragma mark - Keyboard Actions

- (void)willShowKeyboard:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    //NSLog(@"duration: %@, curve: %@", duration, curve);
    
    
    CGRect containerViewFrame = containerView.frame;
    containerViewFrame.origin.y = containerView.frame.origin.y+10 - keyboardBounds.size.height;
    
    CGRect tableViewFrame = self.theTableView.frame;
    tableViewFrame.size.height = self.theTableView.frame.size.height+10 - keyboardBounds.size.height;
    
   
    
    
    

    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        
        containerView.frame = containerViewFrame;
        self.theTableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished){
        if (finished)
        {
            if (commentsArray.count == 0)
            {
                CGSize tableViewContentFrame = self.theTableView.contentSize;
                tableViewContentFrame.height = self.theTableView.frame.size.height - keyboardBounds.size.height;
                self.theTableView.contentSize = tableViewContentFrame;
            }
            
           
            
            
        }
        
    }];
    
    
    
}

- (void)didShowKeyboard:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];
    
    
    
    
}

- (void)willHideKeyboard:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    //NSLog(@"duration: %@, curve: %@", duration, curve);
    
    
    CGRect containerViewFrame = containerView.frame;
    containerViewFrame.origin.y = containerView.frame.origin.y-10 + keyboardBounds.size.height;
    
    CGRect tableViewFrame = self.theTableView.frame;
    tableViewFrame.size.height = self.theTableView.frame.size.height-10 + keyboardBounds.size.height;
    
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        
        containerView.frame = containerViewFrame;
        self.theTableView.frame = tableViewFrame;
        
    } completion:^(BOOL finished){
        if (finished)
        {
           
            
        }
        
    }];
    
    
}

- (void)didHideKeyboard:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];

    
    
}




- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect containerFrame = containerView.frame;
    containerFrame.size.height -= diff;
    containerFrame.origin.y += diff;
	containerView.frame = containerFrame;
    
    
    CGRect tableFrame = self.theTableView.frame;
    tableFrame.size.height += diff;
    self.theTableView.frame = tableFrame;
    
    
    if (commentsArray.count>0)
    {
        CGPoint tableContentOffset = self.theTableView.contentOffset;
        CGSize tableContentSize = self.theTableView.contentSize;
        tableContentOffset.y = tableContentSize.height -  tableFrame.size.height ; //
        
        if (tableContentSize.height > tableFrame.size.height)  //this is the "small" tableFrame size with
        {
            self.theTableView.contentOffset = tableContentOffset;
        }
    }
    else
    {
        CGRect blankFrame = blankTimelineView.frame;
        blankFrame.size.height = self.theTableView.frame.size.height;
        blankTimelineView.frame = blankFrame;
    }
    
    
    
        
    
    
}


- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([growingTextView.text isEqual:@""]) {
        if ([text  isEqual: @" "]) {
            return NO;
        }
    }
    

    
    NSUInteger newLength = [growingTextView.text length] + [text length] - range.length;
    
    if (newLength == 0) {
        
        [UIView animateWithDuration:0.200f animations:^{
            sendBtn.alpha = 0.4f;
        } completion:^(BOOL finished){
            sendBtn.enabled = NO;
        }];
        
        
    } else {
        
        sendBtn.enabled = YES;
        
        [UIView animateWithDuration:0.200f animations:^{
            sendBtn.alpha = 1.0f;
        } completion:^(BOOL finished){
            
        }];
        
    }
    
    
    if ([text isEqualToString:@"\n"])
    {
        return NO;
	}
    
    
    return (newLength > 220) ? NO : YES;
	//return YES;
}



-(void)infoBtnAction:(id)sender
{
    if (self.theUserObj)
    {
        [theTextView resignFirstResponder];
        
        ProfileViewController *pvc = [[ProfileViewController alloc]initWithUser:self.theUserObj];
        [self.navigationController pushViewController:pvc animated:YES];
        
    }
}



@end
