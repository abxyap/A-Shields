#include "ASPControlCenterController.h"
#import <spawn.h>
#import <AppList/AppList.h>
#if THEOS_PACKAGE_SCHEME == rootless
#define PREFERENCE_IDENTIFIER @"/var/jb/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#elif
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#endif
NSMutableDictionary *prefs;

@implementation ASPControlCenterController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"A-Shields" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		NSArray *arr = @[
			@{
				@"name": @"Wi-Fi",
				@"code": @"wifi"
			},
			@{
				@"name": @"Bluetooth",
				@"code": @"bluetooth"
			},
			@{
				@"name": @"AirDrop",
				@"code": @"airdrop"
			},
			@{
				@"name": @"Cellular",
				@"code": @"cellular"
			},
			@{
				@"name": @"Airplane",
				@"code": @"airplane"
			},
			@{
				@"name": @"HotSpot",
				@"code": @"hotspot"
			},
		];

		for( int i = 0; i < [arr count] ; ++i  ) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:arr[i][@"name"] target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:arr[i][@"code"] forKey:@"displayIdentifier"];
			[specifiers addObject:specifier];
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"cc"]) prefs[@"cc"] = [[NSMutableDictionary alloc] init];
	prefs[@"cc"][[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[@"cc"][[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
@end
