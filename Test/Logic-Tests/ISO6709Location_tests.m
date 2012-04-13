//
//  ISO6709Location_tests.m
//
//  Created by Otto Schnurr on 4/13/2012.
//  Copyright 2012
//

#import "ISO6709Location.h"
#import <SenTestingKit/SenTestingKit.h>


@interface ISO6709Location_tests : SenTestCase
@end


#pragma mark -


@implementation ISO6709Location_tests

#pragma mark Factory Tests
- (void)test_invalidCoordinate_isNilString
{
   NSString* const locationString = ISO6709Location_stringFromCoordinate( kCLLocationCoordinate2DInvalid );
   STAssertNil( locationString, nil );
}

- (void)test_nilString_isInvalidCoordinate
{
   const CLLocationCoordinate2D coordinate = ISO6709Location_coordinateFromString( nil );
   STAssertFalse( CLLocationCoordinate2DIsValid( coordinate ), nil );
}

- (void)test_zeroCoordinate_hasExpectedString
{
   const CLLocationCoordinate2D coordinate = { 0 };
   NSString* const locationString = ISO6709Location_stringFromCoordinate( coordinate );
   STAssertEqualObjects( locationString, @"+00.0000+000.0000/", nil );
}

@end
