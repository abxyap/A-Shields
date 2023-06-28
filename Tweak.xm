#import <MRYIPCCenter.h>
#import <LocalAuthentication/LocalAuthentication.h>
#include <AudioToolbox/AudioToolbox.h>
#import <Preferences/PSListController.h>
#import "./headers/SpringBoard.h"
#import "./headers/ControlCenter.h"
#import "./ASScanner.h"
#import "./ASViewController.h"
#import "./ASWindow.h"

// socat - UNIX-CONNECT:/var/run/lockdown/syslog.sock

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

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
	%orig;
  [ASWindow sharedInstance];

	MRYIPCCenter *center = [MRYIPCCenter centerNamed:@"com.rpgfarm.a-shields"];
	[center addTarget:self action:@selector(handleAShieldsVerify:)];
}

%new
-(void)handleAShieldsVerify:(NSDictionary *)args {
	[[ASViewController sharedInstance] verifyTouchID:args[@"title"] reply:^(BOOL success){
		[[%c(NSDistributedNotificationCenter) defaultCenter] postNotificationName:[NSString stringWithFormat:@"com.rpgfarm.a-shields.%@.verify", args[@"bundleID"]] object:nil userInfo:@{ @"success": success ? @1 : @0 }];
	}];
}
%end


%hook SBLockScreenManager
-(void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 {
	%orig;
	[[ASScanner sharedInstance] stopMonitoring];
	[[ASViewController sharedInstance] setSession:false];
	[[ASViewController sharedInstance] closeAlert];
	[[ASWindow sharedInstance] setTouchInjection:false];
}
%end
NSMutableArray *lockedIcons;
%hook SBIconView
%property (nonatomic, retain) UIImageView *lockImageView;
-(void)prepareForReuse {
	if(self.lockImageView) {
		[self.lockImageView removeFromSuperview];
		self.lockImageView = nil;
	}
	[	lockedIcons removeObject:self];
	%orig;
}
-(void)_updateLabel {
	%orig;
	SBIcon *icon = self.icon;
	SBApplication *app = [icon application];
	NSString *bundleID = [app bundleIdentifier];
	if(bundleID == nil) return;
	if([prefs[@"badge"] isEqual:@1] && ![[ASViewController sharedInstance] session] && !(prefs[@"wifi"] && [prefs[@"wifi"][[[objc_getClass("SBWiFiManager") sharedInstance] currentNetworkName]] isEqual:@1]) && [prefs[@"app"][bundleID] isEqual:@1] && ![icon isFolderIcon]) {
		[self setIconImageAlpha:0.3];
		[self setIconAccessoryAlpha:0.3];
		[self _applyIconImageAlpha:0.3];
		if(!self.lockImageView) {
			self.lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"/Library/BawAppie/AShields/lock.png"]];
			CGFloat width = self.frame.size.width;
			self.lockImageView.frame = CGRectMake(width/2-width/4, width/2-width/4, width/2, width/2);
			[self addSubview:self.lockImageView];
		} else {
			CGFloat width = self.frame.size.width;
			self.lockImageView.frame = CGRectMake(width/2-width/4, width/2-width/4, width/2, width/2);
		}
		[lockedIcons addObject:self];
	} else if(self.lockImageView) {
		[self.lockImageView removeFromSuperview];
		self.lockImageView = nil;
		[lockedIcons removeObject:self];
	}
}
%new
-(void)ashieldsUnlock {
	if(![[ASViewController sharedInstance] session]) return;
	if(self.lockImageView) {
		[self.lockImageView removeFromSuperview];
		self.lockImageView = nil;
	}
	[self setIconImageAlpha:1];
	[self setIconAccessoryAlpha:1];
	[self _applyIconImageAlpha:1];
	[lockedIcons removeObject:self];
}
%end

%hook SBFluidSwitcherGestureWorkspaceTransaction
-(void)_didComplete {
	%orig;
	if([[objc_getClass("SBMainSwitcherViewController") sharedInstance] isMainSwitcherVisible]) return;
	SBApplication *app = [[objc_getClass("SpringBoard") sharedApplication] _accessibilityFrontMostApplication];
	NSString *bundle = [app bundleIdentifier];
	NSString *name = [app displayName];
	if(![prefs[@"app"][bundle] isEqual:@1]) return %orig;
	[[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@ for %@", getType(), name] reply:^(BOOL success) {
		if(!success) [[objc_getClass("SpringBoard") sharedApplication] _simulateHomeButtonPress];
	}];
}
%end


