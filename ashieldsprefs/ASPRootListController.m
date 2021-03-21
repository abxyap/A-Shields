#include "ASPRootListController.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <spawn.h>
#import "ASPPINController.h"
#import "ASPApplicationSelectController.h"
#import "ASPWiFiNetworksController.h"
#import "ASPControlCenterController.h"
#import "ASPCustomizeController.h"

#import "../ASViewController.h"

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
NSMutableDictionary *prefs;

@interface PSSpecifier (AShields)
@property (nonatomic) Class editPaneClass;
@end
@interface PSViewController (Private)
-(void)popRecursivelyToRootController;
@end
@interface SpringBoard
-(void)verifyTouchID:(NSString *)alertTitle reply:(void (^)(BOOL))callback;
@end
@interface LAContext (AShields)
-(void)setOptionAuthenticationTitle:(id)arg1;
@end
@interface UIApplication (Private)
- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL success))completion;
@end
@interface DevicePINPane : NSObject
@end

@implementation ASPRootListController : PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[[NSNotificationCenter defaultCenter] addObserverForName:@"reloadSettingPage" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
	    [self reloadSpecifiers];
		}];
		[self getPreference];

		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Credits" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"@BawAppie (Developer)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"BawAppie"];
	    specifier->action = @selector(openCredits:);
			specifier;
		})];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"A-Shields Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enable" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Remember unlock session" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"session" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Show lock icon badge" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"badge" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Disable Haptic when succeed." target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"disablehaptic" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Emulate LAPolicy." target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"emulateLAPolicy" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Customize" target:nil set:nil get:nil detail:[ASPCustomizeController class] cell:PSLinkListCell edit:nil]];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Trusted WiFi Networks" target:nil set:nil get:nil detail:[ASPWiFiNetworksController class] cell:PSLinkListCell edit:nil]];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Passcode Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		if(!prefs[@"passcode"]) [specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Setup Passcode" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier.buttonAction = @selector(showPINSheet:);
			specifier.editPaneClass = [DevicePINPane class];
			[specifier setProperty:@(0) forKey:@"mode"];
			[specifier.properties setValue:@"DevicePINPane" forKey:@"pane"];
			[specifier.properties setValue:@"ASPPINController" forKey:@"customControllerClass"];
			[specifier.properties setValue:@"PSButtonCell" forKey:@"cell"];
			specifier;
		})];
		else {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Change Passcode" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				specifier.buttonAction = @selector(showPINSheet:);
				specifier.editPaneClass = [DevicePINPane class];
				[specifier setProperty:@(2) forKey:@"mode"];
				[specifier.properties setValue:@"DevicePINPane" forKey:@"pane"];
				[specifier.properties setValue:@"ASPPINController" forKey:@"customControllerClass"];
				[specifier.properties setValue:@"PSButtonCell" forKey:@"cell"];
				specifier;
			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Remove Passcode" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				specifier.buttonAction = @selector(showPINSheet:);
				specifier.editPaneClass = [DevicePINPane class];
				[specifier setProperty:@(1) forKey:@"mode"];
				[specifier.properties setValue:@"DevicePINPane" forKey:@"pane"];
				[specifier.properties setValue:@"ASPPINController" forKey:@"customControllerClass"];
				[specifier.properties setValue:@"PSButtonCell" forKey:@"cell"];
				specifier;
			})];
		}

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Protected items" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Application" target:nil set:nil get:nil detail:[ASPApplicationSelectController class] cell:PSLinkListCell edit:nil]];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Control Center" target:nil set:nil get:nil detail:[ASPControlCenterController class] cell:PSLinkListCell edit:nil]];

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

// - (void)viewDidLoad {
// 	[super viewDidLoad];
// 	[self verifyTouchID];
// }
// -(void)verifyTouchID {
//
// 	[[ASViewController sharedInstance] verifyTouchID:@"A-Shields Preferences" reply:^(BOOL success){
// 		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
// 			if(!success) [self.rootController popRecursivelyToRootController];
// 		});
// 	}];


  // LAContext *context = [[LAContext alloc] init];
  // [context setOptionAuthenticationTitle:@"Check device owner"];
  // NSError *error;
  // if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]){
  //   [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"This device is protected by A-Shields\nEnter your Touch ID or Passcode to continue." reply:^(BOOL success, NSError *error) {
	//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	//       if(!success) [self.rootController popRecursivelyToRootController];
	// 		});
  //   }];
  // } else {
	// 	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	// 		[self.rootController popRecursivelyToRootController];
	// 	});
	// }
// }


-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs[[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}

-(void)openCredits:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	if([value isEqualToString:@"BawAppie"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/BawAppie"] options:@{} completionHandler:nil];
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
- (void)Respring {
	pid_t pid;
  const char* args[] = {"killall", "backboardd", NULL};
  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
