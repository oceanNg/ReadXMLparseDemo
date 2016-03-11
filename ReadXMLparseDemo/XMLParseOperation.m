//
//  XMLParseOperation.m
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import "XMLParseOperation.h"
#import "EathquakeModel.h"
@interface XMLParseOperation  () <NSXMLParserDelegate>


@property (nonatomic) EathquakeModel *currentEarthquakeObject;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign) BOOL accumulatingParsedCharacterData;
@property (assign) BOOL didAbortParsing;

@property (assign) NSUInteger parsedEarthquakesCounter;

@property (assign) BOOL seekDescription;
@property (assign) BOOL seekTime;
@property (assign) BOOL seekLatitude;
@property (assign) BOOL seekLongitude;
@property (assign) BOOL seekMagnitude;
// a stack queue containing  elements as they are being parsed, used to detect malformed XML.

@property (nonatomic, strong) NSMutableArray *elementStack;



@end
@implementation XMLParseOperation

#pragma  mark == setup ==
- (instancetype)init {
    
    NSAssert(NO, @"Invalid use of init; use initWithData to create APLParseOperation");
    return [self init];
}

- (instancetype)initWithData:(NSData *) parseData
{
    self = [super init];
    
    if (self != nil && parseData != nil) {
        _earthquakeData =[ parseData copy];
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone =[NSTimeZone timeZoneForSecondsFromGMT:0];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        // 2015-09-24T16:01:00.283Z
        _currentParseBatch =[@[]mutableCopy];
        _currentParsedCharacterData =[@[]mutableCopy];
        _elementStack =[@[]mutableCopy];
        
        
    }
    return  self;
        
        
}
- (void) addEarthquakeToList:(NSArray *) eathquakeList
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[XMLParseOperation AddEarthQuakesNotificationName] object:self userInfo:@{[XMLParseOperation EarthquakeResultsKey]:eathquakeList}];
    
}

// The main function for this NSOperation, to start the parsing.

-(void)main{
    /*
     It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable because it gives less control over the network, particularly in responding to connection errors.
     */
    
    NSXMLParser * parse = [[ NSXMLParser alloc] initWithData:self.earthquakeData];
    parse.delegate = self;
    [parse parse];
    
    
    /*
     Depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
     */

    if (self.currentParseBatch.count >0) {
        
        [self performSelectorOnMainThread:@selector(addEarthquakeToList:) withObject:self waitUntilDone:NO];
        
    }
    
}

#pragma mark == Parser constants ==
/*
 Limit the number of parsed earthquakes to 50 (a given day may have more than 50 earthquakes around the world, so we only take the first 50).
 */

static const NSUInteger kmaximumNumberOfEarthquakeToparse = 50;

/*
 When an Earthquake object has been fully constructed, it must be passed to the main thread and the table view in RootViewController must be reloaded to display it. It is not efficient to do this for every Earthquake object - the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary depending on the amount of data in the object and other factors, as appropriate.
 */

static const NSUInteger kSizeOfEarthquakeBatch = 10;
// Reduce potential parsing errors by using string constants declared in a single place.

static NSString * const kvalueKey = @"value";

static NSString * const kElementEvent = @"event";

static NSString * const kElementDescription  = @"description";

static NSString * const kElementContent = @"text";

static NSString * const kElementTime= @"time";

static NSString * const kElementLatitude = @"latitude";

static NSString * const kElementLongtitude =@"longtitude";

static NSString * const kElementMag = @"mag";



