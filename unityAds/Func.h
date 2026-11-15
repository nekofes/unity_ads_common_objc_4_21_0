//
//  Func.h
//  unityAds
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>  //objc_setAssociatedObjectを使用したため追加

NS_ASSUME_NONNULL_BEGIN

@interface Func : NSObject

+(BOOL)testMode;
// 画面下部のジェスチャーバーの領域（高さ）を取得するメソッド
+(CGFloat)getBottomGestureBarHeight;
//レイアウト確定（バナー最下部中央配置）
+(void)screenSize:(UIView *)parentView
      screenWidth:(CGFloat *)screenWidth
     screenHeight:(CGFloat *)screenHeight
   safeAreaBottom:(CGFloat *)safeAreaBottom
          adWidth:(CGFloat *)adWidth
         adHeight:(CGFloat *)adHeight
  statusBarHeight:(CGFloat *)statusBarHeight;

+(void)adAreaLabel:(UILabel*)lblAdArea;
+(void)displayAdAreaLabel:(UILabel*)lblAdArea hidden:(BOOL)hidden;
+ (UIButton *)addButtonWithName:(UIButton*)btn
                           name:(NSString *)name
                     parentView:(UIView *)parentView
                          frame:(CGRect)frame
                         action:(void (^)(void))actionBlock;
@end

NS_ASSUME_NONNULL_END
