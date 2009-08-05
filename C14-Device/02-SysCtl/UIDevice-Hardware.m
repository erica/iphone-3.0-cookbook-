/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UIDevice-Hardware.h"

@implementation UIDevice (Hardware)

#pragma mark sysctlbyname utils
+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (NSString *) platform
{
	return [self getSysInfoByName:"hw.machine"];
}

#pragma mark sysctl utils
+ (NSUInteger) getSysInfo: (uint) typeSpecifier
{
	size_t size = sizeof(int);
	int results;
	int mib[2] = {CTL_HW, typeSpecifier};
	sysctl(mib, 2, &results, &size, NULL, 0);
	return (NSUInteger) results;
}

+ (NSUInteger) cpuFrequency
{
	return [self getSysInfo:HW_CPU_FREQ];
}

+ (NSUInteger) busFrequency
{
	return [self getSysInfo:HW_BUS_FREQ];
}

+ (NSUInteger) totalMemory
{
	return [self getSysInfo:HW_PHYSMEM];
}

+ (NSUInteger) userMemory
{
	return [self getSysInfo:HW_USERMEM];
}

+ (NSUInteger) maxSocketBufferSize
{
	return [self getSysInfo:KIPC_MAXSOCKBUF];
}
@end
