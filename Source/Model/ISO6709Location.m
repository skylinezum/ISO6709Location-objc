//
//  ISO6709Location.m
//
//  Created by Otto Schnurr on 4/13/12.
//  Copyright 2012
//
//  Much of this was transcribed from http://coordinate.codeplex.com
//

#import "ISO6709Location.h"
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSScanner.h>


// +DD.DDDD+DDD.DDDD/ (eg +12.3450-098.7650/)
static NSString* const _degreeDegreeFormat = @"%+08.4f%+09.4f/";

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


#pragma mark -

static NSRange _parseNextWord( NSString* locationString, NSRange previousWord )
{
   // !!!: implement me
   return NSMakeRange( 0u, 0u );
}

static BOOL _isTerminatingSubstring( NSString* locationString, NSRange range )
{
   // !!!: implement me
   return NO;
}

static BOOL _validWordLengths( 
   NSUInteger latitudeWordLength,
   NSUInteger longitudeWordLength
)
{
   // !!!: implement me
   return NO;
}

static BOOL _parseLatitude( 
   NSString* locationString, 
   NSRange range, 
   CLLocationDegrees* pLatitude 
)
{
   // !!!: implement me
   return NO;
}

static BOOL _parseLongitude( 
   NSString* locationString, 
   NSRange range, 
   CLLocationDegrees* pLatitude 
)
{
   // !!!: implement me
   return NO;
}

static BOOL _parseAltitude( 
   NSString* locationString, 
   NSRange range 
)
{
   // !!!: implement me
   return YES;
}

CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
)
{
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;

   NSRange parsedRange = { 0 };
   
   parsedRange = _parseNextWord( locationString, parsedRange );
   const NSRange latitudeStringRange = parsedRange;

   parsedRange = _parseNextWord( locationString, parsedRange );
   const NSRange longitudeStringRange = parsedRange;
   
   NSRange altitudeStringRange = { 0 };
   parsedRange = _parseNextWord( locationString, parsedRange );
   NSRange terminatorStringRange = parsedRange;

   if ( !_isTerminatingSubstring( locationString, terminatorStringRange ) )
   {
      altitudeStringRange = terminatorStringRange;
      terminatorStringRange = _parseNextWord( locationString, parsedRange );
   }
   
   const BOOL validInputLengths = _validWordLengths( 
      latitudeStringRange.length, longitudeStringRange.length
   );
   const BOOL validAltitidue = 
      _parseAltitude( locationString, altitudeStringRange );
   const BOOL validTerminator = 
      _isTerminatingSubstring( locationString, terminatorStringRange );
   
   if ( validInputLengths && validAltitidue && validTerminator )
   {
      CLLocationDegrees latitude = 0.;
      CLLocationDegrees longitude = 0.;
      
      const BOOL validLatitude = 
         _parseLatitude( locationString, latitudeStringRange, &latitude );
      const BOOL validLongitidue = 
         _parseLongitude( locationString, longitudeStringRange, &longitude );
   
      if ( validLatitude && validLongitidue )
      {
         location = CLLocationCoordinate2DMake( latitude, longitude );
      }
   } 
   
   return location;
}
