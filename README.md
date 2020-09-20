# NewsApp
MVVM-C + Rx App

You need to add Keys.plist file with your https://newsapi.org/ api key.

```swift
private let apiKey: String = {
    guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return "" }
    return (NSDictionary(contentsOfFile: path)?["APIKey"] as? String) ?? ""
}()
```
