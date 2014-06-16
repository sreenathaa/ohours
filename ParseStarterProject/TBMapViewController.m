//
//  TBMapViewController.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

enum Tags {
    TearDownOhoursAlertTag = 0,
    Something1Tag = 1,
    Something2Tag = 2,
};

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

#import <CoreLocation/CoreLocation.h>

#import "TBMapViewController.h"
#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"

#import <Parse/Parse.h> 

#import "ParseStarterProjectAppDelegate.h"

#import "ActivityViewController.h"
#import "CommentsViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"

#import "PAPConstants.h"


@interface TBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;

@property (nonatomic, strong) CLLocationManager *theLocationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSString *currentStatus;

@property (nonatomic, assign) BOOL initiallyLoadingMap;
@property (nonatomic, assign) BOOL initiallyLoadingIsFinished;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) PFUser *currentlyDisplayedUser;

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSArray *activityArrayToPass;
@property (nonatomic, assign) BOOL shouldReloadActivityArrayWhenDone;

@end

@implementation TBMapViewController

@synthesize bottomView;
@synthesize leftBtn;
@synthesize centerBtn;
@synthesize rightBtn;

@synthesize backgroundView;
@synthesize currentlyDisplayedUser;
@synthesize geocoder, placemark;

@synthesize activityArrayToPass;



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserInfoChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.initiallyLoadingMap=YES;
        self.initiallyLoadingIsFinished=NO;
        
        self.view.backgroundColor = [UIColor colorWithRed:164/255 green:219/255 blue:242/255 alpha:1.0];
        
      
        self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
        self.coordinateQuadTree.mapView = self.mapView;
        
        //[self.coordinateQuadTree buildTree];
        
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventEdited:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoChanged:) name:UserInfoChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCommented:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (nil == _theLocationManager)
    {
        _theLocationManager = [[CLLocationManager alloc] init];
    }
    _theLocationManager.delegate = self;
    _theLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _theLocationManager.distanceFilter = kCLDistanceFilterNone;
    [_theLocationManager  startUpdatingLocation];
    //[_theLocationManager startUpdatingHeading];
    
    
    CGFloat square = self.view.frame.size.height+100;
    CGFloat dif = square-self.view.frame.size.width;
    CGRect bigFrame = CGRectMake(0 - (dif/2), 0-50, square, square);
    self.mapView = [[MKMapView alloc] initWithFrame:bigFrame];
    
    //self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    //self.mapView.scrollEnabled = NO;
    //self.mapView.zoomEnabled = NO;
    //self.mapView.rotateEnabled = NO;
    //self.mapView.pitchEnabled = NO;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    
    self.mapView.alpha = 0.0f;
    
    
    
    self.mapView.showsUserLocation = YES;
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////
    
    bottomView = [[UIView alloc]init];
    bottomView.frame = CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height -48 -10, 120, 46);
    bottomView.backgroundColor = [UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
    [self.view addSubview:bottomView];
    //bottomView.layer.cornerRadius = 4.0f;
    //bottomView.layer.masksToBounds =YES;
    
    bottomView.alpha = 0.0f;
    
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(1, 1, 58.5, 44);
    [leftBtn addTarget:self action:@selector(animateToActivityVC1) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:222.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    [bottomView addSubview:leftBtn];
    [leftBtn setImage:[UIImage imageNamed:@"actionBtn3.png"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"actionBtn3.png"] forState:UIControlStateHighlighted];
    //leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(1+58.5+1, 1, 58.5, 44);
    [rightBtn addTarget:self action:@selector(rightBtnAction1:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:222.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    [bottomView addSubview:rightBtn];
    [rightBtn setImage:[UIImage imageNamed:@"actionBtn3.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"actionBtn3.png"] forState:UIControlStateHighlighted];
    //rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	
}



- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];

    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];

    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++)
    {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;

    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];

    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];

    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];

    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}