%hook SBMainWorkspace
- (void)setCurrentTransaction:(SBWorkspaceTransaction *)trans {
	// HBLogError(@"[AShields] trans %@", trans);
	if([[[trans transitionRequest] eventLabel] isEqualToString:@"ActivateSwitcherNoninteractive"]) return %orig;
	if (([trans isKindOfClass:objc_getClass("SBAppToAppWorkspaceTransaction")] || [trans isKindOfClass:objc_getClass("SBCoverSheetToAppsWorkspaceTransaction")]) && ![trans isKindOfClass:objc_getClass("SBRotateScenesWorkspaceTransaction")]) {
		NSArray *activatingApplications = [[[trans transitionRequest] toApplicationSceneEntities] allObjects];
		if (activatingApplications.count == 0) return %orig;
		// HBLogError(@"[AShields] activatingApplications %@", activatingApplications);
		SBApplication *app = [activatingApplications[0] application];
		NSString *bundle = [app bundleIdentifier];
		NSString *name = [app displayName];
		if(![prefs[@"app"][bundle] isEqual:@1]) return %orig;
		[[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@ for %@", getType(), name] reply:^(BOOL success) {
			@try {
				if(success && ![trans isComplete]) %orig;
				else if([trans isComplete]) {
					// NSLog(@"[AShields] Already completed.");
				}
			} @catch(NSException *e) {

			}
		}];
	} else return %orig;
}

%end

@interface PSUIPrefsListController : UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@import Preferences.PSTableCell;
@interface PSTableCell (AShields)
-(NSString *)title;
@end

%hook PSUIPrefsListController
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	PSTableCell *cell = (PSTableCell *)[self tableView:arg1 cellForRowAtIndexPath:arg2];
	if([cell.title isEqualToString:@"A-Shields"]) {
		[[ASViewController sharedInstance] verifyTouchID:@"Access A-Shields Preferences" reply:^(BOOL success){
			if(success) %orig;
		}];
	} else %orig;
}
%end

%hook CCUIRoundButton
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
  CCUILabeledRoundIcon *view = (CCUILabeledRoundIcon *)[self superview];
  NSArray *set = [[self allTargets] allObjects];
  NSString *connectivityType = @"unknown";
  for(id controller in set) {
    if([controller isKindOfClass:[%c(CCUIConnectivityBluetoothViewController) class]]) connectivityType = @"bluetooth";
    else if([controller isKindOfClass:[%c(CCUIConnectivityWifiViewController) class]]) connectivityType = @"wifi";
    else if([controller isKindOfClass:[%c(CCUIConnectivityAirplaneViewController) class]]) connectivityType = @"airplane";
    else if([controller isKindOfClass:[%c(CCUIConnectivityCellularDataViewController) class]]) connectivityType = @"cellular";
    else if([controller isKindOfClass:[%c(CCUIConnectivityHotspotViewController) class]]) connectivityType = @"hotspot";
    else if([controller isKindOfClass:[%c(CCUIConnectivityAirDropViewController) class]]) connectivityType = @"airdrop";
  }
  if(![prefs[@"cc"][connectivityType] isEqual:@1]) return %orig;
  if([view respondsToSelector:@selector(title)]) {
	  [[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@ for %@", getType(), view.title] reply:^(BOOL success) {
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	      if(success) %orig;
	    });
	  }];
	} else {
	  [[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@", getType()] reply:^(BOOL success) {
	      if(success) %orig;
	  }];
	}
}
%end

void loadPrefs() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"];
}
void ashieldsUnlocked() {
	NSArray *arr = [lockedIcons copy];
	for (SBIconView *icon in arr) {
		[icon ashieldsUnlock];
	}
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ashieldsUnlocked, CFSTR("com.rpgfarm.ashields/ashieldsunlocked"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  loadPrefs();
  lockedIcons = [@[] mutableCopy];
}
