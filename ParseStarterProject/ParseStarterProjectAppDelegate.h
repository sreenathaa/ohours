
#import "WelcomeViewController.h"

#import "TBMapViewController.h"

@interface ParseStarterProjectAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, strong) WelcomeViewController *wvc;

@property (nonatomic, strong) TBMapViewController *tvc;



-(void)presentMainViewController;

-(void)logOut;


@end
