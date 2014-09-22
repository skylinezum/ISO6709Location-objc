//
//  ISO6709Location_tests.m
//
//  Copyright (c) 2012, TechSmith Corporation
//  All rights reserved.
//
//  BSD Simplified License
//     file: ./LICENSE.txt
//     http://www.opensource.org/licenses/BSD-3-Clause
//

#import "ISO6709Location.h"
#import <XCTest/XCTest.h>


static BOOL _coordinatesAreEqual( CLLocationCoordinate2D a, CLLocationCoordinate2D b )
{
   return a.latitude == b.latitude && a.longitude == b.longitude;
}


#pragma mark -


@interface ISO6709Location_tests : XCTestCase
@end


@implementation ISO6709Location_tests

#pragma mark String Generation Tests
- (void)test_invalidCoordinate_generatesNilString
{
   NSString* const locationString = ISO6709Location_stringFromCoordinate( kCLLocationCoordinate2DInvalid );
   XCTAssertNil( locationString);
}

- (void)test_zeroCoordinate_generatesZeroString
{
   const CLLocationCoordinate2D coordinate = { 0 };
   NSString* const locationString = ISO6709Location_stringFromCoordinate( coordinate );
   XCTAssertEqualObjects( locationString, @"+00.0000+000.0000/");
}

- (void)test_typicalCoordinate_generatesTypicalString
{
   const CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake( 12.345, -98.765 );
   NSString* const locationString = ISO6709Location_stringFromCoordinate( coordinate );
   XCTAssertEqualObjects( locationString, @"+12.3450-098.7650/");
}


#pragma mark String Parsing Tests
- (void)test_nilString_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( nil );
   XCTAssertFalse( CLLocationCoordinate2DIsValid( coordinate ));
}

- (void)test_zeroString_parsesToZeroCoordinate
{
   const CLLocationCoordinate2D parsedCoordinate = ISO6709Location_coordinateFromString( @"+00.0000+000.0000/" );
   const CLLocationCoordinate2D expectedCoordinate = { 0 };
   XCTAssertTrue( _coordinatesAreEqual( parsedCoordinate, expectedCoordinate ));
}

- (void)test_stringWithoutSlash_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+00.0000+000.0000" );
   XCTAssertFalse( CLLocationCoordinate2DIsValid( coordinate ));
}

- (void)test_typicalString_parsesToTypicalCoordinate
{
   const CLLocationCoordinate2D parsedCoordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650/" );
   const CLLocationCoordinate2D expectedCoordinate = CLLocationCoordinate2DMake( 12.345, -98.765 );
   XCTAssertTrue( _coordinatesAreEqual( parsedCoordinate, expectedCoordinate ));
}

- (void)test_stringWithoutFractions_parses
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.-098./" );
   XCTAssertTrue( CLLocationCoordinate2DIsValid( coordinate ));
}

- (void)test_stringWithValidAltitude_parses
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650+123.456/" );
   XCTAssertTrue( CLLocationCoordinate2DIsValid( coordinate ));
}

- (void)test_stringWithInvalidAltitude_doesNotParse
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12.3450-098.7650+up.high/" );
   XCTAssertFalse( CLLocationCoordinate2DIsValid( coordinate ));
}

- (void)test_stringWithoutDots_parses
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( @"+12-098/" );
   XCTAssertTrue( CLLocationCoordinate2DIsValid( coordinate ));
}

@end