-(void)crazyTreeBuildingMethod {
    
    // query for active users
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Activty"];
        [query setLimit:0];
    }
    
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    [followingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    followingQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingQuery.limit = 1000;
    
    // THIS GETS MY ACTIVE FRIENDS
    PFQuery *onFollowedUsersQuery = [PFUser query];
    [onFollowedUsersQuery whereKeyExists:@"geoPoint"];
    //[onFollowedUsersQuery whereKey:@"objectId" matchesKey:@"toUser" inQuery:followingQuery];  //this doesn't work bc "objectId" isn't being read
    [onFollowedUsersQuery whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [onFollowedUsersQuery whereKey:@"status" equalTo:@"OPEN"];
	[onFollowedUsersQuery whereKey:@"geoPoint" nearGeoPoint:point withinKilometers:2500.0];
    
    
    PFQuery *featuredUsersQuery = [PFUser query];
    [featuredUsersQuery whereKeyExists:@"geoPoint"];
    [featuredUsersQuery whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [featuredUsersQuery whereKey:@"status" equalTo:@"OPEN"];
    [featuredUsersQuery whereKey:@"featured" equalTo:@"YES"];
    [featuredUsersQuery whereKey:@"geoPoint" nearGeoPoint:point withinKilometers:2500.0];
    
    
    PFQuery *businessUsersQuery = [PFUser query];
    [businessUsersQuery whereKeyExists:@"geoPoint"];
    [businessUsersQuery whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [businessUsersQuery whereKey:@"status" equalTo:@"OPEN"];
    [businessUsersQuery whereKey:@"business" equalTo:@"YES"];
    [businessUsersQuery whereKey:@"geoPoint" nearGeoPoint:point withinKilometers:2500.0];
    
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:onFollowedUsersQuery, featuredUsersQuery, businessUsersQuery, nil]];
    
    //[query includeKey:@"user"];

    
    //[query orderByDescending:@"createdAt"];
    
    
    
    if ([self.coordinateQuadTree.activeFriendsArray count] == 0)
    {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
	}
    else
    {
        [query setCachePolicy:kPFCachePolicyNetworkOnly];
    }
    
    //    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            
            
            // get last location for each user - if they have multiple locations today...
            
            
            
            
            self.coordinateQuadTree.activeFriendsArray = objects;
            NSLog(@"self.onFriendsArray.count: %lu", (unsigned long)self.coordinateQuadTree.activeFriendsArray.count);
            
            
            
            NSInteger count = self.coordinateQuadTree.activeFriendsArray.count;
            
            NSMutableArray *lines = [NSMutableArray array];
            
            for (int i=0; i< count ; i++) {
                
                // add lat/long to TestAnotation
                
                PFObject *obj = [self.coordinateQuadTree.activeFriendsArray objectAtIndex:i];
                
                PFGeoPoint *liveGeoPoint = [obj objectForKey:@"geoPoint"];
                NSString *aLine = [NSString stringWithFormat:@"%f, %f, %i, %@", liveGeoPoint.longitude, liveGeoPoint.latitude, i, @"484-883-1234"];
                
                [lines addObject:aLine];
                
            }
            
            NSArray *linesArray = [NSArray arrayWithArray:lines];
            
            //NSLog(@"linesArray: %@", linesArray);
            
            TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * linesArray.count);
            for (NSInteger i = 0; i < linesArray.count; i++) {
                dataArray[i] = TBDataFromLine(linesArray[i]);
            }
            
            NSInteger *linesCount = linesArray.count;
            
            TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
            self.coordinateQuadTree.root = TBQuadTreeBuildWithData(dataArray, linesCount, world, 4);
            
            
            
            ///////
            
            
            [self performSelector:@selector(loadInitialAnnotations:) withObject:nil afterDelay:2.0];
            
            
        }
        else
        {
            NSLog(@"wtff error: %@", [error description]);
        }
    }];
    
    
}










