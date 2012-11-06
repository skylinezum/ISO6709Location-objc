//
//  ISO6709Location.h
//  Cocoa functions for creating and parsing an ISO 6709 coordinate string.
//
//  Copyright (c) 2012, TechSmith Corporation
//  All rights reserved.
//
//  BSD Simplified License
//     file: ./LICENSE.txt
//     http://www.opensource.org/licenses/BSD-3-Clause
//

#import <CoreLocation/CLLocation.h>

@class NSString;

// Returns nil if the coordinate is invalid.
NSString* ISO6709Location_stringFromCoordinate( 
   CLLocationCoordinate2D coordinate 
);

// Returns kCLLocationCoordinate2DInvalid if the location is invalid.
// Use CLLocationCoordinate2DIsValid() to test validity.
CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
);
