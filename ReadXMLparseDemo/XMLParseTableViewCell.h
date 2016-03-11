//
//  XMLParseTableViewCell.h
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EathquakeModel.h"

@interface XMLParseTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *magnitudeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *magnitudeImage;


- (void)configureWithEarthquake:(EathquakeModel *)earthquake;


@end
