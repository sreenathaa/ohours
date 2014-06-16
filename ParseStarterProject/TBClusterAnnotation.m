//
//  TBClusterAnnotation.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/8/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBClusterAnnotation.h"

@implementation TBClusterAnnotation


- (id)initWithAnnotations:(NSArray *)annotations {
    return [self initWithAnnotationSet:[NSSet setWithArray:annotations]];
}

- (id)initWithAnnotationSet:(NSSet *)set {
    self = [super init];
    
    if(self)
    {
        self.annotations = set;
        
        
        [self calculateValues];
        
        
    }
    
    return self;
}



- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count
{
    self = [super init];
    if (self)
    {
        _coordinate = coordinate;
        _title = [NSString stringWithFormat:@"%d hotels in this area", count];
        _count = count;
        
        
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}




#pragma mark - Private

- (void)calculateValues {
    
    CLLocationDegrees minLat = INT_MAX;
    CLLocationDegrees minLng = INT_MAX;
    CLLocationDegrees maxLat = -INT_MAX;
    CLLocationDegrees maxLng = -INT_MAX;
    
    CLLocationDegrees totalLat = 0;
    CLLocationDegrees totalLng = 0;
    
    CLLocationDegrees lat = _coordinate.latitude;
    CLLocationDegrees lng = _coordinate.longitude;
    
    minLat = MIN(minLat, lat);
    minLng = MIN(minLng, lng);
    maxLat = MAX(maxLat, lat);
    maxLng = MAX(maxLng, lng);
    
    totalLat += lat;
    totalLng += lng;
    
    
    
    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                              longitude:minLng]
                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                   longitude:maxLng]] / 2.f;
}





@end
