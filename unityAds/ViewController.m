#import "ViewController.h"

@implementation ViewController

@synthesize viewController;
@synthesize gameId;
@synthesize interstitialPlacementId;
@synthesize bannerPlacementId;
@synthesize lblAdArea;
@synthesize btn;
@synthesize screenWidth;
@synthesize screenHeight;
@synthesize safeAreaBottom;
@synthesize adWidth;
@synthesize adHeight;
@synthesize statusBarHeight;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 画面の背景色を明示的に「白」にする
    self.view.backgroundColor = [UIColor whiteColor];

    //自分自身（ViewController）を通知先としてAdManagerに登録する
    [AdManager sharedManager].delegate = self;

    //画面準備
    //ここではまだ枠サイズが未確定のため、初期配置でaddSubviewだけ行います
    [self screen];
    
    [[AdManager sharedManager] unityId];
    
    [[AdManager sharedManager] initializeSDKWithGameId];
}
//画面準備
-(void)screen
{
    lblAdArea = [[UILabel alloc] init];
    [Func adAreaLabel:lblAdArea];
    [self.view addSubview:lblAdArea];
    
    self.btn = [Func addButtonWithName:btn
                                  name:@"次へ進む"
                             parentView:self.view
                                  frame:CGRectZero
                                 action:^{
        UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;
        bannerAd.view.hidden = YES;
        [bannerAd.view removeFromSuperview];
        NSLog(@"pushViewController bannerAd.view.hidden = YES;");
        self.viewController = [[NextScreen alloc] init];
        [self.navigationController pushViewController:self.viewController animated:YES];
    }];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //画面サイズが確定したこの瞬間に、サイズを取得して下地ラベルを正しい位置へ移動させます
    //第一引数に「self.view」を渡し、残りの変数には「&」をつけてポインタを渡します
    [Func screenSize:self.view
         screenWidth:&screenWidth
        screenHeight:&screenHeight
      safeAreaBottom:&safeAreaBottom
             adWidth:&adWidth
            adHeight:&adHeight
     statusBarHeight:&statusBarHeight
    ];

    CGFloat yLabel = screenHeight - (adHeight + safeAreaBottom);
    lblAdArea.frame = CGRectMake(0, yLabel, screenWidth, adHeight);

    //既に生成されているボタンの位置を確定
    CGFloat width = 200.0f;
    CGFloat xPos = (screenWidth - width) / 2.0;
    if (self.btn) {
        self.btn.frame = CGRectMake(xPos, statusBarHeight, width, adHeight);
    }
    //共通クラスが保持しているバナーを取得して画面に追加するだけ
    UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;

    //オブジェクトがあり、まだ画面に追加されていなければ、ここで追加します
    if (bannerAd && bannerAd.view)
    {
        if (bannerAd.view.superview == nil)
        {
            bannerAd.view.hidden = YES;
            [self adPositon:bannerAd];
            [self.view addSubview:bannerAd.view]; //画面に追加します
        }
    }

    if (bannerAd && bannerAd.view && bannerAd.view.superview)
    {
        xPos = (screenWidth - adWidth) / 2.0;
        CGFloat yPos = screenHeight - adHeight - safeAreaBottom;

        bannerAd.view.frame = CGRectMake(xPos, yPos, adWidth, adHeight);
        // 広告が表示されたので、下地ラベルを非表示に切り替えます
        [Func displayAdAreaLabel:lblAdArea hidden:YES];

    }
}
-(void)adPositon:(UADSBannerAd*)bannerAd
{
    CGFloat xPos = (screenWidth - adWidth) / 2.0;
    CGFloat yPos = screenHeight - adHeight - safeAreaBottom;
    bannerAd.view.frame = CGRectMake(xPos, yPos, adWidth, adHeight);

}
#pragma mark - AdManagerDelegate (AdManagerからの状態通知窓口/広告準備完了の通知を受ける窓口)
- (void)adManagerDidRegisterBannerAd
{
    UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;
    if (bannerAd && bannerAd.view)
    {
        if (bannerAd.view.superview == nil)
        {
            [self adPositon:bannerAd];
            [self.view addSubview:bannerAd.view];
            /*
            広告スペースはデフォルトで画面左上に設置されているようです。
            そのため広告が表示されるまでは非表示にします。
            UADSBannerAdDelegateのデリゲートイベントで表示判定をして
            hiddenをNOに戻し、広告を表示させます。
            */
            bannerAd.view.hidden = YES;
        }
    }
}
#pragma mark - UADSBannerAdDelegate (バナー広告のデリゲートイベント)
//広告が正常に表示された通知を受け取った時
- (void)adManagerDidShowBannerAd
{
    NSLog(@"[画面連動] バナーが表示された通知を受け取りました。目印ラベルを【非表示】にします。");
    
    //広告エリアの下地ラベルを隠す（YES = 非表示）
    [Func displayAdAreaLabel:lblAdArea hidden:YES];

    //広告が貼られた直後なので、念のためもう一度完璧に配置を確定させる
    [self.view setNeedsLayout];
}

//広告のロードが失敗した通知を受け取った時
- (void)adManagerDidFailToLoadBannerAd
{
    NSLog(@"[画面連動] バナーが失敗した通知を受け取りました。目印ラベルを【表示】にします。");
    
    //広告が出なかったので、下地ラベルを表示させる（NO = 表示）
    [Func displayAdAreaLabel:lblAdArea hidden:NO];
}

#pragma mark - クリーンアップ
- (void)cleanupBannerAd
{
    //ViewController側で保持している可能性のあるローカルな参照を安全にクリアします
    UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;
    if (bannerAd)
    {
        if (bannerAd.view)
        {
            [bannerAd.view removeFromSuperview];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;
    if(bannerAd.view)
    {
        [self.view addSubview:bannerAd.view];
        [self adPositon:bannerAd];
        //この再表示をすると広告が消えてしまう
        //[self.view setNeedsLayout];
        //[self.view layoutIfNeeded];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)dealloc
{
    // 画面自体が完全に破棄される時は綺麗に片付けます
    [self cleanupBannerAd];
    if ([AdManager sharedManager].delegate == self)
    {
        [AdManager sharedManager].delegate = nil;
    }
}

@end
