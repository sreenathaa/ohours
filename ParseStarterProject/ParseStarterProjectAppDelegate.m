#import <Parse/Parse.h>
#import "ParseStarterProjectAppDelegate.h"

#import "PAPCache.h"
#import "PAPConstants.h"

#import "ActivityViewController.h" 


@implementation ParseStarterProjectAppDelegate

@synthesize window = _window;
@synthesize wvc, tvc;



#pragma mark - UIApplicationDelegate

-(void)presentMainViewController
{
//    mvc = [[MainViewController alloc] initWithNibName:nil bundle:nil];
//	self.navController = [[UINavigationController alloc] initWithRootViewController:mvc];
//    self.navController.navigationBarHidden = YES;

    tvc = [[TBMapViewController alloc] initWithNibName:nil bundle:nil];
	self.navController = [[UINavigationController alloc] initWithRootViewController:tvc];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    
}

-(void)presentWelcomeViewController
{
    wvc = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
	self.navController = [[UINavigationController alloc] initWithRootViewController:wvc];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    
}

-(void)createAnonymousUser
{
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error)
        {
            NSLog(@"Anonymous login failed.");
        }
        else
        {
            NSLog(@"Anonymous user logged in.");
                        
            
            [self presentMainViewController];
            
            
        }
    }];
    
}




#pragma mark - Application delegation methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];


	[Parse setApplicationId:@"" clientKey:@""];
    
    
    
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        [self presentMainViewController];
    }
    else
    {
        [self createAnonymousUser];
        
        //[self presentWelcomeViewController];
    }
    
    
//    PFUser *currentUser = [PFUser currentUser];
//    if (currentUser)
//    {
//        NSLog(@"currentUser");
//        
//        // clear cache
//        [[PAPCache sharedCache] clear];
//        
//        // clear NSUserDefaults
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
//        [[PFInstallation currentInstallation] setObject:@[@""] forKey:kPAPInstallationChannelsKey];
//        [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
//        [[PFInstallation currentInstallation] saveInBackground];
//        
//        // Log out
//        [PFUser logOut];
//        
//        [self createAnonymousUser];
//    }
//    else
//    {        
//        [self createAnonymousUser];
//    }
    
    
    
    
    
    return YES;
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    
}

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"Bigbird successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"Bigbird failed to subscribe to push notifications on the broadcast channel.");
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    
    //    NSLog(@"GONE TO BACKGROUND, vc.previousIdString: %@", vc.previousIdString);
    //
    //    PFUser *newMe = [PFUser currentUser];
    //    [newMe setValue:vc.previousIdString forKey:@"lastTweetId"];
    //    [newMe save];
    
}





- (void)logOut
{
    // clear cache
    [[PAPCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
    [[PFInstallation currentInstallation] setObject:@[@""] forKey:kPAPInstallationChannelsKey];
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    
    for (UIView *view in self.navController.view.subviews)
    {
        [view removeFromSuperview];
    }
    
    [self.navController.view removeFromSuperview];
    
    
    [self presentWelcomeViewController];
    
    
}

@end
