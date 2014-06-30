//
//  CounterViewController.swift
//  SwiftCounter
//
//  Created by Fisher_Wu on 6/27/14.
//  Copyright (c) 2014 Fisher_Wu. All rights reserved.
//

//在iOS开发中，主要使用ViewController来管理与之关联的View、响应界面横竖屏变化以及协调处理事务的逻辑。每个ViewController都有一个view对象，定制的UI对象都将添加到此view上。
import Foundation

import UIKit

class CounterViewController : UIViewController {
    // 重载的方法viewDidLoad非常重要，它在控制器对应的view装载入内存后调用，主要用来创建和初始化UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 在CounterViewController的viewDidLoad方法中，我们通过调用上面定义好的UI创建方法来创建主页面
        self.view.backgroundColor = UIColor.whiteColor()
        setupTimeLabel()
        setuptimeButtons()
        setupActionButtons()
        // 在Xcode中使用快捷键CMD+R运行app，发现预想中的界面并没有出现，这是因为我们还没有设置每个UI控件的位置和大小
    }
    // 注意，所有的UI变量类型后面都带了?号，表示它们是Optional类型，其变量值可以为nil。Optional类型实际上是一个枚举enum，里面包含None和Some两种类型。nil其实是Optional.None，非nil是Option.Some，它通过Some(T)来包装（wrap）原始值，详细解释请参考Swift之?和!。
    // Swift中非Optional类型（任何不带?号的类型）必须通过设置默认值或在构造函数init中完成初始化。前面有提到，ViewController中的UI控件主要是在viewDidLoad方法中进行创建和初始化的，所以我们必须将UI控件设置为Optional类型。

    var timeLabel: UILabel? //show remaining time
    var timeButtons: UIButton[]?    // set time
    var startStopButton: UIButton? // start/stop button
    var clearButton: UIButton? // reset button
    
    // 其次，考虑到时间按钮的样式和功能基本相同，而且以后可能会增加或删减类似按钮，我们使用一个数组timeButtons来保存所有的时间按钮。同时，因为每个按钮的显示标题跟点击后增加的时间不同，我们还需要定义一个数组timeButtonInfos来保存不同按钮的信息：
    let timeButtonInfos = [("1 min", 60), ("3 min", 180), ("5 min", 300), ("1 sec", 1)]
    
    //在使用倒计时器时，我们发现每次点击时间按钮，当前倒计时的时间会累加；而当开始倒计时时，倒计时的时间又会递减。这些操作都牵扯到一个重要的状态：当前倒计时的时间，而且这个状态是不断变化的。
    //所以我们考虑为这个状态定义一个变量，表示当前倒计时剩余的秒数：
    // 其实我们可以使用更Swift的方式来解决状态跟UI的同步问题：使用属性的willSet和/或didSet方法，请参考Property Observers。
    var remainingSeconds: Int = 0 {
    // 我们给remainingSeconds属性添加了一个willSet方法
    // 这个方法会在remainingSeconds的值将要变化的时候调用，并传入变化后的新值作为唯一参数。
    willSet(newSeconds) {
        // 在这个方法里，我们先通过整除/和取余%的方式得到倒计时秒数对应的分钟，和除分钟数外的秒数。假如新值为80（秒），那么计算后，mins值为1，second值为20。
        let mins = newSeconds/60
        let seconds = newSeconds%60
        // 然后，我们通过使用Objective-C中定义的字符串类型NSString来格式化这两个数值，让其显示为分钟:秒钟的形式：比如新值为80，那么格式化后的字符串为01:20。这里多提一句，Swift中提供了自带的String类，它能跟Obejctive-C定义的NSString互相兼容。在使用Swift编程时，我们主要使用String来处理字符串，但由于String类目前还没有提供格式字符串相关的方法，我们只能求助于NSString类型。
        self.timeLabel!.text = NSString(format:"%02d:%02d", mins, seconds)
    }
    }
    
    // 通过点击启动/停止按钮，我们可以启动或停止倒计时。这种操作能让计时器呈现2种不同的状态：正在计时 和 没有计时。为了实现此功能，我们定义了一个布尔类型变量isCounting：
    var isCounting: Bool = false {
    // // 同样，为了实现界面同步，我们为isCounting属性添加了willSet方法：
    willSet(newValue) {
        // 当isCounting的新值newValue为true时，我们将通过调用NSTimer的类方法scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:创建并启动一个每1秒钟调用1次updateTimer:方法的timer，并将返回的实例保存到timer中。
        if newValue {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
        }
        // 当isCounting的新值newValue为false时，我们将暂停timer并将timer设置为nil。此处对timer使用了?修饰符，意思是只有timer是非nil时才做拆包，并调用后面的方法，否则什么也不做。?的用处很多，善用它能写出更安全的代码。
        else {
            timer?.invalidate()
            timer = nil
        }
        setSettingButtonsEnabled(!newValue)
    }
    }
    
    // 同时，在启动计时器后，我们需要每间隔1秒钟就更新一次UI界面的剩余时间。为实现这种定时触发的功能，我们需要用到Foundation库中定义的NSTimer。
    // 为此我们定义了一个NSTimer类型变量timer：
    var timer: NSTimer?
    
    //UI Helpers
    
    // 创建倒计时剩余时间的标签
    func setupTimeLabel() {
        // 首先使用默认构造函数UILabel()创建了一个UILabel实例并赋值给timeLabel属性
        timeLabel = UILabel()
        // 将timeLabel文本颜色设置为白色
        timeLabel!.textColor = UIColor.whiteColor()
        // 字体设置为80号大小的默认字体
        timeLabel!.font = UIFont(name: nil, size: 80)
        // 背景色设为黑色
        timeLabel!.backgroundColor = UIColor.blackColor()
        // 标签中的文本设置为居中对齐
        timeLabel!.textAlignment = NSTextAlignment.Center
        //需要注意的是，在赋值时，每个timeLabel后都带上了一个!号，这是因为timeLabel实际上是Optional类型，它像一个黑盒子一样包装了（wrap）原始值，所以在使用它的原始值时必须先用!操作符来拆包（unwrap）
        
        // 最后，我们将timeLabel添加到了控制器对应的view上。
        self.view.addSubview(timeLabel)
    }
    
    // 创建一组时间按钮
    func setuptimeButtons() {
        // 首先我们创建了一个空数组，用来临时保存生成的按钮
        var buttons: UIButton[] = []
        // 接下来，考虑到在timeButtons中指定位置index的button对应的是timeButtonInfos中相同位置的信息，我们需要获得这个index
        // 通过使用 enumerate 全局函数我们可以为timeButtonInfos创建一个包含index以及数组中元素（也是元组）的元组(index, (title, _))。由于暂时用不到timeButtonInfos中元组的第二个参数（点击增加的时间），我们使用_替代命名，表示不生成对应的变量。
        for (index, (title, _)) in enumerate(timeButtonInfos) {
            // 接着在每次循环开始，我们创建了一个UIButton实例
            let button: UIButton = UIButton()
            // 每个继承自UIView的类（包括UIButton）都继承了属性tag，它主要用一个整数来标记某个view。此处，我们将按钮信息所在的index赋值给button.tag，用来标记button对应的信息所处的位置。
            button.tag = index // save index of button
            // 接着我们设置了按钮的标题
            button.setTitle("\(title)", forState: UIControlState.Normal)
            // 背景色
            button.backgroundColor = UIColor.orangeColor()
            // 不同点击状态下的标题颜色
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            // 除了显示作用，按钮还可以响应用户的点击操作。我们通过addTarget:action:forControlEvents:方法给button添加了可以响应按下按钮并抬起操作的回调方法：timeButtonTapped:。
            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            // 最后我们将这个临时按钮加入buttons数组
            buttons += button
            // 并将此按钮添加到视图上。
            self.view.addSubview(button)
        }
        timeButtons = buttons
    }
    
    // 创建2个操作按钮
    func setupActionButtons() {
        // create start/stop button
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        startStopButton!.setTitle("start/stop", forState: UIControlState.Normal)
        // 为startStopButton设置了点击后的回调方法startStopButtonTapped:
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStopButton)
        
        // create clear button
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        clearButton!.setTitle("reset", forState: UIControlState.Normal)
        // 为clearButton设置了点击后的回调方法clearButtonTapped:
        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(clearButton)
    }
    
    
    // 简单定义了这几个所需的按钮按下回调方法
    ///Actions & Callbacks
    
    // 界面已开发完毕，现在我们考虑为计时器app添加以下功能：
    //    设置时间
    //    启动和停止倒计时
    //    在计时完成后进行提醒
    
    
    func startStopButtonTapped(sender: UIButton) {
        // 接着，在用户点击启动/停止按钮时触发的回调方法startStopButtonTapped:中，我们切换了isCounting的状态：
        isCounting = !isCounting
        
        // 接下来，我们更新了启动/停止按钮响应的startStopButtonTapped:回调方法：
        if isCounting {
            // 在启动计时器时创建并注册计时完成时的本地提醒
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            // 当计时器停止时，取消当前app所注册的所有本地提醒。
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func clearButtonTapped(sender: UIButton) {
        remainingSeconds = 0
    }
    
    func timeButtonTapped(sender: UIButton) {
        // 按钮回调方法中的唯一参数sender，代表触发此回调方法的控件。
        let (_, seconds) = timeButtonInfos[sender.tag]
        // 在timeButtonTapped:方法中，我们通过控件的tag来找到对应的按钮的信息。按钮信息是一个元组，其中第二个参数存储着每次点击按钮需要增加的秒数，我们将此秒数增加到remainingSeconds上。
        remainingSeconds += seconds
        // 现在在设置或复位时间时，remainingSeconds的值可以正常更新了，我们需要考虑如何让UI界面也能及时显示剩余时间。通常的做法，是在按钮的回调方法中，除了设置remainingSeconds的值，也同时通过设置timeLabel的text属性来更新UI。这种做法可以解决问题，但并不最佳方案，因为我们除了需要在timeButtonTapped:中设置UI；也需要在clearButtonTapped:中设置UI；还需要在计时器启动后，在适当的回调中逐秒递减时设置UI。这样会造成很多重复的代码，且难于管理。
    }
    
    func updateTimer(timer: NSTimer) {
        // 同时我们定义了updateTimer:方法来更新当前的倒计时时间：
        remainingSeconds -= 1
        
        // 当倒计时自然结束时（不是人为点击启动/停止按钮来停止），如果当前app还处于激活状态（用户没有按Home键退出），那么我们此时将弹出一个警告窗口(UIAlertView)，来提示倒计时已完成
        if remainingSeconds <= 0 {
            let alert = UIAlertView()
            alert.title = "计时完成！"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    
    //在Xcode中使用快捷键CMD+R运行app，发现预想中的界面并没有出现，这是因为我们还没有设置每个UI控件的位置和大小。
    //
    //实际上，所有继承自UIView的UI控件类都可以使用init:frame:构造函数来创建指定位置、大小的UI控件。
    //
    //如果你的app只支持一种方向的屏幕（比如说竖屏），这样做是没问题的；但如果你的app需要同时支持竖屏和横屏，那么最好重载ViewController中的viewWillLayoutSubviews方法。这个方法会在ViewController中的视图view大小改变时自动调用（横竖屏切换会改变视图控制器中view的大小），也提供了最好的时机来设置UI控件的位置和大小。
    //
    //所以我们在CounterViewController中重载此方法，并为每个UI控件设置了合适的位置和大小：
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 在iOS设备中，视图坐标系是以左上角(0,0)为原点，使用CGRect结构体来表示一个矩形位置
        // 使用CGRectMake全局函数来创建矩形结构体的实例。每个继承自UIView的UI类都有一个类型为CGRect的frame属性，用来保存其在父view中的位置。
        // 我们首先设置了timeLabel的frame，其左上角为(10,40)，
        // 宽度为整个CounterViewController中view的宽度-20（为右边也留出10的边），高度为120；
        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width-20, 120)
        
        // 其次我通过循环整个时间按钮数组，为每个按钮设置了合适的frame。
        // 这里为了让时间按钮的排列能够自动适应不同屏幕的宽度，我们先计算中每个按钮之间的间距gap，然后根据gap、按钮的宽度64来确定每个按钮的左边距buttonLeft，并最终得到每个按钮的frame。
        let gap = ( self.view.bounds.size.width - 10*2 - (CGFloat(timeButtons!.count) * 64) ) / CGFloat(timeButtons!.count - 1)
        for (index, button) in enumerate(timeButtons!) {
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height-120, 64, 44)
        }
        // 最后，我们为startStopButton按钮和clearButton也设置了合适的frame。
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height-60, self.view.bounds.size.width-20-100, 44)
        clearButton!.frame = CGRectMake(10+self.view.bounds.size.width-20-100+20, self.view.bounds.size.height-60, 80, 44)
        
    }
    
    // 此外，由于时间按钮和复位按钮只在计时器停止时起作用，在计时器启动时无效，我们还提供了辅助方法 setSettingButtonsEnabled: 用来设置这些按钮在不同isCounting状态下的样式（settingButtons是指在设置时间时，也就是计时器停止时可以操作的按钮）：
    func setSettingButtonsEnabled(enabled: Bool) {
        for button in self.timeButtons! {
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }
    
    // 很多情况下，用户在app计时未结束时就离开了计时器app（计时器处于未激活状态），那么当计时完成时，我们如何来通知用户呢？对这种情况，我们可以使用系统的本地通知UILocalNotification。我们先定义一个辅助方法createAndFireLocalNotificationAfterSeconds:来创建和注册一个N秒钟后的本地提醒事件
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {
        // 在方法实现中，我们先调用cancelAllLocalNotifications取消了所有当前app已注册的本地消息
        /// ??
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        // 之后创建了一个新的本地消息对象notification。
        let notification = UILocalNotification()
        // 接下来我们要为notifcation设置消息的激活时间
        // 由于方法接受的参数timeIntervalSinceNow是double类型，我们先将Int类型seconds通过bridgeToObjectiveC()方法转换成兼容的NSNumber对象，再调用其doubleValue方法获得对应的值。
        let timeIntervalSinceNow = seconds.bridgeToObjectiveC().doubleValue
        // 我们通过NSDate(timeIntervalSinceNow: double)构造器创建了从当前时间往后推N秒的一个时间
        notification.fireDate = NSDate(timeIntervalSinceNow:timeIntervalSinceNow);
        // 之后我们将本地消息的时区设置为系统时区
        notification.timeZone = NSTimeZone.systemTimeZone();
        // 提示消息为“计时完成！
        notification.alertBody = "计时完成！";
        // 并最终完成此消息的注册。
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
        
    }
}
