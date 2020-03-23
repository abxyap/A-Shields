#include "ASPCustomizeController.h"
#import <spawn.h>
#import <AppList/AppList.h>
#import <libcolorpicker.h>

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
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

// (A)ppie (E)ncryption (S)tandard 257
NSString *AES257Decrypt(NSString *str) {
  NSMutableString *newString = [[NSMutableString alloc] init];
  int i = 0;
  while (i < [str length]) {
    NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
    int value = 0;
    sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
    [newString appendFormat:@"%c", (char)value];
    i+=2;
  }
  return newString;
}

-(void)viewDidLoad {
	[super viewDidLoad];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	NSString *udid = (__bridge NSString *)MGCopyAnswer(CFSTR("UniqueDeviceID"));
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@?bundleID=ashields_customize&udid=%@", AES257Decrypt([NSString stringWithFormat:@"692e726570%@e636f2e6b72", @"6f2"]), AES257Decrypt(@"6c6963656e7365"), udid]]];
	[request setTimeoutInterval:3.0];
	NSHTTPURLResponse *responseCode = nil;
	NSError *error;
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
	#pragma clang diagnostic pop
	NSString *res = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
	if(![res isEqualToString:@"1"]) {
			[self.rootController popRecursivelyToRootController];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://i.repo.co.kr/checkout?item=ashields_customize&udid=%@", udid]] options:@{} completionHandler:nil];
	}
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
