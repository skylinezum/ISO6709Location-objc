//
//  ISO6709Location.h
//
//  Created by Otto on 4/13/12.
//  Copyright (c) 2012 TechSmith. All rights reserved.
//

#import <CoreLocation/CLLocation.h>

@class NSString;

// Returns nil for kCLLocationCoordinate2DInvalid.
NSString* ISO6709Location_stringFromCoordinate( 
   CLLocationCoordinate2D coordinate 
);

// Returns kCLLocationCoordinate2DInvalid for an invalid string.
CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
);