#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
    NSLog(@"mapViewDidFinishLoadingMap HIT");
    
    
    if (self.initiallyLoadingMap)
    {
        NSLog(@"mapViewDidFinishLoadingMap HIT inside self.initiallyLoadingMap");
        //self.initiallyLoadingMap=NO;

        
        [self setCenterCoordinate:self.currentLocation.coordinate zoomLevel:1 animated:NO];
        //[self setCenterCoordinate:self.currentLocation.coordinate zoomLevel:12 animated:NO]; // 12 is best, gets full view of cities
        
        
        [self crazyTreeBuildingMethod];
        
        
    }
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"mapView regionDidChangeAnimated HIT");
    
    currentZoomLevel = [self getZoomLevel];
    //NSLog(@"currentZoomLevel: %i", currentZoomLevel);
    
    
    if (self.initiallyLoadingIsFinished)
    {
        [[NSOperationQueue new] addOperationWithBlock:^{
            double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
            
            [self updateMapViewAnnotationsWithAnnotations:annotations];
        }];
        return;
    }
   
    if (self.initiallyLoadingMap == NO)
    {
        self.initiallyLoadingIsFinished = YES;
        
        NSLog(@"regionDidChangeAnimated HIT inside self.initiallyLoadingMap");
        
        [[NSOperationQueue new] addOperationWithBlock:^{
            double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
            
            [self updateMapViewAnnotationsWithAnnotations:annotations];
        }];
        
        
        
        // update location automatically when opening the app ?
//        
//        PFUser *newMe = [PFUser currentUser];
//        
//        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
//        
//        [newMe setObject:currentPoint forKey:@"geoPoint"];
//        
//        PFACL *publicACL = [PFACL ACL];
//        [publicACL setPublicReadAccess:YES];
//        [publicACL setPublicWriteAccess:NO];
//        [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
//        [newMe setACL:publicACL];
//        
//        [newMe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded)
//            {
//                NSLog(@"successfully started new Ohours");
//                
//                // now do the currentCity
//                [self getReverseGeocode];
//                
//            }
//            else
//            {
//
//            }
//            if (error)
//            {
//
//            }
//        }];
        
        return;
    }
    
    
    
    
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        //((MKUserLocation *)annotation).title = @"";
        //return nil;
        
        MKAnnotationView *userLocationView = [self.mapView viewForAnnotation:annotation];
        userLocationView.canShowCallout = NO;
        
        return userLocationView;
    }
    
    
    static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";

    TBClusterAnnotationView *annotationView = (TBClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];

    if (!annotationView)
    {
        annotationView = [[TBClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
    }

    annotationView.canShowCallout = NO;
    annotationView.count = [(TBClusterAnnotation *)annotation count];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}



///////////////////////////

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView HIT");
    
    
    if([view.annotation isKindOfClass:[MKUserLocation class]])
    {
        NSLog(@"didSelect MKUserLocation HIT");

        
        // deselect annotation right away ?
        NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
        NSLog(@"selectedAnnotations: %@", selectedAnnotations);
        
        for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations]) {
            [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
        }
        
        return;
    }
    
    
    
    if([view.annotation isKindOfClass:[TBClusterAnnotation class]]) {
        
        TBClusterAnnotation *cluster = (TBClusterAnnotation *)view.annotation;
        
        if(cluster.count > 1)
        {
            // ugh
                        
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(cluster.coordinate,
                                                                  cluster.radius * 3.5f,
                                                                  cluster.radius * 3.5f) animated:YES];
            
            // deselect annotation
            
            NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
            NSLog(@"selectedAnnotations: %@", selectedAnnotations);
            
            for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations]) {
                [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
            }

        }
        else
        {
            NSLog(@"a single annotation: ");
            
            PFUser *user = [self.coordinateQuadTree.activeFriendsArray objectAtIndex:cluster.title.integerValue];
            if (user)
            {
                //NSLog(@"user: %@", user);
                self.currentlyDisplayedUser = user;
                
                [self animateToCommentsVCWithUser:self.currentlyDisplayedUser];
                
                
            }
            
            
            
        }
    }
}


