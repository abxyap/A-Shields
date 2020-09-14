#import "ASViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "./headers/SpringBoard.h"
#include <objc/runtime.h>
#include <dlfcn.h>
#include <AudioToolbox/AudioToolbox.h>
#import "./headers/SpringBoard.h"
#import "./headers/ControlCenter.h"
#import "./ASScanner.h"
#import "./ASViewController.h"
#import "./ASWindow.h"
#import <libcolorpicker.h>

PKGlyphView *fingerglyph;
NSMutableDictionary *prefs;
NSString *typeCache;

NSString *getType() {
	if(!typeCache) {
		@try {
			NSString *type = @"Biometry Authentication";
			LAContext *context = [[LAContext alloc] init];
			[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
			if(context.biometryType == 1) type = @"Touch ID";
			if(context.biometryType == 2) type = @"Face ID";
			[context dealloc];
			typeCache = [type copy];
			return type;
		} @catch(NSException *ex) {
			return @"Biometry Authentication";
		}
	} else return typeCache;
}


@interface ASAlertController : UIAlertController
@end

@implementation ASAlertController

-(BOOL)_canShowWhileLocked {
	return true;
}

@end


@implementation ASViewController

-(BOOL)_canShowWhileLocked {
	return true;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedSelf = nil;
  dispatch_once(&p, ^{
    _sharedSelf = [[self alloc] init];
  });
  return _sharedSelf;
}

void loadPrefs() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"];
}

-(id)init {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
	[self.view setBackgroundColor:[UIColor clearColor]];
	dlopen("/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/SpringBoardUIServices", RTLD_NOW);
	dlopen("/System/Library/PrivateFrameworks/PassKitUIFoundation.framework/PassKitUIFoundation", RTLD_NOW);
	return self;
}

-(void)closeAlert {
	if(self.alert != nil) [self.alert dismissViewControllerAnimated:YES completion:nil];
}

