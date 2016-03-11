//
//  XMLParseOperation.h
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSOperation.h>

@interface XMLParseOperation : NSOperation
@property (copy, readonly) NSData *earthquakeData;


- (instancetype)initWithData:(NSData *) parseData NS_DESIGNATED_INITIALIZER;
// NSNotification name for sending earthquake data back to the app delegate

+ (NSString *)AddEarthQuakesNotificationName;

// NSNotification userInfo key for obtaining the earthquake data

+ (NSString *)EarthquakeResultsKey;

 // NSNotification name for reporting errors
+ (NSString *)EarthquakeErrorNotificationName;

// NSNotification userInfo key for obtaining the error message
+ (NSString *) EarthquakeErrorKey;

@end
