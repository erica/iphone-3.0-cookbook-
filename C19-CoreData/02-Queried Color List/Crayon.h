//
//  Crayon.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Crayon :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * color;

@end



