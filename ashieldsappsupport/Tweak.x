#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <LocalAuthentication/LocalAuthentication.h>

static CPDistributedMessagingCenter *center;
typedef void (^myBlock) (BOOL success, NSError *error);
myBlock savedReply;

NSDictionary *prefs;

%hook LAContext
- (void)evaluatePolicy:(LAPolicy)policy localizedReason:(NSString *)localizedReason reply:(void (^)(BOOL success, NSError *error))reply {
	if([prefs[@"emulateLAPolicy"] isEqual:@1]) return %orig;
	HBLogError(@"[AShields] Start Evaluating LocalAuthentication");
	if(policy == LAPolicyDeviceOwnerAuthenticationWithBiometrics || policy == LAPolicyDeviceOwnerAuthentication) {
	    [center sendMessageName:@"handleAShieldsVerify" userInfo:@{
	    	@"title": localizedReason,
	    	@"bundleID": [NSBundle mainBundle].bundleIdentifier
	    }];
	    savedReply = reply;
	}
	else %orig;
}
%end

void loadPrefs() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"];
}

%ctor {
	if([[NSBundle mainBundle].bundleIdentifier hasPrefix:@"com.apple."]) return;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();

	center = [CPDistributedMessagingCenter centerNamed:@"com.rpgfarm.a-shields"];
  	rocketbootstrap_distributedmessagingcenter_apply(center);

	[[%c(NSDistributedNotificationCenter) defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.rpgfarm.a-shields.%@.verify", [NSBundle mainBundle].bundleIdentifier] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSDictionary *result = [notification userInfo];

	    if([result[@"success"] isEqual:@1]) savedReply(true, nil);
	    else {
		    NSDictionary *userInfo = @{
		        NSLocalizedDescriptionKey: @"Operation was unsuccessful.",
		        NSLocalizedFailureReasonErrorKey: @"Operation was unsuccessful.",
		        NSLocalizedRecoverySuggestionErrorKey: @"Don't access this again"
		    };
		    NSError *error = [NSError errorWithDomain:@"ERROR" code:LAErrorUserCancel userInfo:userInfo];
		    savedReply(false, error);
		}
	}];
}
