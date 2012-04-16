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
#import <Foundation/NSIndexSet.h>
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


static NSIndexSet* _findDelimiters( NSString* locationString )
{
   NSMutableIndexSet* indices = nil;
   const NSRange stringRange = NSMakeRange( 0u, locationString.length );
   
   if ( stringRange.length )
   {
      const NSUInteger bufferLength = stringRange.length * sizeof( unichar );
      NSMutableData* data = [NSMutableData dataWithLength: bufferLength];
      unichar* characters = data.mutableBytes;
      
      if ( characters )
      {
         indices = [NSMutableIndexSet indexSet];
         [locationString getCharacters: characters range: stringRange];
         
         NSCharacterSet* const delimiters = 
            [NSCharacterSet characterSetWithCharactersInString: @"+-/"];
         
         for ( NSUInteger index = 0u; index < stringRange.length; ++index )
         {
            if ( [delimiters characterIsMember: characters[index]] )
            {
               [indices addIndex: index];
            }
         }
      }
   }
    
   NSCParameterAssert( 
      !indices.count || indices.lastIndex < locationString.length 
   );
   return indices;
}

static BOOL _validateDelimiters( 
   NSUInteger stringLength, NSIndexSet* indices 
)
{
   BOOL result = NO;

   const BOOL enoughDelimiters = 2u <= indices.count;
   const BOOL tooManyDelimiters = 4u < indices.count;

   if ( stringLength && enoughDelimiters && !tooManyDelimiters )
   {
      const BOOL startsWithDelimiter = 0u == indices.firstIndex;
      const BOOL endsWithDelimiter = 
         ( indices.lastIndex + 1u ) == stringLength;
      
      result = startsWithDelimiter && endsWithDelimiter;
   }

   return result;
}

static NSArray* _scanSubstrings( NSString* locationString )
{
   NSMutableArray* words = nil;
   NSIndexSet* const wordLocations = _findDelimiters( locationString );

   if ( _validateDelimiters( locationString.length, wordLocations ) )
   {
      words = [NSMutableArray array];
      NSUInteger index = wordLocations.firstIndex;
      NSUInteger nextIndex = [wordLocations indexGreaterThanIndex: index];
      
      while ( nextIndex < locationString.length )
      {
         const NSRange range = NSMakeRange( index, nextIndex - index );
         [words addObject: [locationString substringWithRange: range]];
         index = nextIndex;
         nextIndex = [wordLocations indexGreaterThanIndex: index];
      }
   }

   return words;
}

#if 0
static BOOL _validateDegreeFormat( 
   NSUInteger latitudeDecimalLength, NSUInteger longitudeDecimalLength 
)
{
   const BOOL degreeFormat = 2u == latitudeDecimalLength;
   const BOOL minuteFormat = 4u == latitudeDecimalLength;
   const BOOL secondFormat = 6u == latitudeDecimalLength;
   
   const BOOL validLongitude = 
      longitudeDecimalLength == ( latitudeDecimalLength + 1u );

   return ( degreeFormat || minuteFormat || secondFormat ) && validLongitude;
}

static NSString* _decimalFromString( NSString* numberString )
{
   NSScanner* const scanner = [NSScanner scannerWithString: numberString];
   scanner.charactersToBeSkipped = nil;

   NSCharacterSet* const dotCharacter = 
      [NSCharacterSet characterSetWithCharactersInString: @"."];

   NSString* decimalString = nil;
   [scanner scanUpToCharactersFromSet: dotCharacter intoString: &decimalString];
   return decimalString;
}
#endif // 0

static CLLocationCoordinate2D 
   _parseCoordinate( NSString* latitudeString, NSString* longitudeString )
{
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;

   // !!!: implement me
   return location;
}

static BOOL _parseAltitude( NSString* altitudeString )
{
   NSScanner* const scanner = [NSScanner scannerWithString: altitudeString];
   scanner.charactersToBeSkipped = nil;
   return [scanner scanDouble: NULL];
}

static NSString* _substringAtIndex( NSArray* substrings, NSUInteger index )
{
   NSString* substring = nil;
   
   if ( index < substrings.count )
   {
      substring = [substrings objectAtIndex: index];
   }
   
   return substring;
}

CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
)
{
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
   
   if ( [locationString hasSuffix: @"/"] )
   {
      NSArray* const substrings = _scanSubstrings( locationString );
      NSString* const latitudeString = _substringAtIndex( substrings, 0u );
      NSString* const longitudeString = _substringAtIndex( substrings, 1u );
      NSString* const altitudeString = _substringAtIndex( substrings, 2u );
      
      if ( _parseAltitude( altitudeString ) )
      {
         location = _parseCoordinate( latitudeString, longitudeString );
      }
   }
   
   return location;
}
