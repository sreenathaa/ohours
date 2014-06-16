//
//  TBClusterAnnotation.h
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/8/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TBClusterAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) NSInteger count;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;


@property (nonatomic, readwrite) float radius;
@property (nonatomic, readwrite) NSSet *annotations;

- (id)initWithAnnotations:(NSArray *)annotations;
- (id)initWithAnnotationSet:(NSSet *)set;

@end
