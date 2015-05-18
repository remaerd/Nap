*Nap* is a REST API authentication frameworks designed for Alamofire

# Features

- [x] OAuth1
- [ ] OAuth2
- [ ] Apple's Account.framework Authentication
- [ ] XAuth
- [ ] HTTP Basic Authentication

# Requirements

- iOS 8.0 / Mac OS X 10.9+
- XCode 6.3+
- Alamofire 1.2+

# Install *Nap* with Carthage

Carthage (www.github.com/carthage/carthage) is adecentralized dependency manager that automates the process of adding frameworks to your Cocoa application.
You can install Carthage with Homebrew using the following command:

```
$ brew update
$ brew install carthage
```

To integrate *Nap* into your Xcode project using Carthage, specify it in your Cartfile:

```
github "Alamofire/Alamofire" >= 1.2
github "remaerd/Nap"
```

# Usage

## Login with OAuth1 web services (Twitter Eample)

```swift

class Service: NSObject, AuthManagerDelegate {

  let options = [
    "baseURL"           : "https://api.twitter.com",
    "idKey"             : "user_id",
    "usernameKey"       : "screen_name",
    "signatureMethod"   : "HMAC-SHA1",
    "requestTokenPath"  : "oauth/request_token",
    "accessTokenPath"   : "oauth/access_token",
    "authorizePath"     : "oauth/authorize",
    "callbackURL"       : "http://example.com",
    "consumerKey"       : "***",
    "consumerSecret"    : "***"]
    
  let manager : OAuth1Manager

  init() {
    self.manager = = OAuth1Manager(options: self.options)
    self.manager?.requestToken({ (account, error) -> Void in
      if error != nil { println("Unable to get request token from Twitter") }
      else {
        self.manager?.authorize(loginController: LoginViewController())
        self.manager.delegate = self
      }
   })
  }

  func didFinishAuthentication(manager: AuthManager, account: Account) {
    println("Logged in as \(account.username)")
  }
}
```
