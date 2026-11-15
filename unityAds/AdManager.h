//
//  AdManager.h
//  unityAds
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> //これを書き足すことで UIWindow エラーが一瞬で消えます！
//Unity Ads SDKをインポート
#import <UnityAds/UnityAds.h>
#import "Func.h"

//画面側でロード完了をキャッチするためのプロトコル定義
@protocol AdManagerDelegate <NSObject>
- (void)adManagerDidRegisterBannerAd;
- (void)adManagerDidShowBannerAd; //表示された時用
- (void)adManagerDidFailToLoadBannerAd; //ロード失敗時用
@end

NS_ASSUME_NONNULL_BEGIN

@interface AdManager : NSObject <UADSBannerAdDelegate>

// 最新の広告オブジェクトを保持するプロパティ
@property (nonatomic, strong) UADSBannerAd *bannerAd;
@property (nonatomic, strong) UADSInterstitialAd *interstitialAd;//読み込んだ全画面広告オブジェクトを保持する

//通知先の画面（ViewController）を指すデリゲートプロパティを追加
@property (nonatomic, weak) id<AdManagerDelegate> delegate;

@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *interstitialPlacementId;
@property (nonatomic, strong) NSString *bannerPlacementId;

//アプリ全体で共通のマネージャーを取得するクラスメソッド
+ (instancetype)sharedManager;
- (void)initializeSDK;

// 広告のロード処理をまとめる
- (void)loadAllAds;
// インタースティシャル広告のロード
- (void)loadInterstitialAd;
// バナー広告のロード
- (void)loadBannerAd;

- (void)unityId;
// 初期化やロード用のメソッド宣言
- (void)initializeSDKWithGameId;
@end

NS_ASSUME_NONNULL_END
