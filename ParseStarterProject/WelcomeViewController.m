//
//  WelcomeViewController.m
//  Ohours
//
//  Created by Clay Zug on 3/20/14.
//
//

#import "WelcomeViewController.h"

#import "ParseStarterProjectAppDelegate.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "MobileCoreServices/MobileCoreServices.h"
#import "UIImage+ResizeAdditions.h"

#import "PAPUtility.h"

#import <QuartzCore/QuartzCore.h>


@interface WelcomeViewController ()

@property (nonatomic, strong) ACAccountStore *TWaccountStore;

@end

@implementation WelcomeViewController

@synthesize TWaccountStore;

@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

@synthesize passedTwitterIdString, passedTwitterSceenName, passedTwitterDisplayName, passedTwitterProfileImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.TWaccountStore = [[ACAccountStore alloc]init];
        
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;

        
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(25, self.view.frame.size.height-70-25, self.view.frame.size.width-50, 70)];
        btn.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        [btn addTarget:self action:@selector(getTwitterAuth) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.5f]];
        [btn setTitle:@"Sign in with Twitter" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];

    
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

-(void)getTwitterAuth
{
    ACAccountType *twitterType = [self.TWaccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if ([self.TWaccountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)])
    {
        [self.TWaccountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                //
                [self getUsersTwitterInformation];
            }
            else
            {
                // error?
                [self refreshTwitterAccounts];
            }
        }];
    }
    else
    {
        [self.TWaccountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
            if (granted)
            {
                //
                [self getUsersTwitterInformation];
            }
            else
            {
                // error?
                [self refreshTwitterAccounts];
            }
        }];
    }
    
}


#pragma mark - Twitter methods

- (void)refreshTwitterAccounts
{
    //  Get access to the user's Twitter account(s)
    [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                
                //_reverseAuthBtn.enabled = YES;
                
                [self getUsersTwitterInformation];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ohours Needs Access" message:@"Go to Settings.app -> Twitter -> Scroll down and switch Ohours to ON" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        });
    }];
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    
    ACAccountType *twitterType = [self.TWaccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (!granted)
        {
            
        }
        else
        {
            //do not need array of account... just using first available account
            //self.accounts = [self.accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    [self.TWaccountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    
}


-(void)getUsersTwitterInformation
{
    NSLog(@"getUsersTwitterInformation HIT");
    
    if (self.TWaccountStore)
    {
        ACAccountType *accountTypeTw = [self.TWaccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        NSArray *accountsArray = [self.TWaccountStore accountsWithAccountType:accountTypeTw];
        
        if ([accountsArray count] > 0)
        {
            ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
            
            //theUserName = twitterAccount.username;
            
            NSLog(@"twitterAccount: %@", twitterAccount);
            
            
            
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
            
            NSDictionary *params;
            
            params = @{@"screen_name" : twitterAccount.username,
                       
                       };
            
            SLRequest* twitterRequest =
            [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
            
            [SLRequest requestForServiceType:SLServiceTypeTwitter
                               requestMethod:SLRequestMethodGET
                                         URL:url
                                  parameters:params];
            [twitterRequest setAccount:twitterAccount];
            
            
            // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
            

            
            [twitterRequest performRequestWithHandler:
             ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 if (responseData) {
                     NSDictionary *user =
                     [NSJSONSerialization JSONObjectWithData:responseData
                                                     options:NSJSONReadingAllowFragments
                                                       error:NULL];
                     
                     //NSString *profileImageUrl = [user objectForKey:@"profile_image_url"];
                     
                     
                     //NSLog(@"got user info: %@", user);
                     
                     NSString *idString = [user objectForKey:@"id_str"];
                     if (idString)
                     {
                         passedTwitterIdString=idString;
                     }
                     
                     NSString *screenName = [user objectForKey:@"screen_name"];
                     if (screenName)
                     {
                         passedTwitterSceenName=screenName;
                     }
                     
                     NSString *name = [user objectForKey:@"name"];
                     if (name)
                     {
                         passedTwitterDisplayName=name;
                     }
                     
                     NSString *profileImgUrl = [[user valueForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];//_bigger
                     UIImage *profileImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImgUrl]]];
                     if (profileImage)
                     {
                         NSLog(@"profileImage HIT");
                         passedTwitterProfileImage=profileImage;
                         
                         //[self shouldUploadImage:passedTwitterProfileImage];
                         [self performSelectorOnMainThread:@selector(shouldUploadImage:) withObject:passedTwitterProfileImage waitUntilDone:NO];
                     }
                     else
                     {
                         NSLog(@"profileImage NOT HIT");
                     }
                     
                 }
             }];
            
        }
    }
    
    
    
    
    
}

