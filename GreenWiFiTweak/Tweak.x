#import <substrate.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

static BOOL g_tunnelActive = NO;
static NSString* plistPath = @"/var/jb/tmp/com.demo.greenwifi.state.plist";
static UIImage* greenWifiImage = nil;

// 读取共享文件标记
BOOL readTunnelFlag() {
    NSDictionary *stateDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if(!stateDict) return NO;
    return [stateDict[@"tunnelActive"] boolValue];
}

// 加载绿色WiFi图标（rootless路径自动适配）
UIImage* loadGreenWiFi() {
    if(greenWifiImage) return greenWifiImage;
    NSBundle *tweakBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Bundles/GreenWiFiTweak.bundle")];
    greenWifiImage = [UIImage imageNamed:@"greenWifi" inBundle:tweakBundle compatibleWithTraitCollection:nil];
    return greenWifiImage;
}

// 钩子状态栏WiFi图标视图
%hook SBStatusBarWiFiItemView
- (void)updateVisualState {
    %orig;
    if(g_tunnelActive) {
        UIImage *img = loadGreenWiFi();
        if(img) {
            self.image = img;
        }
    }
}
%end

%ctor {
    // 后台轮询监听状态变化，500ms刷新一次
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^{
        while(YES) {
            @autoreleasepool {
                BOOL newVal = readTunnelFlag();
                if(newVal != g_tunnelActive) {
                    g_tunnelActive = newVal;
                    dispatch_async(dispatch_get_main_queue(),^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SBStatusBarNeedsUpdateNotification" object:nil];
                    });
                }
            }
            usleep(500000);
        }
    });
}
