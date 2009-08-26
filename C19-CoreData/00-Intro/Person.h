//
//  Person.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/25/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Department;

@interface Person :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Department * department;

@end



