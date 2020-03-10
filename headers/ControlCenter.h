@interface CCUIRoundIcon : UIControl
@end
@interface UIView (Private)
@property (assign, nonatomic) UIViewController *viewDelegate;
@end
@interface CCUILabeledRoundIcon : UIView
@property (nonatomic, retain) NSString *title;
@end

@interface CCUIConnectivityButtonViewController : UIViewController
@end
@interface CCUIConnectivityWifiViewController : CCUIConnectivityButtonViewController
@end
@interface CCUIConnectivityHotspotViewController : CCUIConnectivityButtonViewController
@end
@interface CCUIConnectivityAirDropViewController : CCUIConnectivityButtonViewController
@end
@interface CCUIConnectivityAirplaneViewController : CCUIConnectivityButtonViewController
@end
@interface CCUIConnectivityCellularDataViewController : CCUIConnectivityButtonViewController
@end
@interface CCUIConnectivityBluetoothViewController : CCUIConnectivityButtonViewController
@end