-(void)signUpAndPresentMainViewController
{
    NSLog(@"signUpAndPresentMainViewController HIT");
    
    NSLog(@"passedTwitterIdString: %@", passedTwitterIdString);
    NSLog(@"passedTwitterSceenName: %@", passedTwitterSceenName);
    NSLog(@"passedTwitterDisplayName: %@", passedTwitterDisplayName);
    NSLog(@"passedTwitterProfileImage: %@", passedTwitterProfileImage);
    NSLog(@"photoFile: %@", photoFile);
    NSLog(@"thumbnailFile: %@", thumbnailFile);
   
    
    if (passedTwitterIdString && passedTwitterSceenName && passedTwitterDisplayName && passedTwitterProfileImage && photoFile && thumbnailFile)
    {
        PFUser *user = [PFUser user];
        user.username = passedTwitterSceenName;
        user.email = [NSString stringWithFormat:@"%@@gmail.com", passedTwitterSceenName];
        user.password = passedTwitterIdString;
        
        [user setObject:passedTwitterDisplayName forKey:@"displayName"];
        
        [user setObject:self.photoFile forKey:@"profilePictureMedium"];
        [user setObject:self.thumbnailFile forKey:@"profilePictureSmall"];
        
        
        // some odd stuff
        [user setObject:passedTwitterSceenName forKey:@"publicUsername"]; // need to keep twitterScreenName as username for login/log out purposes
        [user setObject:@"" forKey:@"status"];
        
        NSDate *now = [NSDate date];
        [user setObject:now forKey:@"startTime"];
        
        NSNumber *number = [NSNumber numberWithInt:0];
        [user setObject:number forKey:@"totalHours"];
        
        [user setObject:@"" forKey:@"currentCity"];
        
        
        [user setObject:@"NO" forKey:@"featured"];
        [user setObject:@"NO" forKey:@"business"];
        
        
        PFACL *publicACL = [PFACL ACL];
        [publicACL setPublicReadAccess:YES];
        //[publicACL setPublicWriteAccess:NO]; // "can not set writeAccess for unsaved user"
        [user setACL:publicACL];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
                
                // SET INSTALLATION STUFF
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
                [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey]; //"channels"
                [[PFInstallation currentInstallation] saveEventually];
                
                // SET USER STUFF
                [user setObject:privateChannelName forKey:kPAPUserPrivateChannelKey]; //"channel"
                [user saveEventually];
                
                
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:YES completion:nil];
                [(ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate] presentMainViewController];
                
                
            }
            else
            {
                //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                //[alertView show];
                
                if (error.code==202) // username already exists, just log in!
                {
                    [self accountExistsSoLogIn];
                }
                
                
            }
            
        }];
    }
    else
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"missing data, reAuth with Twitter" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
    }
    
    
    
}







- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    self.photoFile = nil;
    self.thumbnailFile = nil;
    
    
    UIImage *thumbnailImage1 = [anImage thumbnailImage:400.0f transparentBorder:0.0f cornerRadius:200.0f interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage2 = [anImage thumbnailImage:100.0f transparentBorder:0.0f cornerRadius:50.0f interpolationQuality:kCGInterpolationHigh];
    
    //NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    NSData *imageData = UIImagePNGRepresentation(thumbnailImage1);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage2);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData]; //
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"photoFile success");
            
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    NSLog(@"thumbnailFile success");
                    
                    // now sign up and log in
                    
                    [self signUpAndPresentMainViewController];
                    
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                
                
            }];
        }
        else
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            
            NSLog(@"Photo could not be uploaded");
            
            // go on anyway
            
            [self signUpAndPresentMainViewController];
           
        }
        
    }];
    
    return YES;
}




-(void)accountExistsSoLogIn
{
    NSLog(@"accountExistsSoLogIn HIT");
    
    [PFUser logInWithUsernameInBackground:passedTwitterSceenName password:passedTwitterIdString block:^(PFUser *user, NSError *error) {
		if (user)
        {
            [user setObject:passedTwitterDisplayName forKey:@"displayName"];
            
            [user setObject:self.photoFile forKey:@"profilePictureMedium"];
            [user setObject:self.thumbnailFile forKey:@"profilePictureSmall"];
            
            
            // some odd stuff
            [user setObject:passedTwitterSceenName forKey:@"publicUsername"]; // need to keep twitterScreenName as username for login/log out purposes
            [user setObject:@"" forKey:@"status"];
            
            NSDate *now = [NSDate date];
            [user setObject:now forKey:@"startTime"];
            
            NSNumber *number = [NSNumber numberWithInt:0];
            [user setObject:number forKey:@"totalHours"];
            
            
            [user setObject:@"NO" forKey:@"featured"];
            [user setObject:@"NO" forKey:@"business"];
            
            
            
            
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            
            // SET INSTALLATION STUFF
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey]; //"channels"
            [[PFInstallation currentInstallation] saveEventually];
            
            // SET USER STUFF
            [user setObject:privateChannelName forKey:kPAPUserPrivateChannelKey]; //@"channel"
            [user saveEventually];
            
            
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:YES completion:nil];
            [(ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate] presentMainViewController];
            
            
		}
        else
        {
			// Didn't get a user.
            
			NSLog(@"%s didn't get a user!", __PRETTY_FUNCTION__);
            
			// Re-enable the done button if we're tossing them back into the form.
			UIAlertView *alertView = nil;
            
			if (error == nil) {
				// the username or password is probably wrong.
				alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn’t log in:\nThe username or password were wrong." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			} else {
				// Something else went horribly wrong:
				alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			}
			[alertView show];

		}
	}];
    
    
    
    
}


@end
