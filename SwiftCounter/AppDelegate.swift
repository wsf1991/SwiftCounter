//
//  AppDelegate.swift
//  SwiftCounter
//
//  Created by Fisher_Wu on 6/27/14.
//  Copyright (c) 2014 Fisher_Wu. All rights reserved.
//
/*
    AppDelegate类中定义了app进入不同生命周期（包括app启动动、闲置、进入后台、进入前台、激活、完全退出）时的回调方法。
    实际上在app启动时，app会自动执行一个叫main的入口函数，它通过调用UIApplicationMain函数来创建出AppDelegate类实例，
    并委托其实现app在不同生命周期的定制行为。
*/

/*  iOS开发中基本UI元素
    UIScreen 代表一块物理屏幕；
    UIWindow 代表一个窗口，在iPhone上每个app一般只有一个窗口，而在Mac上一个app经常有多个窗口；
    UIView 代表窗口里某一块矩形显示区域，用来展示用户界面和响应用户操作；
    UILabel和UIButton，继承自UIView的特定UI控件，实现了特定的样式和行为

*/

/* 后记

通过完成此教程，我对Swift语言的理解也更进了一步。Swift是一门全新的语言，作为开发者，我们需要不断加深对这门语言的理解，并灵活使用语言提供的特性来编程。虽然在开发中还需要大量使用Cocoa(Touch)中提供的Objective-C类库，但编程的方式已经完全改变了，不仅仅是将Objective-C代码翻译成Swift代码，而需要在代码层面进行重新思考。

*/
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        //在app启动完成的回调方法application:didFinishLaunchingWithOptions中，首先创建一个UIWindow对象
        //首先，它通过获取主屏幕的尺寸，创建了一个跟屏幕一样大小的窗口；然后将其背景色为白色；并调用makeKeyAndVisible()方法将此窗口显示在屏幕上。
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        // 在介绍如何定制计时器UI之前，我们需要先将CounterViewController的view跟app中唯一的窗口Window关联起来。完成此操作只需
        //这样CounterViewController的view会自动添加到Window上，用户启动app后直接看到的将是CounterViewController中view的内容。
        self.window!.rootViewController = CounterViewController()
        
        // 值得注意的是，在iOS8中使用本地消息也需要先获得用户的许可，否则无法成功注册本地消息。因此，我们将询问用户许可的代码片段也添加到了app启动后的入口方法中（AppDelegate中的didFinishLaunchingWithOptions）：
        //register notification
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert |
            UIUserNotificationType.Badge, categories: nil
            ))
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
   

}

