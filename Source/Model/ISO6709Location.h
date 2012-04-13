//
//  ISO6709Location.h
//
//  Created by Otto Schnurr on 4/13/12.
//  Copyright 2012
//
//  Cocoa functions for creating and parsing an ISO 6709 coordinate string.
//

#import <CoreLocation/CLLocation.h>

@class NSString;

// Returns nil for kCLLocationCoordinate2DInvalid.
NSString* ISO6709Location_stringFromCoordinate( 
   CLLocationCoordinate2D coordinate 
);

// Returns kCLLocationCoordinate2DInvalid for an invalid string.
// Use CLLocationCoordinate2DIsValid() to test validity.
CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
);
