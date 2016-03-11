//
//  EathquakeModel.m
//  ReadXMLparseDemo
//
//  Created by duongnguyen on 3/11/16.
//  Copyright © 2016 duongnguyen. All rights reserved.
//

#import "EathquakeModel.h"
static EathquakeModel * shareIntance;

@implementation EathquakeModel

+(EathquakeModel *)shareIntance{
    if (! shareIntance) {
        shareIntance = [[EathquakeModel alloc] init];
        
    }
    return  shareIntance;
    
}
@end
