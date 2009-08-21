/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABContact : NSObject
{
	ABRecordRef record;
}

// Convenience allocation methods
+ (id) contact;
+ (id) contactWithRecord: (ABRecordRef) record;
+ (id) contactWithRecordID: (ABRecordID) recordID;

// Class utility methods
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty;
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty;
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty;
+ (NSString *) propertyString: (ABPropertyID) aProperty;
+ (BOOL) propertyIsMultivalue: (ABPropertyID) aProperty;
+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;
+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;

// Creating proper dictionaries
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code;
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName;

// Instance utility methods
- (BOOL) removeSelfFromAddressBook: (NSError **) error;

@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (nonatomic, assign) NSString *firstname;
@property (nonatomic, assign) NSString *lastname;
@property (nonatomic, assign) NSString *middlename;
@property (nonatomic, assign) NSString *prefix;
@property (nonatomic, assign) NSString *suffix;
@property (nonatomic, assign) NSString *nickname;
@property (nonatomic, assign) NSString *firstnamephonetic;
@property (nonatomic, assign) NSString *lastnamephonetic;
@property (nonatomic, assign) NSString *middlenamephonetic;
@property (nonatomic, assign) NSString *organization;
@property (nonatomic, assign) NSString *jobtitle;
@property (nonatomic, assign) NSString *department;
@property (nonatomic, assign) NSString *note;

@property (nonatomic, readonly) NSString *contactName; // my friendly utility
@property (nonatomic, readonly) NSString *compositeName; // via AB

#pragma mark DATE
@property (nonatomic, assign) NSDate *birthday;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *modificationDate;

#pragma mark MULTIVALUE
// Each of these produces an array of NSStrings
@property (nonatomic, readonly) NSArray *emailArray;
@property (nonatomic, readonly) NSArray *emailLabels;
@property (nonatomic, readonly) NSArray *phoneArray;
@property (nonatomic, readonly) NSArray *phoneLabels;
@property (nonatomic, readonly) NSArray *relatedNameArray;
@property (nonatomic, readonly) NSArray *relatedNameLabels;
@property (nonatomic, readonly) NSArray *urlArray;
@property (nonatomic, readonly) NSArray *urlLabels;
@property (nonatomic, readonly) NSArray *dateArray;
@property (nonatomic, readonly) NSArray *dateLabels;
@property (nonatomic, readonly) NSArray *addressArray;
@property (nonatomic, readonly) NSArray *addressLabels;
@property (nonatomic, readonly) NSArray *smsArray;
@property (nonatomic, readonly) NSArray *smsLabels;

@property (nonatomic, readonly) NSString *emailaddresses;
@property (nonatomic, readonly) NSString *phonenumbers;
@property (nonatomic, readonly) NSString *urls;

// Each of these uses an array of dictionaries
@property (nonatomic, assign) NSArray *emailDictionaries;
@property (nonatomic, assign) NSArray *phoneDictionaries;
@property (nonatomic, assign) NSArray *relatedNameDictionaries;
@property (nonatomic, assign) NSArray *urlDictionaries;
@property (nonatomic, assign) NSArray *dateDictionaries;
@property (nonatomic, assign) NSArray *addressDictionaries;
@property (nonatomic, assign) NSArray *smsDictionaries;

#pragma mark IMAGES
@property (nonatomic, assign) UIImage *image;

@end