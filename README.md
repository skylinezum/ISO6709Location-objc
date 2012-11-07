ISO6709Location-objc
====================

Cocoa functions for creating and parsing an ISO 6709 coordinate string.

### Example

    const CLLocationCoordinate2D coordinate =
       ISO6709Location_coordinateFromString( @"+12.3450-098.7650/" );
    
    if ( CLLocationCoordinate2DIsValid( coordinate ) )
    {
       <use coordinate>
    }

### License
BSD Simplified, see http://www.opensource.org/licenses/BSD-3-Clause
