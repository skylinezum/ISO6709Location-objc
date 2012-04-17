//
//  ISO6709Location.m
//
//  Created by Otto Schnurr on 4/13/12.
//  Copyright 2012
//
//  reference:
//     http://www.w3.org/2005/Incubator/geo/Wiki/LatitudeLongitudeAltitude
//     http://coordinate.codeplex.com
//

#import "ISO6709Location.h"
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSScanner.h>


NSString* ISO6709Location_stringFromCoordinate( 
   CLLocationCoordinate2D coordinate 
)
{
   // eg: +12.3450-098.7650/
   static NSString* const _degreeDegreeFormat = @"%+08.4f%+09.4f/";
   
   NSString* locationString = nil;
   
   if ( CLLocationCoordinate2DIsValid( coordinate ) )
   {
      locationString = [NSString stringWithFormat: _degreeDegreeFormat, 
         coordinate.latitude, coordinate.longitude];
   }

   return locationString;
}


#pragma mark -


static const NSUInteger _integerLocation = 1u;

static NSString* _scanWord( NSScanner* scanner, NSUInteger minimumIntegerLength )
{
   NSCharacterSet* const signCharacters = 
      [NSCharacterSet characterSetWithCharactersInString: @"+-"];
   NSCharacterSet* const digits = [NSCharacterSet decimalDigitCharacterSet];
   NSCharacterSet* const dotCharacter =
      [NSCharacterSet characterSetWithCharactersInString: @"."];
   
   NSString* word = nil;
   NSString* sign = nil;
   NSString* integer = nil;
   NSString* fraction = @"";
   
   const BOOL validScan = 
      [scanner scanCharactersFromSet: signCharacters intoString: &sign] &&
      [scanner scanCharactersFromSet: digits intoString: &integer];
      
   // fraction is optional
   [scanner scanCharactersFromSet: dotCharacter intoString: NULL];
   [scanner scanCharactersFromSet: digits intoString: &fraction];

   if ( validScan && integer.length >= minimumIntegerLength )
   {
      word = [NSString stringWithFormat: @"%@%@.%@", sign, integer, fraction];
   }
   
   return word;
}

static NSInteger _parseInteger( 
   NSString* integerString, NSUInteger startIndex, NSUInteger endIndex 
)
{
   NSCParameterAssert( startIndex <= endIndex );
   NSCParameterAssert( endIndex < integerString.length );
   const NSRange range = NSMakeRange( startIndex, endIndex - startIndex );
   NSString* const substring = [integerString substringWithRange: range];
   return [substring integerValue];
}

static BOOL _parseDegrees( NSString* degreeString, CLLocationDegrees* pDegrees )
{
   static const NSUInteger degreeDotLocation = _integerLocation + 3u;
   static const NSUInteger minuteDotLocation = _integerLocation + 5u;
   static const NSUInteger secondDotLocation = _integerLocation + 7u;

   NSCharacterSet* const digits = [NSCharacterSet decimalDigitCharacterSet];
   NSScanner* const scanner = [NSScanner scannerWithString: degreeString];
   scanner.charactersToBeSkipped = nil;
   scanner.scanLocation = _integerLocation;
   [scanner scanCharactersFromSet: digits intoString: NULL];

   BOOL result = NO;
   CLLocationDegrees degrees = 0.;
   CLLocationDegrees minutes = 0.;
   CLLocationDegrees seconds = 0.;

   if ( scanner.scanLocation <= degreeDotLocation )
   {
      scanner.scanLocation = _integerLocation;
      result = [scanner scanDouble: &degrees];
   }
   else if ( scanner.scanLocation <= minuteDotLocation )
   {
      scanner.scanLocation -= 2u;
      result = [scanner scanDouble: &minutes];
      
      degrees = 
         _parseInteger( degreeString, _integerLocation, scanner.scanLocation );
   }
   else if ( scanner.scanLocation <= secondDotLocation )
   {
      scanner.scanLocation -= 2u;
      result = [scanner scanDouble: &seconds];
      
      const NSUInteger minuteLocation = scanner.scanLocation - 2u;
      minutes = 
         _parseInteger( degreeString, minuteLocation, scanner.scanLocation );
      degrees = 
         _parseInteger( degreeString, _integerLocation, minuteLocation );
   }
   
   if ( result && pDegrees )
   {
      minutes += seconds / 60.f;
      degrees += minutes / 60.f;

      if ( [degreeString hasPrefix: @"-"] )
      {
         degrees = -degrees;
      }
      
      *pDegrees = degrees;
   }

   return result;
}

static NSUInteger _integerLengthForDecimalString( NSString* floatString )
{
   NSUInteger length = 0u;

   if ( floatString.length )
   {
      NSCParameterAssert( 
         [floatString hasPrefix: @"+"] || [floatString hasPrefix: @"-"] 
      );
      
      NSCharacterSet* const digits = [NSCharacterSet decimalDigitCharacterSet];
      NSScanner* const scanner = [NSScanner scannerWithString: floatString];
      scanner.charactersToBeSkipped = nil;
      scanner.scanLocation = _integerLocation;
      [scanner scanCharactersFromSet: digits intoString: NULL];

      length = scanner.scanLocation - _integerLocation;
   }
   
   return length;
}

static BOOL 
   _verifyDegreeFormat( NSString* latitudeString, NSString* longitudeString )
{
   const NSUInteger latitudeIntegerLength =
      _integerLengthForDecimalString( latitudeString );
   const NSUInteger longitudeIntegerLength =
      _integerLengthForDecimalString( longitudeString );

   const BOOL degreeFormat = 2u == latitudeIntegerLength;
   const BOOL minuteFormat = 4u == latitudeIntegerLength;
   const BOOL secondFormat = 6u == latitudeIntegerLength;
   
   const BOOL validLongitude = 
      longitudeIntegerLength == ( latitudeIntegerLength + 1u );
   
   return ( degreeFormat || minuteFormat || secondFormat ) && validLongitude;
}

static CLLocationCoordinate2D 
   _parseCoordinate( NSString* latitudeString, NSString* longitudeString )
{
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;

   if ( _verifyDegreeFormat( latitudeString, longitudeString ) )
   {
      CLLocationDegrees latitude = 0.;
      CLLocationDegrees longitude = 0.;

      if (
         _parseDegrees( latitudeString, &latitude ) &&
         _parseDegrees( longitudeString, &longitude )
      )
      {
         location = CLLocationCoordinate2DMake( latitude, longitude );
      }
   }

   return location;
}

static BOOL _validateAltitude( NSScanner* scanner )
{
   return scanner.isAtEnd || [scanner scanDouble: NULL];
}

CLLocationCoordinate2D ISO6709Location_coordinateFromString( 
   NSString* locationString 
)
{
   static const NSUInteger latitudeMinimumIntegerLength = 2u;
   static const NSUInteger longitudeMinimumIntegerLength = 3u;
   
   CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
   
   if ( [locationString hasSuffix: @"/"] )
   {
      NSString* const content = 
         [locationString substringToIndex: locationString.length - 1u];
      NSScanner* const scanner = [NSScanner scannerWithString: content];
      scanner.charactersToBeSkipped = nil;

      NSString* const latitudeString = 
         _scanWord( scanner, latitudeMinimumIntegerLength );
      NSString* const longitudeString = 
         _scanWord( scanner, longitudeMinimumIntegerLength );

      if ( _validateAltitude( scanner ) )
      {
         location = _parseCoordinate( latitudeString, longitudeString );
      }
   }
   
   return location;
}