#pragma mark == NSXMLParserDelegate ==


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    // add the element to the state stack
    
    [_elementStack addObject:elementName];
    
    /*
     If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
     */
    
    if (self.parsedEarthquakesCounter >= kmaximumNumberOfEarthquakeToparse) {
        
         // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors
        _didAbortParsing= YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kElementEvent]) {
        _currentEarthquakeObject = [EathquakeModel shareIntance];
        
    }
    else if ((_seekDescription && [elementName isEqualToString:kElementContent])// <description>..<text>
             || ( _seekTime & [elementName isEqualToString:kvalueKey]) //<time>..<value>
             || (_seekLatitude & [elementName isEqualToString:kvalueKey]) // <latitude> .. <value>
             || (_seekLongitude & [elementName isEqualToString:kvalueKey]) // <longitude> .. <value>
             || (_seekMagnitude & [elementName isEqualToString:kvalueKey]) // <mag> .. <value>
             )
    {
        // For elements: <text> and <value>, the contents are collected in parser:foundCharacters:
        _accumulatingParsedCharacterData =YES;

        // The mutable string needs to be reset to empty.
        _currentParsedCharacterData = [NSMutableString stringWithString:@""];
        
    }
    else if ([elementName isEqualToString:kElementDescription]){
        _seekDescription = YES;
        
    }
    else if ([elementName isEqualToString:kElementTime]){
        _seekTime = YES;
        
    }
    else if ([elementName isEqualToString:kElementLatitude]){
        _seekLatitude = YES;
        
    }
    else if ([elementName isEqualToString:kElementLongtitude]){
        _seekLongitude = YES;
        
    }
    else if ([elementName isEqualToString:kElementMag]){
        _seekMagnitude = YES;
        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // check if the end element matches what's last on the element stack
    if ([elementName isEqualToString: _elementStack.lastObject]) {
        
        [_elementStack removeLastObject];        // they match, remove it
    }
    else {
        // they don't match, we have malformed XML
        NSLog(@"could not find end element of \"%@\"", elementName);

        [_elementStack removeAllObjects];
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kElementEvent]) {
        // end earthquake entry, add it to the array

        [_currentParseBatch addObject:_currentEarthquakeObject];
        _parsedEarthquakesCounter ++;
        
        if (_currentParseBatch.count >= kSizeOfEarthquakeBatch) {
            [self performSelectorOnMainThread:@selector(addEarthquakeToList:) withObject:self waitUntilDone:YES];
            [_currentParseBatch removeAllObjects];
        }
        
    }
    else if ([elementName isEqualToString:kElementContent]){
        // end description, set the location of the earthquake
        if (_seekDescription) {
            
            /*
             The description element contains the following format:
             "14km WNW of Anza, California"
             Extract just the location name
             */
            
            // search the entire string for "of ", and extract that last part of that string
            NSRange rangeSearched = NSMakeRange(0, _currentParsedCharacterData.length);
            
            NSRegularExpression *rangeException = [[NSRegularExpression alloc] initWithPattern:@"of" options:0 error:nil];
            
            NSTextCheckingResult *  checkResult = [rangeException firstMatchInString:_currentParsedCharacterData options:0 range:rangeSearched];
            
            NSInteger starNumber = checkResult.range.location + checkResult.range.length;
            
            NSRange extrange = NSMakeRange(starNumber, _currentParsedCharacterData.length - starNumber);
            
            _currentEarthquakeObject.location = [_currentParsedCharacterData substringWithRange:extrange];
            
            _seekDescription = NO;
            
        }
        
        else if ([elementName isEqualToString:kvalueKey])
        {
            if (_seekTime ) // en earth date time
            {
                _currentEarthquakeObject.date =  [self.dateFormatter dateFromString:_currentParsedCharacterData];
                _seekTime = NO;
            
            }
            else if (self.seekLatitude)
            {
                // end earth latitude
                _currentEarthquakeObject.latitude = _currentParsedCharacterData.doubleValue;
                _seekLatitude = NO;
            }
            else if (_seekLongitude)
            {
                // end earthquake longitude
                _currentEarthquakeObject.longitude  = _currentParsedCharacterData.doubleValue;
                _seekLongitude = NO;

            }
            else if (_seekMagnitude)
            {
                // end earth mag
                _currentEarthquakeObject.magnitude = _currentParsedCharacterData.floatValue;
                _seekMagnitude = NO;
            }
            
        }

    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    _accumulatingParsedCharacterData = NO;

}


/**
 This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to accumulate character data until the end of the element is reached.
 */

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (self.accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

/**An error occurred while parsing the earthquake data: post the error as an NSNotification to our app delegate.
*/

- (void)handleEarthquakesError:(NSError *)parseError {
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:[XMLParseOperation EarthquakeErrorNotificationName]
                                                        object:self
                                                      userInfo:@{[XMLParseOperation EarthquakeErrorKey ]: parseError}];
}

/**
 An error occurred while parsing the earthquake data, pass the error to the main thread for handling.
 (Note: don't report an error if we aborted the parse due to a max limit of earthquakes.)
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    if (parseError.code != NSXMLParserDelegateAbortedParseError && !self.didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleEarthquakesError:) withObject:parseError waitUntilDone:NO];
    }
}


// NSNotification name for sending earthquake data back to the app delegate

+ (NSString *)AddEarthQuakesNotificationName{
    
    return @"AddEarthquakesNotif";

}

// NSNotification userInfo key for obtaining the earthquake data

+ (NSString *)EarthquakeResultsKey{
    return @"EarthquakeResultsKey";

}

// NSNotification name for reporting errors
+ (NSString *)EarthquakeErrorNotificationName{
    return @"EarthquakeErrorNotif";

}

// NSNotification userInfo key for obtaining the error message
+ (NSString *) EarthquakeErrorKey{
    return @"EarthquakesMsgErrorKey";

}
@end
