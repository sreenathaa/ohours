//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"

#import <Parse/Parse.h>


typedef struct TBHotelInfo {
    char* hotelName;
    char* hotelPhoneNumber;
} TBHotelInfo;

TBQuadTreeNodeData TBDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@","];
    double latitude = [components[1] doubleValue];
    double longitude = [components[0] doubleValue];

    TBHotelInfo* hotelInfo = malloc(sizeof(TBHotelInfo));

    NSString *hotelName = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);

    NSString *hotelPhoneNumber = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);

    return TBQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));

    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;

    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;

    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));

    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));

    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);

    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;

        default:
            return 100; //88;
    }
}

@implementation TBCoordinateQuadTree

- (void)buildTree
{
    NSLog(@"buildTree HIT");
    
//    @autoreleasepool {
//        NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USA-HotelMotel" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
//        NSArray *lines = [data componentsSeparatedByString:@"\n"];
//
//        NSInteger count = lines.count - 83400;  // - 1;
//        
//        NSLog(@"lines.count: %lu", (unsigned long)lines.count);  //83433
//        
//        //NSLog(@"lines: %@", lines);
//
//        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
//        for (NSInteger i = 0; i < count; i++) {
//            dataArray[i] = TBDataFromLine(lines[i]);
//        }
//        
//        NSInteger *linesCount = lines.count;
//
//        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
//        _root = TBQuadTreeBuildWithData(dataArray, linesCount, world, 4);
//    }
    
    
    
    
    ////////////////////////////////////////////////////////////////
    
    NSDate *now = [NSDate date];
    unsigned int      intFlags   = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSCalendar       *calendar   = [NSCalendar currentCalendar]; //
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:intFlags fromDate:now];
    
    NSDate *startOfDay = [[NSDate alloc] init];
    startOfDay = [calendar dateFromComponents:components];
    
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:86400];
    
    // query for active users
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Activty"];
        [query setLimit:0];
    }
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    [followingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    followingQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingQuery.limit = 1000;
    
    // THIS GETS MY ACTIVE FRIENDS
    PFQuery *onFollowedUsersQuery = [PFUser query];
    [onFollowedUsersQuery whereKeyExists:@"geoPoint"];
    [onFollowedUsersQuery whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [onFollowedUsersQuery whereKey:@"status" equalTo:@"OPEN"];
    
    
    
//    PFQuery *locationsFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Location"];
//    [locationsFromFollowedUsersQuery whereKey:@"user" matchesKey:@"toUser" inQuery:followingQuery];
//    [locationsFromFollowedUsersQuery whereKeyExists:@"geoPoint"];
//    
//    PFQuery *locationsFromCurrentUserQuery = [PFQuery queryWithClassName:@"Location"];
//    [locationsFromCurrentUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
//    [locationsFromCurrentUserQuery whereKeyExists:@"geoPoint"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:onFollowedUsersQuery, nil]];

    //[query includeKey:@"user"];
    //[query whereKey:@"createdAt" greaterThanOrEqualTo:startOfDay];
    //[query whereKey:@"createdAt" lessThanOrEqualTo:endOfDay];
    
    //[query orderByDescending:@"createdAt"];
    
    
    
    if ([self.activeFriendsArray count] == 0)
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
            
            
            
            
            
            
            
            
            self.activeFriendsArray = objects;
            NSLog(@"self.onFriendsArray.count: %lu", (unsigned long)self.activeFriendsArray.count);
            
            
            
            NSInteger count = self.activeFriendsArray.count;
            
            NSMutableArray *lines = [NSMutableArray array];
            
            for (int i=0; i< count ; i++) {
                
                // add lat/long to TestAnotation
                
                PFObject *obj = [self.activeFriendsArray objectAtIndex:i];
                
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
            _root = TBQuadTreeBuildWithData(dataArray, linesCount, world, 4);
            
            
            
            
        }
        else
        {
            NSLog(@"wtff error: %@", [error description]);
        }
    }];
    
    
    
    
    
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;

    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    for (NSInteger x = minX; x <= maxX; x++) {
        
        for (NSInteger y = minY; y <= maxY; y++) {
            
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;

            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            
            __block CLLocationDegrees minLat = INT_MAX;
            __block CLLocationDegrees minLng = INT_MAX;
            __block CLLocationDegrees maxLat = -INT_MAX;
            __block CLLocationDegrees maxLng = -INT_MAX;
            

            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;

                TBHotelInfo hotelInfo = *(TBHotelInfo *)data.data;
                
                //NSLog(@"lat %f", data.x);
                //NSLog(@"lng %f", data.y);
                CLLocationDegrees lat = data.x;
                CLLocationDegrees lng = data.y;
                
                minLat = MIN(minLat, lat);
                minLng = MIN(minLng, lng);
                maxLat = MAX(maxLat, lat);
                maxLng = MAX(maxLng, lng);
                
                
                [names addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelName]];
                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelPhoneNumber]];
                
                
            });

            if (count == 1)
            {
                //NSLog(@"count == 1 HIT");
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                annotation.title = [names lastObject];
                annotation.subtitle = [phoneNumbers lastObject];
                [clusteredAnnotations addObject:annotation];
            }

            if (count > 1)
            {
                //NSLog(@"count > 1");
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);

                
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];


                annotation.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                                          longitude:minLng]
                               distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                               longitude:maxLng]] / 2.f;
                
                
                
                [clusteredAnnotations addObject:annotation];
                
            }
        }
    }

    return [NSArray arrayWithArray:clusteredAnnotations];
}



//- (void)calculateValues {
//    
//    CLLocationDegrees minLat = INT_MAX;
//    CLLocationDegrees minLng = INT_MAX;
//    CLLocationDegrees maxLat = -INT_MAX;
//    CLLocationDegrees maxLng = -INT_MAX;
//    
//    CLLocationDegrees totalLat = 0;
//    CLLocationDegrees totalLng = 0;
//    
//    for(id<MKAnnotation> a in self.annotations){
//        
//        CLLocationDegrees lat = [a coordinate].latitude;
//        CLLocationDegrees lng = [a coordinate].longitude;
//        
//        minLat = MIN(minLat, lat);
//        minLng = MIN(minLng, lng);
//        maxLat = MAX(maxLat, lat);
//        maxLng = MAX(maxLng, lng);
//        
//        totalLat += lat;
//        totalLng += lng;
//    }
//    
//    
//    self.coordinate = CLLocationCoordinate2DMake(totalLat / self.annotations.count,
//                                                 totalLng / self.annotations.count);
//    
//    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
//                                              longitude:minLng]
//                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
//                                                                   longitude:maxLng]] / 2.f;
//}

@end