- (void)setUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    NSLog(@"setUserTrackingMode HIT");
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    
    
    [_theLocationManager stopUpdatingLocation]; // STOP so the map stops repositioning
    
    
    CLLocation *newLocation = [locations lastObject];
    
    self.currentLocation = newLocation;
    
    NSLog(@"currentLocation & didUpdateLocations HIT");

    
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"wtf Error: %@", [error description]);
    
    [_theLocationManager stopUpdatingLocation];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Required"
                                                    message:@"Go to Settings.app >> Privacy >> Location Services and switch Ohours to ON" //[error description]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    
    
	if (error.code == kCLErrorDenied)
    {
		
	}
    else if (error.code == kCLErrorLocationUnknown)
    {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	}
    else
    {
        
	}
}



#pragma mark Method Actions

-(void)loadInitialAnnotations:(id)sender {
    
    NSLog(@"loadInitialAnnotations HIT");
    
    [UIView animateWithDuration:0.100f animations:^{
        self.mapView.alpha = 1.0f;
        bottomView.alpha = 1.0f;
    } completion:^(BOOL finished){
        if (finished)
        {
            [[NSOperationQueue new] addOperationWithBlock:^{
                double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
                NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:self.mapView.visibleMapRect withZoomScale:scale];
                
                [self updateMapViewAnnotationsWithAnnotations:annotations];
            }];
            
            
            [self nowQueryForActivity];
            
        }
    }];
}

-(void)nowQueryForActivity {
    
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

            self.activityArrayToPass = [NSArray arrayWithArray:ma1];
            
        }
    }];
}

-(void)animateToActivityVC1 {
    
    ParseStarterProjectAppDelegate *appDelegate = (ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect testRect = CGRectMake(0, 10, appDelegate.window.frame.size.width-0, appDelegate.window.frame.size.height-20);
    
    ActivityViewController *avc = [[ActivityViewController alloc]initWithArray:self.activityArrayToPass]; //self.coordinateQuadTree.activeFriendsArray
    avc.view.backgroundColor = [UIColor whiteColor];
    
    avc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector (doneBtnAction)];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 25, 25);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton addTarget:self action:@selector(settingsBtnAction1:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"gearTest2.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"gearTest2Light.png"] forState:UIControlStateHighlighted];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(2, 6, 0, -4); //top, left, bottom, right
    
    UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    avc.navigationItem.rightBarButtonItem = settingsBtn;
    
    
    _nav = [[UINavigationController alloc] initWithRootViewController:avc];
    _nav.view.layer.cornerRadius=3.0f;
    _nav.view.layer.masksToBounds=YES;
    _nav.view.frame = testRect;
    [appDelegate.window addSubview:_nav.view];
    
    
    backgroundView = [[UIView alloc] initWithFrame:[appDelegate.window bounds]];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.00f alpha:0.75f];
    backgroundView.alpha = 0.0f;
    [appDelegate.window insertSubview:backgroundView belowSubview:_nav.view];
    
    
    CGAffineTransform transformStep1 = CGAffineTransformMakeScale(1.05f, 1.05f);
    CGAffineTransform transformStep2 = CGAffineTransformMakeScale(1, 1);
    
    
    _nav.view.transform = CGAffineTransformMakeScale(0.25, 0.25);
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ //UIViewAnimationOptionCurveEaseInOut
        
        //newNav.view.transform = CGAffineTransformIdentity;
        _nav.view.layer.affineTransform = transformStep1;
        
        backgroundView.alpha = 1.0f;
        
    } completion:^(BOOL finished){
        if (finished)
        {
            if (finished) {
                [UIView animateWithDuration:0.20f animations:^{
                    _nav.view.layer.affineTransform = transformStep2;
                }];
            }
        }
        
    }];
    
}

