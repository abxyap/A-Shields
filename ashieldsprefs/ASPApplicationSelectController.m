#include "ASPApplicationSelectController.h"
#import <spawn.h>
#import <AppList/AppList.h>
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
NSMutableDictionary *prefs;

static NSInteger DictionaryTextComparator(id a, id b, void *context) {
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

@implementation ASPApplicationSelectController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"A-Shields Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = [[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"1=1"] onlyVisible:YES titleSortedIdentifiers:nil];
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];
		[displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];
		for (NSString *displayIdentifier in displayIdentifiers)
		{
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];
			UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
			if (icon) [specifier setProperty:icon forKey:@"iconImage"];
			[specifiers addObject:specifier];
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"app"]) prefs[@"app"] = [[NSMutableDictionary alloc] init];
	prefs[@"app"][[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[@"app"][[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
@end
