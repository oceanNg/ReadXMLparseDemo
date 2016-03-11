//
//  EathquakeModel.h
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EathquakeModel;

@interface EathquakeModel : NSObject

// Magnitude of the earthquake on the Richter scale.
@property (nonatomic) float magnitude;
// Name of the location of the earthquake.
@property (nonatomic, strong) NSString *location;
// Date and time at which the earthquake occurred.
@property (nonatomic, strong) NSDate *date;
// Latitude and longitude of the earthquake.
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+(EathquakeModel *) shareIntance;

@end