-(void)animateToCommentsVCWithUser:(PFUser*)user
{
    ParseStarterProjectAppDelegate *appDelegate = (ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect testRect = CGRectMake(0, 10, appDelegate.window.frame.size.width-0, appDelegate.window.frame.size.height-20);
    //CGRect testRect = CGRectMake(5, 10, appDelegate.window.frame.size.width -10, appDelegate.window.frame.size.height -20);
    
    //CommentsViewController *cvc = [[CommentsViewController alloc] initWithUserObject:user];
    ProfileViewController *cvc = [[ProfileViewController alloc] initWithUser:user];
    cvc.view.backgroundColor = [UIColor whiteColor];
    
    cvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnAction)];
    
    
    _nav = [[UINavigationController alloc] initWithRootViewController:cvc];
    _nav.view.layer.cornerRadius=3.0f;
    _nav.view.layer.masksToBounds=YES;
    _nav.view.frame = testRect;
    [appDelegate.window addSubview:_nav.view];
    
    
    
    backgroundView = [[UIView alloc] initWithFrame:[appDelegate.window bounds]];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.00f alpha:0.75f];
    backgroundView.alpha = 0.0f;
    [appDelegate.window insertSubview:backgroundView belowSubview:_nav.view];
    
    
    CGAffineTransform transformStep1 = CGAffineTransformMakeScale(1.05f, 1.05f);
    CGAffineTransform transformStep2 = CGAffineTransformMakeScale(1, 1);
    
    
    _nav.view.transform = CGAffineTransformMakeScale(0.25, 0.25);
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ //UIViewAnimationOptionCurveEaseInOut
        
        //newNav.view.transform = CGAffineTransformIdentity;
        _nav.view.layer.affineTransform = transformStep1;
        
        backgroundView.alpha = 1.0f;
        
    } completion:^(BOOL finished){
        if (finished)
        {
            if (finished) {
                [UIView animateWithDuration:0.20f animations:^{
                    _nav.view.layer.affineTransform = transformStep2;
                }];
            }
        }
        
    }];
}


-(void)settingsBtnAction1:(id)sender
{
    
    SettingsViewController *svc = [[SettingsViewController alloc]init];
    [_nav pushViewController:svc animated:YES];
    
    
}

-(void)doneBtnAction
{
    NSLog(@"doneBtnAction HIT");
    
    self.view.userInteractionEnabled = NO;
    
    
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{ //UIViewAnimationOptionCurveEaseInOut
        
        _nav.view.transform = CGAffineTransformMakeScale(0.25, 0.25);
        
        _nav.view.alpha = 0.0f;
        
        backgroundView.alpha = 0.0f;
        
    } completion:^(BOOL finished){
        if (finished)
        {
            _nav.view.hidden=YES;
            backgroundView.hidden=YES;
            
            for (UIView *view in _nav.view.subviews)
            {
                [view removeFromSuperview];
            }
            
            [_nav.view removeFromSuperview];
            
            [backgroundView removeFromSuperview];
            
            
            // deselect annotation
            
            NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
            NSLog(@"selectedAnnotations: %@", selectedAnnotations);
            
            for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations]) {
                [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
            }
            
            self.view.userInteractionEnabled = YES;
            
            
            
            if (self.shouldReloadActivityArrayWhenDone) 
            {
                self.shouldReloadActivityArrayWhenDone = NO;
                
                [self nowQueryForActivity];
            }
            
        }
        
    }];
    
    
}


- (void)centerBtnAction1:(id)sender
{
//    NSLog(@"go live(if not live already) AND zoom in to currentLocation");
//    
//    if ([self.currentStatus isEqualToString:@"OPEN"])
//    {
//        // just navigate
//        [self setCenterCoordinate:self.currentLocation.coordinate zoomLevel:15 animated:YES];
//        
//        
//    }
//    else
//    {
//        //if status == OFF ... turn button ON, save data, then navigate
//        
//        [self newMeAction];
//        
//        self.mapView.showsUserLocation = YES;
//        
//        [self setCenterCoordinate:self.currentLocation.coordinate zoomLevel:15 animated:YES];
//        
//    }
    
    
    
    
    //CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    //[self.mapView setCenterCoordinate:userCoordinate animated:YES];
    
    //[self newLocationAction];
    
    
    CLLocationCoordinate2D nearbyCoord = CLLocationCoordinate2DMake(39.963296, -75.544316);
    
    PFObject *newLocation = [PFObject objectWithClassName:@"Location"];
    
    [newLocation setObject:[PFUser currentUser] forKey:@"user"];
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:nearbyCoord.latitude longitude:nearbyCoord.longitude];
    [newLocation setObject:currentPoint forKey:@"geoPoint"];
    
    PFACL *publicACL = [PFACL ACL];
    [publicACL setPublicReadAccess:YES];
    [publicACL setPublicWriteAccess:NO];
    [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [newLocation setACL:publicACL];
    
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
        }
    }];
    
    
}

