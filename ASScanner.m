#include "ASScanner.h"

@implementation ASScanner

+(instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedSelf = nil;
  dispatch_once(&p, ^{
    _sharedSelf = [[self alloc] init];
  });
  return _sharedSelf;
}

BOOL success = false;
BOOL FaceID = false;

-(void)biometricResource:(void *)arg2 observeEvent:(unsigned long long)arg3 {
	if (!self.isMonitoring) return;
	HBLogError(@"Biometry Kit %llu", arg3);
	switch (arg3) {
		case TouchIDFingerDown: {
			HBLogDebug(@"Finger down");
     	self.eventAlert(1);
			break;
		}
		case TouchIDFingerUp: {
			HBLogDebug(@"Finger up");
			self.eventAlert(2);
			if(success) {
				success = false;
				[self stopMonitoring];
			}
			break;
		}
		case TouchIDFingerHeld:
			HBLogDebug(@"Finger held");
    		self.eventAlert(3);
			break;
		case TouchIDMatched:
			HBLogDebug(@"Finger matched");
 		 	self.eventAlert(4);
  		self.callback(TRUE);
			if(FaceID) [self stopMonitoring];
     	success = true;
			break;
		case TouchIDNotMatched: {
			HBLogDebug(@"Authentication failed");
			self.eventAlert(5);
			self.callback(FALSE);
			break;
		}
		case 10: {
			HBLogDebug(@"Authentication failed");
			self.eventAlert(5);
			self.callback(FALSE);
			break;
		}

		case 13: {
			FaceID = true;
			HBLogDebug(@"Finger down");
     	self.eventAlert(1);
			break;
		}

		case 28: {
			FaceID = true;
			HBLogDebug(@"Mask Detected");
     	self.eventAlert(6);
			break;
		}
	}

  return;
}

- (void)startMonitoring {
	if (self.isMonitoring) return;
	[[objc_getClass("SBUIBiometricResource") sharedInstance] setValue:@(1) forKey:@"_isMatchingAllowed"];
	[[objc_getClass("SBUIBiometricResource") sharedInstance] addObserver:self];

	self.assertion = [[objc_getClass("SBUIBiometricResource") sharedInstance] acquireMatchingAssertionWithMode:3 reason:@"A-Shields Authentication"];
	self.isMonitoring = YES;
	HBLogDebug(@"Touch ID monitoring began");
}

- (void)stopMonitoring {
	if (!self.isMonitoring) return;
	[[objc_getClass("SBUIBiometricResource") sharedInstance] removeObserver:self];
	[self.assertion invalidate];
	self.assertion = nil;
	self.isMonitoring = NO;
	HBLogDebug(@"Touch ID monitoring ended");
}


@end
