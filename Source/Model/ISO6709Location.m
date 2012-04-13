//
//  ISO6709Location.m
//
//  Created by Otto Schnurr on 4/13/12.
//  Copyright 2012
//
//  Much of this was transcribed from http://coordinate.codeplex.com
//

#import "ISO6709Location.h"


// +DD.DDDD+DDD.DDDD/ (eg +12.3450-098.7650/)
static NSString* const _degreeDegreeFormat = @"%+08.4f%+09.4f/";
static const NSUInteger _minimumFormatLength = 18u;
static NSString* const _formatSuffix = @"/";


NSString* ISO6709Location_stringFromCoordinate( 
   CLLocationCoordinate2D coordinate 
)
{
   NSString* locationString = nil;
   
   if ( CLLocationCoordinate2DIsValid( coordinate ) )
   {
      locationString = [NSString stringWithFormat: _degreeDegreeFormat, 
         coordinate.latitude, coordinate.longitude];
   }

   return locationString;
}

CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
)
{
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;

   const BOOL stringHasRequiredSuffix = [locationString hasSuffix: _formatSuffix];
   const BOOL stringIsTooShort = locationString.length < _minimumFormatLength;

   if ( stringHasRequiredSuffix && !stringIsTooShort )
   {
      location = CLLocationCoordinate2DMake( 0., 0. );
   }
   
   return location;
}