- (void)rightBtnAction1:(id)sender
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:self.mapView.visibleMapRect withZoomScale:scale];
        
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
    
    
    // zoom out a little
    
    CLLocationCoordinate2D center = [self.mapView centerCoordinate];
    //NSLog(@"currentZoomLevel: %i", currentZoomLevel);
    int newZoom;
    
    if (currentZoomLevel<3)
    {
        newZoom = 1;
    }
    else
    {
        newZoom = currentZoomLevel-2;
    }
    
    
    [self setCenterCoordinate:center zoomLevel:newZoom animated:YES];
    
    
}



////////////////////////////////////////////////

-(void)newLocationAction
{
    NSLog(@"newLocationAction HIT");
    
    PFObject *newLocation = [PFObject objectWithClassName:@"Location"];
    
    [newLocation setObject:[PFUser currentUser] forKey:@"user"];
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [newLocation setObject:currentPoint forKey:@"geoPoint"];
    
    PFACL *publicACL = [PFACL ACL];
    [publicACL setPublicReadAccess:YES];
    [publicACL setPublicWriteAccess:NO];
    [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [newLocation setACL:publicACL];
    
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"successful newLocation");
            
            // now do the currentCity
            //[self getReverseGeocode];
            
            [self.coordinateQuadTree buildTree];
            
            
            
        }
        else
        {
            if (error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error description]
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
    }];

}




-(void)newMeAction
{
    NSLog(@"newMeAction HIT");
    
    PFUser *newMe = [PFUser currentUser];
    
    [newMe setObject:@"OPEN" forKey:@"status"];
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    //[newMe addUniqueObject:currentPoint forKey:@"locations"];
    
    [newMe setObject:currentPoint forKey:@"geoPoint"];
    
    NSDate *now = [NSDate date];
    [newMe setObject:now forKey:@"startTime"];
    
    //[newMe setObject:currentCityString forKey:@"currentCity"];
    
    
    [newMe setObject:@"NO" forKey:@"featured"];
    [newMe setObject:@"NO" forKey:@"business"];
    
    
    PFACL *publicACL = [PFACL ACL];
    [publicACL setPublicReadAccess:YES];
    [publicACL setPublicWriteAccess:NO];
    [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [newMe setACL:publicACL];

    
    [newMe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"successfully started new Ohours");
            
            self.currentStatus = @"OPEN";
            
            // now do the currentCity
            [self getReverseGeocode];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    
        
    }];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == TearDownOhoursAlertTag)
    {
        if (buttonIndex == 0)
        {
            //do nothing
        }
        else
        {
            PFUser *newMe = [PFUser currentUser];
            
            if ([self.currentStatus isEqualToString:@"OPEN"])
            {
                // turn OFF
                self.mapView.showsUserLocation = NO;
                
                [self performSelector:@selector(doneBtnAction) withObject:nil afterDelay:0.0];
                
                [newMe setObject:@"CLOSED" forKey:@"status"];
                
                NSDate *now = [NSDate date];
                
                NSDate *originalStartTime = [[PFUser currentUser] objectForKey:@"startTime"];
                
                NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:originalStartTime];
                NSLog(@"distanceBetweenDates: %f", distanceBetweenDates);
                
                double between = distanceBetweenDates/3600; //secs in an hour
                NSLog(@"between: %f", between);
                
                NSNumber *incrementNum = [NSNumber numberWithFloat:between];
                NSLog(@"incrementNum: %@", incrementNum);
                
                //NSNumber *previousTotalHours = [[PFUser currentUser] objectForKey:@"totalHours"];
                //NSNumber *sum = [NSNumber numberWithFloat:([previousTotalHours floatValue] + [incrementNum floatValue])];
                
                [newMe incrementKey:@"totalHours" byAmount:incrementNum];
                
                PFACL *publicACL = [PFACL ACL];
                [publicACL setPublicReadAccess:YES];
                [publicACL setPublicWriteAccess:NO];
                [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
                [newMe setACL:publicACL];
                
                [newMe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        NSLog(@"successful tear down");
                        
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[error description]
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                    if (error)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[error description]
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                    
                    
                }];
                
            }
            else
            {
                // turn ON - from infoBtn ?
                
                [self newMeAction];
                
                self.mapView.showsUserLocation = YES;
                
                return;
            }
            
            
        }
        
        
    }
    
}



