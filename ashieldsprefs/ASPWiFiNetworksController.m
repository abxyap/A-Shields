#include "ASPWiFiNetworksController.h"
#import <spawn.h>
#import <AppList/AppList.h>
#include <MobileWiFi/MobileWiFi.h>
#include <MobileWiFi/WiFiNetwork.h>
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
NSMutableDictionary *prefs;

@implementation ASPWiFiNetworksController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"If you connect to the selected WiFi network, A-Shields will stop working" forKey:@"footerText"];	
			specifier;
		})];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Trusted WiFi Networks" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];


		WiFiManagerRef manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0);
		CFArrayRef networks = WiFiManagerClientCopyNetworks(manager);
		for( int i = 0; i < CFArrayGetCount(networks) ; ++i  ) {
			WiFiNetworkRef value = (WiFiNetworkRef)CFArrayGetValueAtIndex(networks, i);
			NSString *name = (__bridge NSString *)WiFiNetworkGetSSID(value);
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:name forKey:@"displayIdentifier"];
			[specifiers addObject:specifier];
		}
		CFRelease(manager);

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"wifi"]) prefs[@"wifi"] = [[NSMutableDictionary alloc] init];
	prefs[@"wifi"][[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[@"wifi"][[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
@end
