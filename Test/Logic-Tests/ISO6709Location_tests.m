//
//  ISO6709Location_tests.m
//
//  Created by Otto Schnurr on 4/13/2012.
//  Copyright 2012
//

#import "ISO6709Location.h"
#import <SenTestingKit/SenTestingKit.h>


static BOOL _coordinatesAreEqual( CLLocationCoordinate2D a, CLLocationCoordinate2D b )
{
   return a.latitude == b.latitude && a.longitude == b.longitude;
}


#pragma mark -


@interface ISO6709Location_tests : SenTestCase
@end


@implementation ISO6709Location_tests

#pragma mark String Generation Tests
- (void)test_invalidCoordinate_generatesNilString
{
   NSString* const locationString = ISO6709Location_stringFromCoordinate( kCLLocationCoordinate2DInvalid );
   STAssertNil( locationString, nil );
}

- (void)test_zeroCoordinate_generatesZeroString
{
   const CLLocationCoordinate2D coordinate = { 0 };
   NSString* const locationString = ISO6709Location_stringFromCoordinate( coordinate );
   STAssertEqualObjects( locationString, @"+00.0000+000.0000/", nil );
}

- (void)test_typicalCoordinate_generatesTypicalString
{
   const CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake( 12.345, -98.765 );
   NSString* const locationString = ISO6709Location_stringFromCoordinate( coordinate );
   STAssertEqualObjects( locationString, @"+12.3450-098.7650/", nil );
}


#pragma mark String Parsing Tests
- (void)test_nilString_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( nil );
   STAssertFalse( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

- (void)test_zeroString_parsesToZeroCoordinate
{
   const CLLocationCoordinate2D parsedCoordinate = ISO6709Location_coordinateFromString( @"+00.0000+000.0000/" );
   const CLLocationCoordinate2D expectedCoordinate = { 0 };
   STAssertTrue( _coordinatesAreEqual( parsedCoordinate, expectedCoordinate ), nil );
}

- (void)test_stringWithoutSlash_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+00.0000+000.0000" );
   STAssertFalse( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

- (void)test_typicalString_parsesToTypicalCoordinate
{
   const CLLocationCoordinate2D parsedCoordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650/" );
   const CLLocationCoordinate2D expectedCoordinate = CLLocationCoordinate2DMake( 12.345, -98.765 );
   STAssertTrue( _coordinatesAreEqual( parsedCoordinate, expectedCoordinate ), nil );
}

- (void)test_stringWithoutFractions_parses
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.-098./" );
   STAssertTrue( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

- (void)test_stringWithValidAltitude_parses
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650+123.456/" );
   STAssertTrue( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

- (void)test_stringWithInvalidAltitude_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650+up.high/" );
   STAssertFalse( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

@end
