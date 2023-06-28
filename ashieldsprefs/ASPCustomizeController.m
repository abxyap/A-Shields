#include "ASPCustomizeController.h"
#import <spawn.h>
#import <AppList/AppList.h>
#import <libcolorpicker.h>

#if THEOS_PACKAGE_SCHEME == rootless
#define PREFERENCE_IDENTIFIER @"/var/jb/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#elif
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#endif
NSMutableDictionary *prefs;

extern CFPropertyListRef MGCopyAnswer(CFStringRef property);

@implementation ASPCustomizeController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"A-Shields Customize" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Request Message" target:self	set:@selector(setString:forSpecifier:) get:@selector(getString:) detail:nil cell:PSEditTextCell edit:nil];
			[specifier.properties setValue:@"lockedMessage" forKey:@"displayIdentifier"];
			((PSTextFieldSpecifier *)specifier).placeholder = @"This device is protected by A-Shields...";
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Failed Message" target:self	set:@selector(setString:forSpecifier:) get:@selector(getString:) detail:nil cell:PSEditTextCell edit:nil];
			[specifier.properties setValue:@"authFailMessage" forKey:@"displayIdentifier"];
			((PSTextFieldSpecifier *)specifier).placeholder = @"Authentication failed. Please try again...";
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Primary Fingerprint Glyph Color" target:nil set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
			[specifier.properties setValue:@"Primary Fingerprint Glyph Color" forKey:@"label"];
			[specifier.properties setValue:NSClassFromString(@"PFSimpleLiteColorCell") forKey:@"cellClass"];
			[specifier.properties setValue:@YES forKey:@"isContoller"];
			[specifier.properties setValue:@{
				@"defaults": @"com.rpgfarm.ashieldsprefs",
				@"key": @"primaryColor",
				@"fallback": @"#FF0000",
				@"alpha": @(0)
			} forKey:@"libcolorpicker"];
			specifier->action = @selector(cellAction);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Secondary Fingerprint Glyph Color" target:nil set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
			[specifier.properties setValue:@"Secondary Fingerprint Glyph Color" forKey:@"label"];
			[specifier.properties setValue:NSClassFromString(@"PFSimpleLiteColorCell") forKey:@"cellClass"];
			[specifier.properties setValue:@YES forKey:@"isContoller"];
			[specifier.properties setValue:@{
				@"defaults": @"com.rpgfarm.ashieldsprefs",
				@"key": @"secondaryColor",
				@"fallback": @"#000000",
				@"alpha": @(0)
			} forKey:@"libcolorpicker"];
			specifier->action = @selector(cellAction);
			specifier;
		})];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Extra" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Reset Customize" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(reset);
			specifier;
		})];

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setString:(NSString *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"customize"]) prefs[@"customize"] = [[NSMutableDictionary alloc] init];
	prefs[@"customize"][[specifier propertyForKey:@"displayIdentifier"]] = value;
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSString *)getString:(PSSpecifier *)specifier {
	return prefs[@"customize"][[specifier propertyForKey:@"displayIdentifier"]];
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"customize"]) prefs[@"customize"] = [[NSMutableDictionary alloc] init];
	prefs[@"customize"][[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[@"customize"][[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
- (void)reset {
	prefs[@"customize"] = nil;
	prefs[@"primaryColor"] = nil;
	prefs[@"secondaryColor"] = nil;
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
@end
