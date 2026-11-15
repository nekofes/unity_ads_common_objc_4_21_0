//
//  ViewController.h
//  unityAds
//

#import <UIKit/UIKit.h>
//Unity Ads SDKをインポート
#import <UnityAds/UnityAds.h>

#import "Func.h"
#import "AdManager.h"
#import "NextScreen.h"

//@interface ViewController : UIViewController
@interface ViewController : UIViewController <AdManagerDelegate> //規約を追加

@property (nonatomic) id viewController;//画面コントロール

@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *interstitialPlacementId;
@property (nonatomic, strong) NSString *bannerPlacementId;
@property (nonatomic) UILabel *lblAdArea;
@property (nonatomic) UIButton *btn;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat safeAreaBottom;
@property (nonatomic) CGFloat adWidth;
@property (nonatomic) CGFloat adHeight;
@property (nonatomic) CGFloat statusBarHeight;
@end

