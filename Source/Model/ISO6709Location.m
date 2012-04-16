//
//  ISO6709Location.m
//
//  Created by Otto Schnurr on 4/13/12.
//  Copyright 2012
//
//  reference: http://coordinate.codeplex.com
//

#import "ISO6709Location.h"
#import <Foundation/NSCharacterSet.h>


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

// Returns zero length on failure.
static NSRange _scanNextWord( NSString* locationString, NSRange previousWord )
{
   NSRange word = NSMakeRange( previousWord.location + previousWord.length, 0u );

   if ( word.location + word.length < locationString.length )
   {
      NSCharacterSet* const delimiters = 
         [NSCharacterSet characterSetWithCharactersInString: @"+-/"];
      const unichar firstCharacter = 
         [locationString characterAtIndex: word.location + word.length];
      
      // Each valid word starts with a delimiter.
      if ( [delimiters characterIsMember: firstCharacter] )
      {
         word.length++;
      
         while ( word.location + word.length < locationString.length )
         {
            const unichar nextCharacter = 
               [locationString characterAtIndex: word.location + word.length++];
            
            if ( [delimiters characterIsMember: nextCharacter] )
            {
               break;
            }
         }
      }
   }

   return word;
}

static NSString* _safeSubstring( NSString* locationString, NSRange range )
{
   NSString* substring = nil;

   if ( range.location + range.length <= locationString.length )
   {
      substring = [locationString substringWithRange: range];
   }
   
   return substring;
}

static BOOL _isTerminatingSubstring( NSString* locationString, NSRange range )
{
   NSString* const substring = _safeSubstring( locationString, range );
   return [substring isEqualToString: @"/"];
}

static BOOL _validWordLengths( 
   NSUInteger latitudeWordLength,
   NSUInteger longitudeWordLength
)
{
   const BOOL degreeFormat = 8u == latitudeWordLength;
   const BOOL minuteFormat = 10u == latitudeWordLength;
   const BOOL secondFormat = 12u == latitudeWordLength;
   
   const BOOL validLongitude = 
      longitudeWordLength == ( latitudeWordLength + 1u );

   return ( degreeFormat || minuteFormat || secondFormat ) && validLongitude;
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
   const NSRange startingRange = { 0 };
   const NSRange latitudeStringRange = 
      _scanNextWord( locationString, startingRange );

   const NSRange longitudeStringRange = 
      _scanNextWord( locationString, latitudeStringRange );
   
   NSRange altitudeStringRange = { 0 };
   NSRange terminatorStringRange = 
      _scanNextWord( locationString, longitudeStringRange );

   if ( !_isTerminatingSubstring( locationString, terminatorStringRange ) )
   {
      altitudeStringRange = terminatorStringRange;
      terminatorStringRange = 
         _scanNextWord( locationString, terminatorStringRange );
   }
   
   const BOOL validWordLengths = _validWordLengths( 
      latitudeStringRange.length, longitudeStringRange.length
   );
   const BOOL validAltitude = 
      _parseAltitude( locationString, altitudeStringRange );
   const BOOL validTerminator = 
      _isTerminatingSubstring( locationString, terminatorStringRange );
   
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
   
   if ( validWordLengths && validAltitude && validTerminator )
   {
      CLLocationDegrees latitude = 0.;
      CLLocationDegrees longitude = 0.;
      
      const BOOL validLatitude = 
         _parseLatitude( locationString, latitudeStringRange, &latitude );
      const BOOL validLongitude = 
         _parseLongitude( locationString, longitudeStringRange, &longitude );
   
      if ( validLatitude && validLongitude )
      {
         location = CLLocationCoordinate2DMake( latitude, longitude );
      }
   } 
   
   return location;
}