-(void)verifyTouchID:(NSString *)alertTitle reply:(void (^)(BOOL))callback {
	@try {
		NSError *authError = nil;
		[[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError];
		if(authError != nil) {
			[[ASWindow sharedInstance] setTouchInjection:true];
				NSString *msg;
			if([authError code] == -8) msg = [NSString stringWithFormat:@"%@ is locked because there were too many failed attempts.\nA-Shields will deny all authentication until %@ is available again.", getType(), getType()];
			else if([authError code] == -7) msg = [NSString stringWithFormat:@"%@ is not available.\nGo to Settings to activate %@.\nA-Shields will not work until you activate %@.", getType(), getType(), getType()];
			else msg = @"This device does not support biometric authentication.\nPlease upgrade to iPhone 5s or later to use A-Shields.";
			self.alert = [ASAlertController alertControllerWithTitle:alertTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
			[self.alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				[[ASWindow sharedInstance] setTouchInjection:false];
				callback([authError code] != -8);
			}]];
			return [self presentViewController:self.alert animated:YES completion:nil];
		}
		if(![prefs[@"enable"] isEqual:@1]) return callback(true);
		if(prefs[@"wifi"] && [prefs[@"wifi"][[[objc_getClass("SBWiFiManager") sharedInstance] currentNetworkName]] isEqual:@1]) return callback(true);
		if(self.session) return callback(true);
		[[ASScanner sharedInstance] setCallback:^(BOOL success) {
			if(success) {
			if([prefs[@"session"] isEqual:@1]) self.session = true;
			[self.alert dismissViewControllerAnimated:YES completion:nil];
				[[ASWindow sharedInstance] setTouchInjection:false];
				callback(true);
				if(![prefs[@"disablehaptic"] isEqual:@1]) AudioServicesPlaySystemSound(1519);
			} else {
				[self.alert setMessage:prefs[@"customize"][@"authFailMessage"] ?: @"Authentication failed. Please try again."];
				if(![prefs[@"disablehaptic"] isEqual:@1]) AudioServicesPlaySystemSound(1521);
				// if([getType() isEqualToString:@"Face ID"]) {
				// 	[self.alert addAction:[UIAlertAction actionWithTitle:@"Retry Face ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				//		// TODO: Retry Face ID
				// 	}]];
				// }
			}
		}];
		[[ASScanner sharedInstance] setEventAlert:^(int event) {
				if([getType() isEqualToString:@"Touch ID"]) {
					if(event == 1) [fingerglyph setState:kGlyphStateScanning animated:YES completionHandler:nil];
					if(event == 2) [fingerglyph setState:kGlyphStateDefault animated:YES completionHandler:nil];
					if(event == 5) {
						[fingerglyph setState:kGlyphStateDefault animated:YES completionHandler:nil];
						CABasicAnimation *shakeanimation = [CABasicAnimation animationWithKeyPath:@"position"];
						shakeanimation.duration = 0.05;
						shakeanimation.repeatCount = 4;
						shakeanimation.autoreverses = YES;
						shakeanimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x - 10, fingerglyph.center.y)];
						shakeanimation.toValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x + 10, fingerglyph.center.y)];
						[fingerglyph.layer addAnimation:shakeanimation forKey:@"position"];
					}
				} else {

					if(event == 1) [fingerglyph setState:6 animated:YES completionHandler:nil];
					if(event == 2) [fingerglyph setState:5 animated:YES completionHandler:nil];
					if(event == 5) {
						[fingerglyph setState:5 animated:YES completionHandler:nil];
						CABasicAnimation *shakeanimation = [CABasicAnimation animationWithKeyPath:@"position"];
						shakeanimation.duration = 0.05;
						shakeanimation.repeatCount = 4;
						shakeanimation.autoreverses = YES;
						shakeanimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x - 10, fingerglyph.center.y)];
						shakeanimation.toValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x + 10, fingerglyph.center.y)];
						[fingerglyph.layer addAnimation:shakeanimation forKey:@"position"];
					}
				}
		}];
		[[ASScanner sharedInstance] startMonitoring];
		[[ASWindow sharedInstance] setTouchInjection:true];

		self.alert = [ASAlertController alertControllerWithTitle:[NSString stringWithFormat:@"\n\n%@", alertTitle] message:[NSString stringWithFormat:prefs[@"customize"][@"lockedMessage"] ?: @"This device is protected by A-Shields\nUse %@ to continue.", getType()] preferredStyle:UIAlertControllerStyleAlert];
		if ([[ASWindow sharedInstance] respondsToSelector:@selector(_setSecure:)]) [[ASWindow sharedInstance] _setSecure:YES];

		fingerglyph = [[objc_getClass("PKGlyphView") alloc] initWithStyle:0];
		if(prefs[@"primaryColor"]) [fingerglyph _setPrimaryColor:LCPParseColorString(prefs[@"primaryColor"], @"#FFFFFF") animated:false];
		if(prefs[@"secondaryColor"]) [fingerglyph _setSecondaryColor:LCPParseColorString(prefs[@"secondaryColor"], @"#FFFFFF") animated:false];
		fingerglyph.frame = CGRectMake(120, 16, 32, 32);
		[self.alert.view addSubview:fingerglyph];

		if([getType() isEqualToString:@"Face ID"]) {
			[fingerglyph setState:5 animated:YES completionHandler:nil];
		}


		[self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[[ASScanner sharedInstance] stopMonitoring];
				[[ASWindow sharedInstance] setTouchInjection:false];
					callback(false);
				}]];
			if(prefs[@"passcode"]) [self.alert addAction:[UIAlertAction actionWithTitle:@"Use Passcode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[[ASScanner sharedInstance] stopMonitoring];

			self.alert = [ASAlertController alertControllerWithTitle:alertTitle message:prefs[@"customize"][@"lockedMessage"] ?: @"This device is protected by A-Shields\nEnter passcode to continue." preferredStyle:UIAlertControllerStyleAlert];

			[self.alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
				textField.placeholder = @"Passcode";
				textField.secureTextEntry = true;
				textField.keyboardType = UIKeyboardTypeNumberPad;
				textField.delegate = [ASViewController sharedInstance];
			}];
			[self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				[[ASWindow sharedInstance] setTouchInjection:false];
				callback(false);
			}]];
			[self.alert addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				if([self.alert.textFields.firstObject.text isEqualToString:prefs[@"passcode"]]) {
					if([prefs[@"session"] isEqual:@1]) self.session = true;
					[self.alert dismissViewControllerAnimated:YES completion:nil];
					[[ASWindow sharedInstance] setTouchInjection:false];
					callback(true);
					if(![prefs[@"disablehaptic"] isEqual:@1]) AudioServicesPlaySystemSound(1521);
				} else {
						self.alert = [ASAlertController alertControllerWithTitle:alertTitle message:prefs[@"customize"][@"authFailMessage"] ?: @"Authentication failed. Please try again." preferredStyle:UIAlertControllerStyleAlert];
						[self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
							[[ASWindow sharedInstance] setTouchInjection:false];
							callback(false);
						}]];
						[self presentViewController:self.alert animated:YES completion:nil];
					}
				}]];
				[self presentViewController:self.alert animated:YES completion:nil];
		}]];
		[self presentViewController:self.alert animated:YES completion:nil];
	} @catch(NSException *ex) {
		[[ASWindow sharedInstance] setTouchInjection:true];
		self.alert = [ASAlertController alertControllerWithTitle:alertTitle message:[NSString stringWithFormat:@"Oops! A-Shields has crashed. Please try again later.\n\n%@", ex.reason] preferredStyle:UIAlertControllerStyleAlert];
		[self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[[ASWindow sharedInstance] setTouchInjection:false];
			callback(false);
		}]];
		[self presentViewController:self.alert animated:YES completion:nil];
	}
}

@end