-(void)getReverseGeocode
{
    NSLog(@"getReverseGeocode HIT");
    
    __block NSString *returnedString;
    
    if(self.currentLocation)
    {
        CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lastCoordinate.latitude longitude:lastCoordinate.longitude];
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                
                self.placemark = [placemarks lastObject];
                
                if (self.placemark.subThoroughfare == NULL)
                {
                    
                    returnedString = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
                    NSLog(@"returnedString1: %@", returnedString);
                    
                }
                else
                {
                    //                    NSString *string2 = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",  //@"%@ %@\n%@ %@\n%@\n%@"
                    //                                                    self.placemark.subThoroughfare, placemark.thoroughfare,
                    //                                                    self.placemark.locality, self.placemark.administrativeArea,
                    //                                                    self.placemark.postalCode,
                    //                                                    self.placemark.country];
                    
                    if (self.placemark.locality && self.placemark.administrativeArea)
                    {
                        returnedString = [NSString stringWithFormat:@"%@, %@", self.placemark.locality, self.placemark.administrativeArea];
                        NSLog(@"returnedString2a: %@", returnedString);
                    }
                    else
                    {
                        returnedString = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
                        NSLog(@"returnedString2b: %@", returnedString);
                    }
                    
                    
                }
                
                // either way upDate user
                
                PFUser *newMe = [PFUser currentUser];
                [newMe setObject:returnedString forKey:@"currentCity"];
                
                PFACL *publicACL = [PFACL ACL];
                [publicACL setPublicReadAccess:YES];
                [publicACL setPublicWriteAccess:NO];
                [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
                [newMe setACL:publicACL];
                
                [newMe saveInBackground];
                
                
            }
            else
            {
                returnedString = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
                NSLog(@"returnedString3: %@", returnedString);
                
                PFUser *newMe = [PFUser currentUser];
                [newMe setObject:returnedString forKey:@"currentCity"];
                
                PFACL *publicACL = [PFACL ACL];
                [publicACL setPublicReadAccess:YES];
                [publicACL setPublicWriteAccess:NO];
                [publicACL setWriteAccess:YES forUser:[PFUser currentUser]];
                [newMe setACL:publicACL];
                
                [newMe saveInBackground];
                
            }
        }];
        
    }
    
}


#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = self.mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 15);
    
    NSUInteger *castedZoomLevel = arc4random_uniform((uint32_t) zoomLevel);
    
    currentZoomLevel =  castedZoomLevel;
    // NSLog(@"currentZoomLevel: %@", currentZoomLevel);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self.mapView centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self.mapView setRegion:region animated:animated];
    
    
    
    
    NSLog(@"final ?");
    
    if (self.initiallyLoadingMap)
    {
        self.initiallyLoadingMap = NO;
        
    }
    
}

-(double) getZoomLevel {
    return log2(360 * ((self.mapView.frame.size.width/256) / self.mapView.region.span.longitudeDelta));
}



- (void)eventEdited:(NSNotification *)note
{
    NSLog(@"eventEdited hit");
    
    
}

- (void)userInfoChanged:(NSNotification *)note
{
    NSLog(@"userInfoChanged hit");
    
    

}

-(void)userFollowingChanged:(NSNotification*)note
{
    NSLog(@"userInfoChanged hit");
    
}

-(void)userCommented:(NSNotification*)note
{
    NSLog(@"userCommented hit");
    
    self.activityArrayToPass = nil;
    
    self.shouldReloadActivityArrayWhenDone = YES;
    
}

@end
