# BreadCrumbNavigationController V1.0
It is for showing pushed controller hierarchy in navigation controller just like a bread crumb. It is very easy to integrate with 0 line of code, you just need to change the class name of your navigation controller in storyboard


**How to Implement:**
You just need to replace the UINavigationController class to  BreadCrumbNavigationController class in storyboard and it will show the title of all pushed ViewControllers in the navigation bar as bread crumb. These titles are tappable and navigate you to the corresponding ViewController.

**Customizable Parameters:**
- seperatorImageName     [If not set then a blank view of width 5px is used as seperator]
- breadCrumbFontName     [if not set then default is Arial]
- breadCrumbFontSize     [If not set then default is 14px]
- breadCrumbTitleColor   [If not set then default is black]
- backButtonImageName    [If not set then default is Button with Text = Back]
- breadCrumbMaxWidth     [If not set then default is 100 px, After that title will be trimmed]
- navigationBarSize      [Set only if your bread crumb navigation controller is not occupying whole screen]

***Note**: Parameter can be set in User Defined Runtime Attributes. No need to make its instance programmatically*