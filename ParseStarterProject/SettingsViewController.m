//
//  SettingsViewController.m
//  Ohours
//
//  Created by Clay Zug on 3/18/14.
//
//

#import "SettingsViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "PAPConstants.h"

#import "PAPProfileImageView.h"

#import "ParseStarterProjectAppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize theTableView = _theTableView;
@synthesize shouldReloadOnAppear;

@synthesize availableToggleSwitch, availableLabel;

enum ActionSheetTags {
    SettingsActionSheetTag = 0,
    CameraActionSheetTag = 1
};


enum AlertTags {
    LogoutAlertTag = 0,
    OpenSafariTag = 1
};


- (void)dealloc {
    

    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width-0, self.view.frame.size.height-20)];
        self.view.backgroundColor = [UIColor whiteColor];
        
    
        self.title = @"Settings";
        
        
        self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height ) style:UITableViewStyleGrouped];
        self.theTableView.dataSource = self;
        self.theTableView.delegate = self;
        [self.theTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        self.theTableView.showsVerticalScrollIndicator = YES;
        [self.view addSubview:self.theTableView];
        [self.theTableView setBackgroundView:nil];
        self.theTableView.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
        
        //[self.theTableView setContentInset:UIEdgeInsetsMake(44,0,0,0)];
        
        self.theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
        
        
        
       
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0 )
    {
        return nil;
    }
    if (section == 1 )
    {
        return nil; // @"ACCOUNT";
    }
    if (section == 2 )
    {
        return nil;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    
    if (section==0 )
    {
        return 0;
        
    } else if (section==1)
    {
        return 0; //40;
    }
    else
    {
        return 0;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 10, self.view.frame.size.width, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
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
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 75, 50)];
        [lbl setText:[NSString stringWithFormat:@"Status: "]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        
        self.availableLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 150, 50)];
        self.availableLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        [self.availableLabel setTextColor:[UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        [self.availableLabel setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:self.availableLabel];
        
        
        self.availableToggleSwitch =[[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-65, 10, 20, 20)];
        
        NSString *status = [[PFUser currentUser] objectForKey:@"status"];
        NSLog(@"status: %@", status);
        if ([status isEqualToString:@"OPEN"])
        {
            [self.availableLabel setText:@"Open"];
            [self.availableToggleSwitch  setOn:YES];
        }
        else
        {
            [self.availableLabel setText:@"Closed"]; //Not Available
            [self.availableToggleSwitch  setOn:NO];
        }
        
        
//        if (self) //[[DataManager shareInstance] availableToggleOn]
//        {
//            [self.availableToggleSwitch  setOn:YES];
//            self.availableLabel.text = @"Open";
//            if (![[[PFUser currentUser] objectForKey:@"available"] isEqualToString:@"yes"])
//            {
//                PFUser *newMe = [PFUser currentUser];
//                [newMe setValue:@"yes" forKey:@"available"];
//                [newMe saveInBackground];
//            }
//        }
//        else
//        {
//            self.availableLabel.text = @"Closed";
//            if (![[[PFUser currentUser] objectForKey:@"available"] isEqualToString:@"no"])
//            {
//                PFUser *newMe = [PFUser currentUser];
//                [newMe setValue:@"no" forKey:@"available"];
//                [newMe saveInBackground];
//            }
//        }
        
        [self.availableToggleSwitch addTarget:self action:@selector(switchmethod) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:self.availableToggleSwitch];
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 1 && indexPath.row == 0 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Profile"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    if (indexPath.section == 1 && indexPath.row == 1 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Card"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];
        
        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    
    if (indexPath.section == 2 && indexPath.row == 0 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Find People to Follow"]];
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
    
    if (indexPath.section == 2 && indexPath.row == 1 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Tell a Friend"]];
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
    if (indexPath.section == 2 && indexPath.row == 2 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Send Feedback"]];
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
    
    
    if (indexPath.section == 3 && indexPath.row == 0 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
        [lbl setText:[NSString stringWithFormat:@"Log Out"]];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.5f];
        [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lbl];

        
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    	cell.selectedBackgroundView = v;
    }
    
    
    
    return cell;
    
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
    [self.theTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 2 && indexPath.row == 0 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
        alert.tag = LogoutAlertTag;
        [alert show];
    }
    
}


- (void)showShareSheet
{
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:1];
    
    NSString *string = [NSString stringWithFormat:@"Add me on Ohours! (Username: %@)  http://www.theOhoursApp.com/", [PFUser currentUser].username];
    
    [activityItems addObject:string];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == LogoutAlertTag)
    {
        if (buttonIndex == 0)
        {
            //do nothing
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            [(ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            
        }
    }
}



-(void)switchmethod
{
//    [DataManager shareInstance].availableToggleOn = availableToggleSwitch.on;
//    
//    if ([[DataManager shareInstance] availableToggleOn])
//    {
//        if (self.pendingOrActiveStatus)
//        {
//            [self turnSwitchOff];
//        }
//        else
//        {
//            [self turnSwitchOn];
////            
//        }
//    }
//    else
//    {
//        [self turnSwitchOff];
//        
//        [self presentNotAvailableStuff];
//    }
    
}

//-(void)turnSwitchOn
//{
//    [DataManager shareInstance].availableToggleOn = YES;
//    [self.availableToggleSwitch setOn:YES animated:YES];
//    self.availableSwitchLabel.text=@"ON";
//    self.availableLabel.text = @"Available: \"YES\"";
//    PFUser *newMe = [PFUser currentUser];
//    if ([[newMe objectForKey:@"available"] isEqualToString:@"no"])
//    {
//        //this may cause a problem... most likely need to reload/save anyway
//    }
//    [newMe setValue:@"yes" forKey:@"available"];
//    [newMe saveInBackground];
//    
//}
//
//
//-(void)turnSwitchOff
//{
//    [DataManager shareInstance].availableToggleOn = NO;
//    [self.availableToggleSwitch setOn:NO animated:YES];
//    self.availableSwitchLabel.text=@"OFF";
//    self.availableLabel.text = @"Available: \"NO\"";
//    PFUser *newMe = [PFUser currentUser];
//    if ([[newMe objectForKey:@"available"] isEqualToString:@"yes"])
//    {
//        //
//    }
//    [newMe setValue:@"no" forKey:@"available"];
//    [newMe saveInBackground];
//    
//}






@end
