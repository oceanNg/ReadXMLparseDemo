//
//  XMLParseTableViewCell.m
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import "XMLParseTableViewCell.h"

@implementation XMLParseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithEarthquake:(EathquakeModel *)earthquake{
    self.locationLabel.text = earthquake.location;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];

//    dateFormatter.timeStyle = NSDateFormatterNoStyle;
//    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
//    dateFormatter.timeZone = [NSTimeZone localTimeZone ];
//
    self.dateLabel.text = [dateFormatter stringFromDate:earthquake.date];
    self.magnitudeLabel.text = [NSString stringWithFormat:@"%0.1f", earthquake.magnitude];
    self.magnitudeImage.image = [self  imageForMagnitude:earthquake.magnitude];
    
 
}

// Based on the magnitude of the earthquake, return an image indicating its seismic strength.
- (UIImage *)imageForMagnitude:(CGFloat)magnitude {
    
    if (magnitude >= 5.0) {
        return [UIImage imageNamed:@"5.0.png"];
    }
    if (magnitude >= 4.0) {
        return [UIImage imageNamed:@"4.0.png"];
    }
    if (magnitude >= 3.0) {
        return [UIImage imageNamed:@"3.0.png"];
    }
    if (magnitude >= 0.0) {
        return [UIImage imageNamed:@"2.0.png"];
    }
    return nil;
}


@end
