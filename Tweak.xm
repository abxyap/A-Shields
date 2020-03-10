#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
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
			return @"Error";
		}
	} else return typeCache;
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
	%orig;
  [ASWindow sharedInstance];
	CPDistributedMessagingCenter *_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.rpgfarm.a-shields"];
	rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
	[_messagingCenter runServerOnCurrentThread];
	[_messagingCenter registerForMessageName:@"verifyTouchID" target:self selector:@selector(handleAShieldsVerify:withUserInfo:)];
}

%new
-(void)handleAShieldsVerify:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	[[ASViewController sharedInstance] verifyTouchID:userInfo[@"title"] reply:^(BOOL success){
		[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] postNotificationName:[NSString stringWithFormat:@"com.rpgfarm.a-shields-app-support.%@", userInfo[@"bundle"]] object:nil userInfo:@{
			@"success": [NSNumber numberWithBool:success]
		}];
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

%hook SBMainWorkspace
- (void)setCurrentTransaction:(SBWorkspaceTransaction *)trans {
	NSLog(@"[AShields] trans %@", trans);
	if([[[trans transitionRequest] eventLabel] isEqualToString:@"ActivateSwitcherNoninteractive"]) return %orig;
	if (([trans isKindOfClass:objc_getClass("SBAppToAppWorkspaceTransaction")] || [trans isKindOfClass:objc_getClass("SBCoverSheetToAppsWorkspaceTransaction")]) && ![trans isKindOfClass:objc_getClass("SBRotateScenesWorkspaceTransaction")]) {
		HBLogDebug(@"class check ok");
		NSArray *activatingApplications = [[(SBToAppsWorkspaceTransaction *)trans toApplicationSceneEntities] allObjects];
		HBLogDebug(@"activatingApplications %@", activatingApplications);
		if (activatingApplications.count == 0) return %orig;
		SBApplication *app = [activatingApplications[0] application];
		NSString *bundle = [app bundleIdentifier];
		NSString *name = [app displayName];
		if(![prefs[@"app"][bundle] isEqual:@1]) return %orig;
		[[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@ for %@", getType(), name] reply:^(BOOL success) {
				if(success) %orig;
		}];
	} else return %orig;
}

%end

@interface PSUIPrefsListController : UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface PSTableCell
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
  [[ASViewController sharedInstance] verifyTouchID:[NSString stringWithFormat:@"%@ for %@", getType(), view.title] reply:^(BOOL success) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if(success) %orig;
    });
  }];
}
%end

void loadPrefs() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"];
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  loadPrefs();
}
